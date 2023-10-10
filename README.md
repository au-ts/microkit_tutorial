# A tutorial for the seL4 Microkit

The [seL4 Microkit](https://github.com/seL4/Microkit) is a
minimal operating system framework made for developing systems using the seL4
microkernel.

The tutorial is available [here](https://trustworthy.systems/projects/microkit/tutorial).

This repository contains the infrastructure and material for the tutorial. If
you are developing the tutorial itself, the rest of the README is for you.

## Tutorial website

The tutorial is delivered using [mdBook](https://rust-lang.github.io/mdBook/),
a fairly accessible way for making small online guides, books and tutorials
using Markdown.

### Working on the tutorial website

#### Install mdBook

Install the mdBook tool and `mdbook-variables` preprocessor using
[Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html).

```sh
cargo install --locked mdbook-variables mdbook
```

#### Developing and making changes to the website

The source for the website is under `website/src/`.

To start a local webserver to serve the website, run the following:

```sh
cd website
./develop.sh
```

#### Building the website for deployment

To build the website run:
```sh
cd website
./build.sh
```

The built website will be in `website/build/`.

## Tutorial code and solutions

All the tutorial code is under `tutorial/` in the repository.

All the solutions code is under `solutions/` in the repository.

## Word dictionary

In part 4 of the tutorial, there is a random word available at the given URL.
The dictionary where the random word is chosen from is in `dictionary.txt` at
the root of the repository.
