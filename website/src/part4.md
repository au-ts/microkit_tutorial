# Part 4 - Virtual machines

*Note: virtual machines are currently an experimental feature of Microkit*

Now that you have a playable Wordle, you will notice that the word to guess
is always "hello" and does not change. That is a bit boring and not realistic.

The real Wordle game client works by having some server contain the word that
changes every day. What if we could do something similar so that every time we
start the game, we have to guess a new word? One way of doing this would be
talking to some external server that picks a random word which the Wordle server
receives.

This approach sounds complicated, and from part 1 you will know that in this tutorial we had to implement our own device driver just to be able to output characters to a screen. Talking
to the internet would require an ethernet device driver which is non-trivial to create.

What if we wanted to have other more complicated systems? We would have to implement a lot
of device drivers. For hardware like USB or Bluetooth, there would be
hundreds of thousands of lines of code we would have to port from Linux or something
else to get working on seL4.

**However**, there is a quicker and easier approach. We can run a virtual machine! [^vms]

In this part, you will be shown how to run a virtual machine running Linux using
Microkit. We will make use of the ethernet driver that already exists in Linux to
talk to a server `{{LEARNMICROKIT_WORD_URL}}` that responds with a new five-letter word
on every request.

If you do `wget -qO- {{LEARNMICROKIT_WORD_URL}}`, you should see a new word each time
you run the command.

## Virtual machines on seL4

<p><img height="450" src="assets/part4/passthrough.svg" alt="Virtual machine with passthrough ethernet diagram" /></p>

This diagram shows two main components involved when using virtual machines on top of seL4. Obviously there is a
virtual machine (VM), but there is also a virtual machine monitor (VMM). The VMM is responsible for starting and
managing the VM for its lifetime. As the VM doesn't necessarily know it is being virtualised and thinks that it
is just running directly on hardware, it will try to perform operations such as memory read/write to regions of
memory we do not want it to. Making these kinds of restrictions is well-suited to a capability system, as we can easily control exactly
what resources the VM has power over.

In this case we *want* to give the VM access to the ethernet device, so we map the address of the device into
the VM's virtual machine. This is typically called "pass-through" because, as you can see from the diagram, the
VM bypasses both the VMM and seL4 when it accesses the device. This is ideal for performance as it means that
the VMM nor seL4 consume any CPU when the VM is accessing the device.

However, interrupts are still managed through seL4 and the VMM. The reason for this is because we do not want
the virtual machine to be able to mess with any other interrupts in the system, and most hardware architectures
(such as ARM which we are using today) leave this problem up to software.

## Integrating with the Wordle system

Our goal is to have a Linux virtual machine start that then gets the word from `{{LEARNMICROKIT_WORD_URL}}` which
it sends to the VMM for it to give to the Wordle server.

In the (development version of) Microkit it is possible to describe a VM using the `virtual_machine` element. It is
very similar to a PD in that it has its own TCB, VSpace and CSpace.

There are a few pieces in order to create a VMM and VM in the system description, so I have given the description
for you to copy-and-paste into your `wordle.system`. There are comments to help you understand all the pieces.

```xml
<!--
    This is what the virtual machine will use as its "RAM".
    Remember it does not know it is a VM and so it will expect a
    block of contigious memory as RAM.
-->
<memory_region name="guest_ram" size="0x10000000" page_size="0x200_000"
    phys_addr="0x40000000" />
<!-- Create a memory region for the ethernet device -->
<memory_region name="ethernet" size="0x1000" phys_addr="0xa003000" />
<!--
    Create a memory region for the GIC CPU interface. This is a device
    that is virtualised at the hardware-level, unlike other parts
    of the GIC.
-->
<memory_region name="gic_vcpu" size="0x1000" phys_addr="0x8040000" />

<!-- Create a VMM protection domain -->
<protection_domain name="vmm" priority="101">
    <program_image path="vmm.elf" />
    <!--
        Map in the virtual machine's RAM region as the VMM needs
        access to it as well for starting and setting up the VM.
    -->
    <map mr="guest_ram" vaddr="0x40000000" perms="rw"
        setvar_vaddr="guest_ram_vaddr" />
    <!--
        Create the virtual machine, the `id` is used for the
        VMM to refer to the VM. Similar to channels and IRQs.
    -->
    <virtual_machine name="linux" id="0" priority="100">
        <map mr="guest_ram" vaddr="0x40000000" perms="rwx" />
        <map mr="ethernet" vaddr="0xa003000" perms="rw" cached="false" />
        <map mr="uart" vaddr="0x9000000" perms="rw" cached="false" />
        <map mr="gic_vcpu" vaddr="0x8010000" perms="rw" cached="false" />
    </virtual_machine>
    <!--
        We want the VMM to receive the ethernet interrupts, which it
        will then deliver to the VM.
     -->
    <irq irq="79" id="2" trigger="edge" />
</protection_domain>
```

Next, let's try build and run the system to see Linux booting.

### Building

For building part 4, run the command:

```sh
make part4
```

### Running

The same command from the previous parts works:
```sh
make run
```

When you run the system, you will see a lot more output than the previous parts, most
of this is Linux's boot logs. At the bottom you should see the following (note that it may take a couple of seconds):
```
Starting network: OK
udhcpc: started, v1.35.0
udhcpc: broadcasting discover
udhcpc: broadcasting select for 10.0.2.15, server 10.0.2.2
udhcpc: lease of 10.0.2.15 obtained from 10.0.2.2, lease time 86400
deleting routers
adding dns 10.0.2.3
Linux user-space: Send request to trustworthy.systems/projects/microkit/tutorial/word
Linux user-space: Received word
Linux user-space: Transfer word to virtual-machine monitor
<<seL4(CPU 0) [decodeInvocation/645 T0x806000ac00 "child of: 'rootserver'" @200288]: Attempted to invoke a null cap #75.>>
```

What is happening here? Well after Linux boots it starts the initial task I have added a script that will
automatically run and get the current Wordle word and copy it to the VMM. Surprisingly, it is a very simple
script:
```bash
{{#include ../../buildroot/overlay/etc/init.d/S60Wordle}}
```

Once we have the word, we simply transfer it character-by-character to the VMM using a tool that lets us write
to a physical address (physical address from the virtual machine's point of view). Since the characters are being written to
memory that the VM does not have access to, this will cause a virtual memory fault which seL4 gives to the VMM to handle.
You will notice that this is not particularly efficient, especially if we were doing this process with large amounts of data.
Fortunately, other methods such as the virtIO standard exist. But for this tutorial, that is out of scope.

If we look at the last line of the system:
```
<<seL4(CPU 0) [decodeInvocation/645 T0x806000ac00 "child of: 'rootserver'" @200288]: Attempted to invoke a null cap #75.>>
```

What is happening is that the VMM is trying to perform a PPC to send the word to the Wordle server. However, as we do not have a
channel, we are trying to invoke a channel (and hence a capability) that does not exist! Hence the seL4 error print.

We can easily fix this by creating a channel between the VMM and the Wordle server:
```xml
<channel>
    <!-- The VMM code expects the channel ID to be 1. -->
    <end pd="vmm" id="1" />
    <end pd="wordle_server" id="2" />
</channel>
```

Finally, we need to add code in `wordle_server.c` in order to handle the PPC from the VMM. We can look at how the
VMM is transferring the word here:
```c
microkit_msginfo msg = microkit_msginfo_new(0, WORDLE_WORD_SIZE);
for (int i = 0; i < WORDLE_WORD_SIZE; i++) {
    microkit_mr_set(i, word[i]);
}
microkit_ppcall(WORDLE_SERVER_CHANNEL, msg);
```

It is simply setting each character in one of the message-registers. So in the Wordle server you can read each
message-register using `uint64_t microkit_mr_get(uint8_t mr)` to update the `word` array from being equal to "hello"
to our new word.

After doing that and re-running the system, you should see the message `Linux user-space: Transfer word to virtual-machine monitor`.
Hit the `RETURN` key then you should see the client interface printing again. You can now guess the
secret word! If you do not want to guess, you can instead print out the word in the Wordle server :).

---

[^vms]: It is not always ideal to use virtual machines. Especially when you care about
performance and reliability, having a native seL4 driver is typically better.
