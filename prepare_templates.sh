set -ex
if [ -e overlay ]
then
	rm -r overlay
fi
cp -r overlay_template overlay
cp vendor_${1}.img overlay/

if [ -e ramdisk-overlay ]
then
	rm -r ramdisk-overlay
fi
cp -r ramdisk-overlay_template ramdisk-overlay
echo ${1} > ramdisk-overlay/model

cp deviceinfo_herolte deviceinfo
