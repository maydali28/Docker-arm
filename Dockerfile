#the first thing we need to do is define from what image we want to build from. 
#Here we will use a 14.04 LTS(long term support) version of ubuntu from docker Hub :
FROM ubuntu:14.04

MAINTAINER Mohamed Ali May "https://github.com/maydali28"

ARG DEBIAN_FRONTEND=noninteractive

RUN mv /etc/apt/sources.list /etc/apt/sources.list.old
RUN echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse' >> /etc/apt/sources.list
RUN apt-get update -q
#install software requirements
RUN apt-get install --no-install-recommends -y software-properties-common build-essential git symlinks expect

# Install build dependancies
RUN apt-get purge binutils-arm-none-eabi \
                   gcc-arm-none-eabi \
                   gdb-arm-none-eabi \
                   libnewlib-arm-none-eabi
RUN add-apt-repository -y ppa:team-gcc-arm-embedded/ppa
RUN apt-get update -q
RUN apt-cache policy gcc-arm-none-eabi
RUN apt-get install --no-install-recommends -y gcc-arm-embedded

#install Debugging dependancies
#install OPENOCD Build dependancies and gdb
RUN apt-get install --no-install-recommends -y \
  		libhidapi-hidraw0 \
  		libusb-0.1-4 \
  		libusb-1.0-0 \
  		libhidapi-dev \
      libusb-1.0-0-dev \
  		libusb-dev \
  		libtool \
  		make \
  		automake \
  		pkg-config \
      autoconf \
        texinfo
#build and install OPENOCD from repository
RUN cd /usr/src/ \
    && git clone --depth 1 https://github.com/ntfreak/openocd.git \
    && cd openocd \
    && ./bootstrap \
    && ./configure --enable-stlink --enable-jlink --enable-ftdi --enable-cmsis-dap \
    && make -j"$(nproc)" \
    && make install 
#remove unneeded directories
RUN cd ..
RUN rm -rf /usr/src/openocd \
    && rm -rf /var/lib/apt/lists/*
#OpenOCD talks to the chip through USB, so we need grant our account access to the FTDI. 
RUN cp /usr/local/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d/60-openocd.rules

#create a directory for our project & setup a shared workfolder between the host and docker container
RUN mkdir -p /usr/src/app
VOLUME ["/usr/src/app"]
WORKDIR /usr/src/app
RUN cd /usr/src/app

EXPOSE 4444
