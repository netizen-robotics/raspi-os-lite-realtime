#!/bin/sh

RASPIOS=/raspios/2024-11-19-raspios-bookworm-arm64-lite.img
OUTPUT=$(sfdisk -lJ ${RASPIOS})
BOOT_START=$(echo $OUTPUT | jq -r '.partitiontable.partitions[0].start')
BOOT_SIZE=$(echo $OUTPUT | jq -r '.partitiontable.partitions[0].size')
EXT4_START=$(echo $OUTPUT | jq -r '.partitiontable.partitions[1].start')

mkdir /raspios/mnt
mkdir /raspios/mnt/boot
mkdir /raspios/mnt/root

mount -t ext4 -o loop,offset=$(($EXT4_START * 512)) ${RASPIOS} /raspios/mnt/root
mount -t vfat -o loop,offset=$(($BOOT_START * 512)),sizelimit=$(($BOOT_SIZE * 512)) ${RASPIOS} /raspios/mnt/boot

# Kernel Setup

cd /raspi-kernel/linux/

make -j6 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/raspios/mnt/root modules_install

cp /raspios/mnt/boot/$KERNEL.img /raspios/mnt/boot/$KERNEL-backup.img
cp /raspi-kernel/linux/arch/arm64/boot/Image /raspios/mnt/boot/$KERNEL.img
cp /raspi-kernel/linux/arch/arm64/boot/dts/broadcom/*.dtb /raspios/mnt/boot
cp /raspi-kernel/linux/arch/arm64/boot/dts/overlays/*.dtb* /raspios/mnt/boot/overlays/
cp /raspi-kernel/linux/arch/arm64/boot/dts/overlays/README /raspios/mnt/boot/overlays/

umount /raspios/mnt/root
umount /raspios/mnt/boot

cd /raspios
xz -z -9 -e -T0 -c ${RASPIOS} > image.xz
