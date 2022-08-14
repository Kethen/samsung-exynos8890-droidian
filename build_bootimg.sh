set -xe
# this is a stripped down version of https://gitlab.com/ubports/porting/community-ports/halium-generic-adaptation-build-tools/-/blob/halium-11/build.sh

if ! [ -e build_dir ]
then
	mkdir build_dir
fi

source deviceinfo

if ! [ -e halium-generic-adaptation-build-tools ]
then
	git clone "https://gitlab.com/kethen/halium-generic-adaptation-build-tools.git" -b halium-11
fi

if ! [ -e aarch64-linux-android-4.9 ]
then
	git clone "https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9" -b pie-gsi --depth 1
fi

GCC_PATH=$(realpath aarch64-linux-android-4.9)

if ! [ -e arm-linux-androideabi-4.9 ]
then
	git clone "https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9" -b pie-gsi --depth 1
fi

GCC_ARM32_PATH=$(realpath arm-linux-androideabi-4.9)

KERNEL_DIR=$(basename "${deviceinfo_kernel_source}")
KERNEL_DIR="${KERNEL_DIR%.*}"
if ! [ -e "$KERNEL_DIR" ]
then
	git clone "$deviceinfo_kernel_source" -b $deviceinfo_kernel_source_branch --depth 1
fi
if ! [ -e "build_dir/${KERNEL_DIR}" ]
then
	ln -s "$(realpath $KERNEL_DIR)" "build_dir/${KERNEL_DIR}"
fi

if ! [ -e build_dir/halium-boot-ramdisk.img ]
then
	wget "https://github.com/Halium/initramfs-tools-halium/releases/download/dynparts/initrd.img-touch-arm64" -O build_dir/halium-boot-ramdisk.img
fi

HERE=$(pwd) PATH="$GCC_PATH/bin:$GCC_ARM32_PATH/bin:${PATH}" halium-generic-adaptation-build-tools/build-kernel.sh "$(realpath build_dir)" ""

PATH="$(realpath mkbootimg_modified):${PATH}" halium-generic-adaptation-build-tools/make-bootimage.sh "$(realpath build_dir)" "$(realpath build_dir)/KERNEL_OBJ" "$(realpath build_dir/halium-boot-ramdisk.img)" "$(realpath build_dir)/boot.img"
