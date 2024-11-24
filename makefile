.PHONY: all raspi-rt-kernel-build clean prebuild

all: clean prebuild raspi-rt-kernel-build

prebuild:
	mkdir -p build

raspi-rt-kernel-build:
	docker build -t raspi-image-builder .
	docker run --privileged --name rpi-builder raspi-image-builder /raspios/builder.sh
	docker cp rpi-builder:/raspios/image.xz ./build/image.xz
	docker rm rpi-builder

clean:
	rm -f ./build/image.xz
