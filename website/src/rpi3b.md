# Instructions for Raspberry Pi 3 Model B+

These instructions have been adapted (and hopefully simplified) from <a href="https://docs.sel4.systems/Hardware/Rpi3.html" target="_blank">here</a>.

## Flashing microSD card

The first step is to get your microSD card into the right format, FAT32.

Note that the board will boot from the *first* FAT32 partition.

## Booting

I have packaged up all the required binaries in order to get booting into U-Boot, which have been tested and are known to work.

Download and extract the binaries to your microSD card with the following commands:
```sh
curl -L {{TUTORIAL_DOWNLOADS_URL}}/rpi3b.tar.gz -o rpi3b.tar.gz
tar xvf rpi3b.tar.gz --directory /path/to/sdcard
```

Also included is a boot script (`boot.scr`) which has the commands for loading the image from the microSD card into RAM and starting execution of the loaded system. This means that once you turn on your board, the system should automatically load and start.

## Testing

To test that the setup works, we will run a simple "hello world" program.

### Building

```sh
# Inside the "microkit_workshop" directory from Part 0 setup
mkdir hello_world_build
make -C microkit_workshop_sdk/board/qemu_arm_virt/example/hello/ BUILD_DIR=$(pwd)/hello_world_build SEL4CP_SDK=$(pwd)/microkit_workshop_sdk SEL4CP_BOARD=rpi3b SEL4CP_CONFIG=debug
```

Next, you'll want to copy the built image to the microSD card you are using.
```sh
cp hello_world_build/loader.img /path/to/sdcard
```

### Running

First disconnect the microSD card from your computer and insert it into the Raspberry Pi. Then, you'll want to hook up the board's UART to your computer so you can receive and transmit characters from/to the UART. Transmit (TX) is at GPIO pin 14 and receive (RX) is at GPIO pin 15, as you can see below:

![Raspberry Pi 3 Model B+](assets/rpi3_gpio.png)

Now that you have the hardware hooked up, before powering on the board, you need to connect the serial to your computer. One way that is available on UNIX systems is via the `screen` program. It takes in the path to the serial device and a baud rate (which in this case is 115200). The path to the serial device depends on the device itself, an example of the command is below:

```sh
screen /dev/ttyUSB0 115200
```

Finally, you can plug in the micro USB cable for power and should see U-Boot start the system image, finally outputting "hello, world".

<!-- ## Creating a boot script

For convenience, you may want to have a U-Boot boot script to avoid having to manually load and boot the image on every change. In a file called `boot.txt`:
```
fatload mmc 0 0x10000000 loader.img
go 0x10000000
```

Then, to create the script, run the following command:
```sh
mkimage -A arm -O linux -T script -C none -n boot.scr -d boot.txt boot.scr
```

`mkimage` is apart of the Docker container already. If you aren't using Docker, you will need to install it on your machine. Using `apt` this would be done with `sudo apt-get install u-boot-tools`.

Finally, copy the generated `boot.scr` to the microSD card. -->

<!-- ## Troubleshooting

If the instructions are not working for you, and for some reason you cannot get U-Boot to run or the seL4CP hello world, I would suggest to first try get Linux booting and running to check that you have the serial working. The easiest way of doing this is probably to download the [Raspberry Pi Image](https://github.com/raspberrypi/rpi-imager). When you start it, select "Operating System" then Raspberry Pi OS (other)" then "Raspberry Pi OS (64-bit)". After flashing your microSD card, edit `config.txt` and add the line `enable_uart=1`. Hopefully, booting your Pi with the microSD should now automatically boot into Linux. TODO, if it does work/if it doesn't work.n
 -->