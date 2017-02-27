#!/bin/sh -e

buildroot=$HOME/src/buildroot-2016.11.2

image_raw=/tmp/test.raw
image_size=${1:-150}
p1_start=2048
p1_start_in_mega=1M
output_vdi=/tmp/test.vdi
vmname=test2

rm -f ${output_vdi} 2>/dev/null || true

dd if=/dev/zero of=${image_raw} bs=1M count=${image_size}

# create two partitions:
# 1) few mega raw for the bzImage
# 2) rootfs squashfs
# credit: http://superuser.com/a/984637/241894
sed -e 's/\t\([\+0-9a-zA-Z]*\)[ \t].*/\1/' <<EOF | /sbin/fdisk ${image_raw}
	n # new
	p # primary
	1 # 1st
	${p1_start} # first sector
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

dd if=${buildroot}/output/images/bzImage bs=512 seek=2048 conv=notrunc of=${image_raw}
dd if=${buildroot}/output/images/rootfs.squashfs bs=512 seek=12288 conv=notrunc of=${image_raw}

${buildroot}/output/build/mlb-61fdd07e2e05f6ef342ea55277f242dbfc940bda/mlbinstall ${image_raw} ${buildroot}/output/images/bzImage@2048 "root=/dev/sda2 vga=0x0f06"

### detach old disk from vm
VBoxManage storageattach ${vmname} --storagectl "IDE" --device 0 --port 0 --type hdd --medium none || true
### should remove old disk from media...
###VBoxManage closemedium disk ${output_vdi} --delete
VBoxManage closemedium disk ${output_vdi} || true

VBoxManage convertdd ${image_raw} ${output_vdi} --format VDI

### convert back (not tested)
### VBoxManage clonehd src.vdi dst.raw --format RAW

### attach new disk to vm
VBoxManage storageattach ${vmname} --storagectl "IDE" --device 0 --port 0 --type hdd --medium ${output_vdi}
