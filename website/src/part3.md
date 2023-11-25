# Part 3 - Wordle server

This part involves hooking up the client with a Wordle server PD. The Wordle server will accept attempted guesses of what the word is from the client, and will reply with what characters in the word were correct, incorrect, or correct but in the wrong position. At the end of this exercise, you should have a playable Wordle!

As mentioned in the previous part, there are two operations you can do using a channel, so far we have used notifications to asynchronously signal a PD that an event has occurred. With the Wordle server however, we want the semantics that the client requests the server to check the word that has been entered by the player, and returns a response with: what characters were correct, what characters were correct but in the wrong place, and what characters were incorrect.

To do this, we will use a synchronous method of communication, where the client will be blocked and waiting on the Wordle server for a response on each request.

<p><img height="300" src="assets/part3/overview.svg" alt="Client and wordle server overview" /></p>

## Protected Procedure Calls (PPC)

A protection domain may provide a protected procedure (PP) which can be invoked from another protection domain. Up to 64 words of data may be passed as arguments when calling a protected procedure. The protected procedure return value may also be up to 64 words.

When a protection domain calls a protected procedure, the procedure executes within the context of the providing protection domain.

A protected procedure call is only possible if the callee has strictly higher priority than the caller. This means that if A has a priority of 1 and B has a priority of 254, A can invoke B's protected procedure, but B cannot invoke A's protected procedure. Transitive calls are possible, and as such a PD may call a protected procedure in another PD from a protected entry point. However the overall call graph between PDs forms a directed, acyclic graph. It follows that a PD can not call itself, even indirectly. For example, A calls B calls C is valid (subject to the priority constraint), while A calls B calls A is not valid.

When a protection domain is called, the protected entry point is invoked. The control returns to the caller when the protected entry point returns.

The caller is blocked until the callee returns. Protected procedures must execute in bounded time. Currently, the caller must trust the callee to conform.

To call a PP, a PD calls `microkit_ppcall` passing the channel identifier and a message structure, a message structure is returned from this function.
* To create a message structure, you can use `microkit_msginfo microkit_msginfo_new(uint64_t label, uint16_t count)`. The `label` is typically used for distinguishing PPCs when there are multiple services from the same client to the same server. In this tutorial it will not be necessary to use the `label` and it can just be 0. The `count` will be used and it represents how many arguments (message-registers) are in the PPC.
* To set the arguments of a message (message registers), you can use `void microkit_mr_set(uint8_t mr, uint64_t value)` where `mr` is the index.
* To get arguments from the returned message, you can use `uint64_t microkit_mr_get(uint8_t mr)` where `mr` is the index.
* To get the label of a message, you can use `uint64_t microkit_msginfo_get_label(microkit_msginfo msginfo);`.

When a PD's protected procedure is invoked, the protected entry point is invoked with the channel identifier and message structure passed as arguments. The protected entry point must return a message structure.

Your task now is to:
* Add a Wordle server PD (using the program image `wordle_server.elf`).
* Add the ability to invoke the Wordle server's protected procedure from the client. This means creating a channel between the two PDs and setting `pp="true"` on the Wordle server's `protection_domain` element.
* On the client side, implement `wordle_server_send` to send the user-inputted word from the client to the Wordle server.
    * Do this using message registers by setting each character of the word from the client to the Wordle server.
* On the Wordle server side, implement the protected entry point `microkit_msginfo protected(microkit_channel ch, microkit_msginfo msginfo)`.
    * Use the helper functions in `wordle_server.c` to put the state of each character in the same message-register that the character
      was delivered in.

### Building

For building part 3, run the command:

```sh
make part3
```

### Running

The same command from the previous parts works:
```sh
make run
```

Hopefully now you have the table printing with colour output (orange for correct letter wrong position, red for incorrect letter) and are
able to guess the word! If all the letters are green, then you have won.
