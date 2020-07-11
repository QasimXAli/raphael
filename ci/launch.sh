#!/usr/bin/env bash

set -veufo pipefail
cd "$(dirname "$0")"


apt-get install -y build-essential libssl-dev bison python3 bc curl zip flex unzip --no-install-recommends


curl -L -O https://github.com/kdrag0n/proton-clang/archive/master.zip
unzip master.zip && mv proton-clang-master/ tc/
export PATH="$(pwd)/tc/bin:$PATH"

cd ..
mkdir out

git submodule init
git submodule update

git clone https://github.com/wloot/AnyKernel2 -b raphael FLASHER
rm -rf FLASHER/.git

export KBUILD_BUILD_USER=QasimXali
export KBUILD_BUILD_HOST=Qasim
export ARCH=arm64

make O=out raphael_defconfig
make O=out CC=clang AR=llvm-ar LD=ld.lld NM=llvm-nm OBJCOPY=llvm-objcopy STRIP=llvm-strip OBJDUMP=llvm-objdump CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- -j$(nproc)

cp -f out/arch/arm64/boot/Image-dtb FLASHER/
cp -f out/arch/arm64/boot/dtbo.img FLASHER/

rel_date=$(date "+%Y%m%e-%H%M"|sed 's/[ ][ ]*/0/g')

pushd FLASHER
ZIPNAME=Candy-raphael-${rel_date}.zip
zip -r $ZIPNAME . -i *
popd

sed -i "/raphaelin/d" anykernel.sh

exit 0
