# Part 0 - Setting up your environment

<!-- This page outlines how to set up your environment for completing the workshop and how to test that you've done so correctly. The workshop exercises are setup to run on a simulator as well as a limited number of hardware platforms. All the exercises can be completed on both simulator and the supported hardware. If you would like to complete the workshop on hardware, see [this page](hardware.md). -->

This page covers two things:
1. Acquiring the Microkit SDK and the other dependencies needed for the tutorial.
2. Acquiring the tutorial code, so you can complete the exercises.

If you have any issues, feel free to open an issue on [the GitHub repository](https://github.com/au-ts/microkit_tutorial).

## Acquiring the dependencies
We have two options for working on the tutorial:

1. Install dependencies and do the tutorial natively, however this option is only available if you are doing the tutorial on Linux, macOS or Nix.
2. If you prefer to use Docker, you can follow the instructions for Docker.

### Option 1 - Linux, macOS, Nix

You'll need the following dependencies:
* Make
* AAarch64 cross compiler
* QEMU simulator for running the tutorial
* The Microkit SDK

{{#tabs }}
{{#tab name="Linux" }}

Follow these instructions depending on your machine's architecture to get
the Microkit SDK.

{{#tabs }}
{{#tab name="x86-64" }}


```sh
# First make a directory for the tutorial
mkdir microkit_tutorial
cd microkit_tutorial
# Then download and extract the SDK
curl -L https://github.com/seL4/microkit/releases/download/{{MICROKIT_VERSION}}/microkit-sdk-{{MICROKIT_VERSION}}-linux-x86-64.tar.gz -o sdk.tar.gz
tar xf sdk.tar.gz
```
{{#endtab}}

{{#tab name="AArch64" }}
```sh
# First make a directory for the tutorial
mkdir microkit_tutorial
cd microkit_tutorial
# Then download and extract the SDK
curl -L https://github.com/seL4/microkit/releases/download/{{MICROKIT_VERSION}}/microkit-sdk-{{MICROKIT_VERSION}}-linux-aarch64.tar.gz -o sdk.tar.gz
tar xf sdk.tar.gz
```
{{#endtab}}
{{#endtabs}}

Follow these instructions to get the tutorial's dependencies depending
on your Linux distribution.

{{#tabs }}
{{#tab name="Ubuntu/Debian" }}
```sh
sudo apt update && sudo apt install -y make gcc-aarch64-linux-gnu qemu-system-arm
```
{{#endtab}}
{{#tab name="Arch" }}
```sh
sudo pacman -Sy make aarch64-linux-gnu-gcc qemu-system-aarch64
```
{{#endtab}}
{{#tab name="Fedora" }}
```sh
sudo dnf install -y make qemu gcc-aarch64-linux-gnu
```
{{#endtab}}
{{#endtabs}}

{{#endtab }}
{{#tab name="macOS" }}

Follow these instructions depending on your what kind of Mac you have
to get the Microkit SDK.

{{#tabs }}
{{#tab name="Apple Silicon (ARM64)" }}
```sh
# First make a directory for the tutorial
mkdir microkit_tutorial
cd microkit_tutorial
# Then download and extract the SDK
curl -L https://github.com/seL4/microkit/releases/download/{{MICROKIT_VERSION}}/microkit-sdk-{{MICROKIT_VERSION}}-macos-aarch64.tar.gz -o sdk.tar.gz
tar xf sdk.tar.gz
```
{{#endtab }}
{{#tab name="Intel (x86-64)" }}
```sh
# First make a directory for the tutorial
mkdir microkit_tutorial
cd microkit_tutorial
# Then download and extract the SDK
curl -L https://github.com/seL4/microkit/releases/download/{{MICROKIT_VERSION}}/microkit-sdk-{{MICROKIT_VERSION}}-macos-x86-64.tar.gz -o sdk.tar.gz
tar xf sdk.tar.gz
```
{{#endtab }}
{{#endtabs }}

You can install the tutorial's dependencies using [Homebrew](https://brew.sh/):

```sh
brew tap messense/macos-cross-toolchains
brew install make qemu aarch64-unknown-linux-gnu
```

{{#endtab }}
{{#tab name="Nix" }}

The development shell will give you all the depenencies you need:
```sh
mkdir microkit_tutorial
cd microkit_tutorial
nix develop 'github:au-ts/microkit_tutorial'
```
Note you will still have download the tutorial code from below.

{{#endtab }}
{{#endtabs }}

### Option 2 - Docker

seL4 provides an official Docker container which has the necessary dependencies for this tutorial.
You can find instructions for acquring it [here](https://docs.sel4.systems/projects/dockerfiles/).

After setting up the Docker container, run the following commands outside Docker:
```sh
# First make a directory for the tutorial
mkdir microkit_tutorial
cd microkit_tutorial
# Then start the Docker container
container
# Then download and extract the SDK
curl -L https://github.com/seL4/microkit/releases/download/{{MICROKIT_VERSION}}/microkit-sdk-{{MICROKIT_VERSION}}-linux-x86-64.tar.gz -o sdk.tar.gz
tar xf sdk.tar.gz
```

This Docker image is mounted on your host file system. What that means is that the `microkit_tutorial` directory is
accessible from both Docker and from your normal environment.

Run all the commands for downloading the tutorial code and building/running the tutorial in the container. You can
then open the `microkit_tutorial` directory in your code editor for viewing/editing the tutorial code.

<!--
## Hardware

I expect the majority of people to be doing the workshop via a simulator. However, everyone is welcome to bring their own machine to do the workshop on. If you have done so, I have instructions for the following boards:
- Raspberry Pi Model 3B+
- Raspberry Pi Model 4
-->

## Getting the tutorial code

```sh
# Download and extract the tutorial code (in the microkit_tutorial directory)
curl -L {{TUTORIAL_DOWNLOADS_URL}}/tutorial.tar.gz -o tutorial.tar.gz
tar xf tutorial.tar.gz
```

Now you can move on to [part 1 of the tutorial](./part1.md).
