# Welcome

Welcome to the tutorial for the seL4 Microkit (formerly called the seL4 Core Platform).

To complete this tutorial, you will need:
* A laptop or computer with access to the internet.
* Some familiarity with operating systems concepts and the C programming language.

## Getting started

In this tutorial, you will be completing multiple exercises to end up with a system that
implements the [Wordle game](https://www.nytimes.com/games/wordle/index.html). If you are
not familiar with Wordle, it is a simple word guessing game. Through implementing the game,
you will see how systems are constructed on seL4 using Microkit. This Wordle system, while
largely a toy, does represent a realistic architecture as there is:
* a driver (to allow the user to input)
* a trusted server (which has the secret word)
* a untrusted client (which guesses what the word is based on user input)

All of these are isolated components that then communicate via seL4 and Microkit.

But, before we can start the actual tutorial, you will have to go to [part 0 to set up your machine](./part0.md).

## License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" /></a><br />This work is created by Ivan Velickovic and licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
