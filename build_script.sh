#!/bin/bash

# Init
KERNEL_DIR="${PWD}"
cd "$KERNEL_DIR" || exit
DTB_TYPE="" # define as "single" if want use single file
KERN_IMG="${KERNEL_DIR}"/out/arch/arm64/boot/Image.gz # if use single file define as Image.gz-dtb instead
KERN_DTBO="${KERNEL_DIR}"/out/arch/arm64/boot/dtbo.img # and comment this variable
KERN_DTB="${KERNEL_DIR}"/out/arch/arm64/boot/dtb.img
ANYKERNEL="/root/kernel/AnyKernel3"

# Repo URL
ANYKERNEL_REPO="https://github.com/TheStrechh/AnyKernel3"
ANYKERNEL_BRANCH="silont"

# Compiler
COMP_TYPE="clang"
CLANG_DIR="/root/kernel/tc/clang"
GCC_DIR="/root/kernel/tc/aarch64-linux-android-4.9"
GCC32_DIR="/root/kernel/tc/arm-linux-androideabi-4.9"

if [[ "${COMP_TYPE}" =~ "clang" ]]; then
    CSTRING=$("$CLANG_DIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
    COMP_PATH="$CLANG_DIR/bin:${PATH}"
else
    COMP_PATH="${GCC_DIR}/bin:${GCC32_DIR}/bin:${PATH}"
fi

# Defconfig
DEFCONFIG="surya_defconfig"

# Versioning
versioning() {
    DEF=$(cat arch/arm64/configs/${DEFCONFIG} | grep CONFIG_LOCALVERSION= | sed "s/-SiLonT-//g" | sed 's/"//g' | sed "s/CONFIG_LOCALVERSION/KERNELTYPE/g")
    export $DEF
}

# Costumize
versioning
KERNEL="SiLonT"
DEVICE="Surya"
KERNELNAME="${KERNEL}-${DEVICE}-$(date +%y%m%d-%H%M)"
TEMPZIPNAME="${KERNELNAME}-unsigned.zip"
ZIPNAME="${KERNELNAME}.zip"

# Build Failed
build_failed() {
	    END=$(date +"%s")
	    DIFF=$(( END - START ))
	    echo -e "Kernel compilation failed, See buildlog to fix errors"
	    exit 1
}

# Building
makekernel() {
    echo "Charly@xda-developers" > "$KERNEL_DIR"/.builderdata
    export PATH="${COMP_PATH}"
    make O=out ARCH=arm64 ${DEFCONFIG}
    if [[ "${COMP_TYPE}" =~ "clang" ]]; then
        make -j$(nproc --all) CC=clang CROSS_COMPILE=aarch64-linux-gnu- O=out ARCH=arm64 LLVM=1 2>&1 | tee "$LOGS"
    else
      	make -j$(nproc --all) O=out ARCH=arm64 CROSS_COMPILE="${GCC_DIR}/bin/aarch64-elf-"
    fi
    # Check If compilation is success
    packingkernel
}

# Packing kranul
packingkernel() {
    # Copy compiled kernel
    if [ -d "${ANYKERNEL}" ]; then
        rm -rf "${ANYKERNEL}"
    fi
    git clone "$ANYKERNEL_REPO" -b "$ANYKERNEL_BRANCH" "${ANYKERNEL}"
    if ! [ -f "${KERN_IMG}" ]; then
        build_failed
    fi
    if ! [ -f "${KERN_DTBO}" ]; then
        build_failed
    fi
    if [[ "${DTB_TYPE}" =~ "single" ]]; then
        cp "${KERN_IMG}" "${ANYKERNEL}"/Image.gz-dtb
    else
        cp "${KERN_IMG}" "${ANYKERNEL}"/Image.gz
        cp "${KERN_DTBO}" "${ANYKERNEL}"/dtbo.img
        cp "${KERN_DTB}" "${ANYKERNEL}"/dtb.img
    fi

    # Zip the kernel, or fail
    cd "${ANYKERNEL}" || exit
    zip -r9 "${TEMPZIPNAME}" ./*

    END=$(date +"%s")
    DIFF=$(( END - START ))
}

# Starting
NOW=$(date +%d/%m/%Y-%H:%M)
START=$(date +"%s")
makekernel
