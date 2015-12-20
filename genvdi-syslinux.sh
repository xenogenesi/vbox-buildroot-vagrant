#!/bin/sh -e

# tested only with debian/unstable

# host dependencies:
# kpartx syslinux dosfstools mtools
# (probably already installed) e2fsprogs util-linux coreutils mount

buildroot=$HOME/src/buildroot-2015.11.1

image_raw=/tmp/test.raw
output_vdi=/tmp/test.vdi
ext4_mountp=/tmp/ext4
vfat_start=2048
vfat_start_in_mega=1M
syslinux_cfg=/tmp/syslinux.cfg

mkdir -p ${ext4_mountp}

# terminate some status
sudo losetup -d /dev/loop0 2>/dev/null || true
sudo umount ${ext4_mountp} 2>/dev/null || true
sudo kpartx -d ${image_raw} 2>/dev/null || true
rm -f ${output_vdi} 2>/dev/null || true

# create image container
dd if=/dev/zero of=${image_raw} bs=1M count=150
#dd if=/dev/zero of=${image_raw} bs=1M count=600

# create two partitions:
# 1) few mega "W95 Fat" for syslinux and bzImage
# 2) all the remaining "ext4" for the rootfs
# credit: http://superuser.com/a/984637/241894
sed -e 's/\t\([\+0-9a-zA-Z]*\)[ \t].*/\1/' <<EOF | /sbin/fdisk ${image_raw}
	n # new
	p # primary
	1 # 1st
	${vfat_start} # first sector
	+5M # last +4M
	a # enable bootable
	t # change type
	b # w95 fat
	n # new
	p # primary
	2 # 2nd
	  # default first sector
	  # default last sector
	w # write and quit
EOF

# *bind* loop devices to /dev/mapper
sudo kpartx -a ${image_raw}
# FIXME better way to wait for loop partitions to be *bounded*
sleep 1

# create both filesystem
sudo mkfs.vfat /dev/mapper/loop0p1
sudo mkfs.ext4 /dev/mapper/loop0p2

# extract rootfs
sudo mount /dev/mapper/loop0p2 ${ext4_mountp}
# TODO find a way to copy the ext filesystem without using sudo?
sudo tar -C ${ext4_mountp} -xf ${buildroot}/output/images/rootfs.tar
sudo umount ${ext4_mountp}

if [ -d ${ext4_mountp} ]; then
	rm -fr ${ext4_mountp}
fi

# *unbind* loop devices
sudo kpartx -d ${image_raw}

# install the kernel and syslinux into the vfat partition
mmd -i ${image_raw}@@${vfat_start_in_mega} ::boot
mmd -i ${image_raw}@@${vfat_start_in_mega} ::boot/syslinux
mcopy -i ${image_raw}@@${vfat_start_in_mega} ${buildroot}/output/images/bzImage ::boot/syslinux/bzImage.img
cat <<EOF >${syslinux_cfg}
DEFAULT linux
    SAY booting kernel from SYSLINUX...
  LABEL linux
    KERNEL bzImage.img
    APPEND ro root=/dev/sda2
EOF
mcopy -i ${image_raw}@@${vfat_start_in_mega} ${syslinux_cfg} ::boot/syslinux/syslinux.cfg
rm ${syslinux_cfg}
syslinux --offset $((${vfat_start}*512)) --directory /boot/syslinux --install ${image_raw}

# install mbr
dd if=/usr/lib/SYSLINUX/mbr.bin of=${image_raw} bs=440 count=1 conv=notrunc

# detach old disk from vm
VBoxManage storageattach test2 --storagectl "IDE" --device 0 --port 0 --type hdd --medium none || true
# should remove old disk from media...
#VBoxManage closemedium disk /tmp/test.vdi --delete
VBoxManage closemedium disk /tmp/test.vdi || true

VBoxManage convertdd ${image_raw} ${output_vdi} --format VDI

# convert back (not tested)
# VBoxManage clonehd src.vdi dst.raw --format RAW

# attach new disk to vm
VBoxManage storageattach test2 --storagectl "IDE" --device 0 --port 0 --type hdd --medium /tmp/test.vdi
