# Part 2 - Client

Now that we have a serial server working, our next goal will be to have a client PD that serves a command-line interface to play Wordle. For this we want to have a way for the client to retrieve characters from the serial server. A relatively simple way to do this is to share a buffer and have the serial server notify the client that there's a new character to read. We also want the client to be able to send characters for the serial server
to output to the terminal. By the end of this part, we will have something like the following:

<p><img height="350" src="assets/part2/overview.svg" alt="Serial server and client overview" /></p>

<!-- [^1]: While it would be easier to just IPC five characters at a time, since the server has higher priority than the client, doing a protected procedure (same concept as IPC which will be explained later), is restricted in Microkit. See <a href="https://github.com/seL4/microkit/blob/main/docs/manual.md#protected-procedure-priorities" target="_blank">this section</a> in the manual for details. -->

Your first task is to:
* Add a PD for the client to the system description. The name of the client's program image is `client.elf`.
    * Note that, as mentioned in part 1, the client should have a lower priority than the serial server.

### Building

For building part 2, run the command:

```sh
make part2
```

### Running

The same command from part 1 works:
```sh
make run
```

You should get the following output, indicating that the client has been successfully started:
```
SERIAL SERVER: starting
CLIENT: starting
```

The next step is to get the client and serial server communicating.

## Channels

A channel allows two protection domains to interact with each other, either via notifications which are asynchronous and bidirectional, or, protected procedures which are synchronous and unidirectional. In this part of the tutorial, you'll be using notifications (protected procedures will be covered later).

When a channel is created between two PDs, a channel identifier is configured for each PD. The channel identifier is used by the PD to reference the channel. Each PD can refer to the channel with a different identifier. For example if PDs A and B are connected by a channel, A may refer to the channel using an identifier of 37 while B may use 42 to refer to the same channel.

The `channel` element has exactly two `end` children elements for specifying the two PDs associated with the channel.

The `end` element has the following attributes:

* `pd`: Name of the protection domain for this end.
* `id`: Channel identifier in the context of the named protection domain. Must be at least 0 and less than 63.
* `pp`: (optional) Indicates that the protection domain for this end can perform a protected procedure call to the other end; defaults to false.
        Protected procedure calls can only be to PDs of strictly higher priority.
* `notify`: (optional) Indicates that the protection domain for this end can send a notification to the other end; defaults to true.


### Example

Here is a basic example of two PDs using a channel to notify each other.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<system>
    <protection_domain name="sender">
        <program_image path="sender.elf" />
    </protection_domain>
    <protection_domain name="receiver">
        <program_image path="receiver.elf" />
    </protection_domain>

    <channel>
        <end pd="sender" id="1" />
        <end pd="receiver" id="2" />
    </channel>
</system>
```

The sender's code might look something like this:
```c
#include <microkit.h>

#define RECEIVER_CHANNEL_ID 1

void init() {
    // Send a message to the receiver
    microkit_notify(RECEIVER_CHANNEL_ID);
}
```

The receiver's code might look something like this:
```c
#include <microkit.h>

#define SENDER_CHANNEL_ID 2

void notified(microkit_channel ch) {
    // Receive a message from the sender
    switch (ch) {
        case SENDER_CHANNEL_ID:
            microkit_dbg_puts("Received message from sender!\n");
    }
}

void init() {}
```

Notice that the IDs of the channel are local to the PD. The sender refers to the channel with `2` but the receiver refers to the same channel with `1`.

Your task now is to:
* Add the channel to the system description.
* You can make sure you have added the channel correctly by printing a message when the client gets notified from the serial server.
    * You can use either `microkit_dbg_puts` to print out a string or use `printf` for formatted strings. `printf` is just using `microkit_dbg_puts`
      behind the scenes anyways, but will be more convenient if you have to debug etc.

### Shared buffer

Now that we can communicate between the client and serial server, the serial server has the ability to let the client know that it has received input. Since we cannot pass data via notifications, we will use a shared buffer, placing each new character in the buffer and subsequently notifying the client.

#### Example

If we wanted to have two PDs that share a buffer to avoid costly IPC to send data between the PDs, my system description might look something like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<system>
    <!--
        Define a page sized buffer to share between the "sender" and "receiver"
        protection domains.
    -->
    <memory_region name="shared_buffer" size="0x1000" />

    <protection_domain name="sender">
        <program_image path="sender.elf" />
        <!--
            Map the buffer into the address space of "sender", which only
            writes to it. The Microkit tool will do ELF symbol patching to set
            the virtual address of the mapping to a global variable called
            "buffer". The region is mapped as read-write as write-only mappings
            are not permitted by seL4 (at least on AArch64).
        -->
        <map mr="shared_buffer" vaddr="0x4000000" perms="rw" setvar_vaddr="buffer"/>
    </protection_domain>
    <protection_domain name="receiver">
        <program_image path="receiver.elf" />
        <!--
            Map the buffer into the address space of "receiver", which only
            reads from it. The Microkit tool will do ELF symbol patching to set
            the virtual address of the mapping to a global variable called
            "buffer".
        -->
        <map mr="shared_buffer" vaddr="0x4000000" perms="r" setvar_vaddr="buffer"/>
    </protection_domain>
</system>
```

<details><summary>Reference for memory region and map elements</summary>

`memory_region`:
* `name`: A unique name for the memory region
* `size`: Size of the memory region in bytes (must be a multiple of the page size)
* `page_size`: (optional) Size of the pages used in the memory region; must be a supported page size if provided. Defaults to the largest page size for the target architecture that the memory region is aligned to.
* `phys_addr`: (optional) The physical address for the start of the memory region (must be a multiple of the page size).

`map`:
* `mr`: Identifies the memory region to map.
* `vaddr`: Identifies the virtual address at which to map the memory region to.
* `perms`: Identifies the permissions with which to map the memory region with. Can be any combination of r (read), w (write), and x (eXecute).
* `cached`: Determines if region is mapped with caching enabled or disabled. Defaults to true.
* `setvar_vaddr`: Specifies a symbol in the program image. This symbol will be rewritten with the virtual address of the memory region.
</details>

Your task now is to:
* Create two shared buffers between the client and server. One buffer should handle user input, the other should handle output in order to display the game state.
* Be able to print out the characters received from the serial server in the client.
* Implement the `serial_send` function in the client to print out the game's interface.

Ultimately, you want to be able to get some output like this:
```
SERIAL SERVER: starting
CLIENT: starting
Welcome to the Wordle client!
[h] [e] [l] [l] [o]
[t] [h] [e] [r] [e]
[ ] [ ] [ ] [ ] [ ]
[ ] [ ] [ ] [ ] [ ]
[ ] [ ] [ ] [ ] [ ]
```

Pressing `ENTER` (`\r`) should move to the next line if they've entered enough characters. Similarly, you should be able to delete a character by pressing `BACKSPACE`.

Once you have that working, we can implement the Wordle server to get it to check whether we have a correct guess.
