fetch_rootfs () {
	#wget 'https://github.com/droidian-images/droidian/releases/download/droidian%2Fbookworm%2F24/droidian-OFFICIAL-phosh-phone-rootfs-api30-arm64-24_20220804.zip' -O /tmp/droidian.zip
	wget 'https://github.com/droidian-images/droidian/releases/download/nightly/droidian-OFFICIAL-phosh-phone-rootfs-api30-arm64-nightly_20220815.zip' -O /tmp/droidian.zip
	unzip -p /tmp/droidian.zip data/rootfs.img > build_dir/rootfs.img
	rm /tmp/droidian.zip
}

fetch_halium () {
	wget 'https://ci.ubports.com/job/UBportsCommunityPortsJenkinsCI/job/ubports%252Fporting%252Fcommunity-ports%252Fjenkins-ci%252Fgeneric_arm64/job/halium-11.0/lastSuccessfulBuild/artifact/halium_halium_arm64.tar.xz' -O - | xz -d | tar -x system/var/lib/lxc/android/android-rootfs.img
	mv system/var/lib/lxc/android/android-rootfs.img build_dir/android-rootfs.img
	rm -r system
}

update_halium () {
	if ! [ -e build_dir/mnt ]
	then
		mkdir build_dir/mnt
	fi
	sudo mount build_dir/rootfs.img build_dir/mnt
	sudo cp build_dir/android-rootfs.img build_dir/mnt/var/lib/lxc/android/android-rootfs.img
	sudo umount build_dir/mnt
}

apply_overlay () {
	if ! [ -e build_dir/mnt ]
	then
		mkdir build_dir/mnt
	fi
	sudo mount build_dir/rootfs.img build_dir/mnt
	sudo cp -r overlay/. build_dir/mnt/
	sudo umount build_dir/mnt
}

set -xe

if ! [ -e build_dir/rootfs.img ]
then
	fetch_rootfs
fi
if ! [ -e build_dir/android-rootfs.img ]
then
	fetch_halium
fi
update_halium
apply_overlay
