# Docker-arm

This repository contains source code for the article

Contents:

1.Dockerfile 

2.example of blink led Project for STM32F4 Discovery with it's libraries

## How to setup The environment :

```
cd ~
sudo apt-get install git 
git clone https://github.com/maydali28/Docker-arm/
cd ~/Docker-arm
```

## Usage :

#### Build the image :

```
cd ~/Docker-arm
docker build -t docker-arm .
```

#### run the container :

```
cd ~/Docker-arm
docker run -it --name docker-arm -p 4444:4444 -v "$(pwd)/app":/usr/src/app --privileged -v /dev/bus/usb:/dev/bus/usb docker-arm /bin/bash
```

#### build existing Project :

see more steps in https://github.com/rowol/stm32_discovery_arm_gcc/blob/master/README.md
```
cd /usr/src/app
cd blinky
make
```

### flash code into the board:

openocd -s "/usr/local/share/openocd/scripts" -f "interface/stlink-v2.cfg" -f "target/stm32f4x.cfg" -c "main main.elf verify reset exit"

#### debugging existing project

Run Openocd as GDB server 
```
openocd -c ""gdb_port 4444" -s "/usr/local/share/openocd/scripts" -f "interface/stlink-v2.cfg" -f "target/stm32f4x.cfg"

```
Open another terminal and run
```
docker exec -it docker-arm /bin/bash
arm-none-eabi-gdb blinky.elf
gdb) target remote localhost:4444
gdb) load
```
