FROM ubuntu:24.04

ARG BRANCH=stable_20240529

RUN apt update
RUN apt install -y git make bc bison flex libssl-dev make libc6-dev libncurses5-dev wget crossbuild-essential-arm64 jq fdisk kmod
 
WORKDIR /raspi-kernel
RUN git clone --depth=1 --branch ${BRANCH} https://github.com/raspberrypi/linux

ENV KERNEL=kernel_2712
WORKDIR /raspi-kernel/linux
RUN make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig

RUN wget https://www.kernel.org/pub/linux/kernel/projects/rt/6.6/older/patch-6.6.31-rt31.patch.gz
RUN gunzip patch-6.6.31-rt31.patch.gz
RUN cat patch-6.6.31-rt31.patch | patch -p1

RUN ./scripts/config --enable CONFIG_PREEMPT_RT

RUN make -j12 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs

WORKDIR /raspios
RUN wget https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-11-19/2024-11-19-raspios-bookworm-arm64-lite.img.xz
RUN xz -d 2024-11-19-raspios-bookworm-arm64-lite.img.xz

ADD builder.sh ./builder.sh
