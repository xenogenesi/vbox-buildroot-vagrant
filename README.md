# vbox-buildroot-vagrant
External buildroot to build a minimal VirtualBox disk image with busybox, Vagrant ready.

Some note:
- current configs support only 64bit
- ipv4 only, ipv6 disabled
- openssl/ssh enabled
- vagrant user/home
- vboxguest, vboxsf kernel modules and mount.vboxsf (for directory sharing)
- current supported version for vbox guest drivers & commands: 5.0.10
- `/vagrant` directory shared with host
- [vagrant insecure pub key in authorized keys](https://github.com/mitchellh/vagrant/tree/master/keys)


## How to build

Assuming sources are in your home `~/src/`

    cd ~/src/${buildroot}
    make BR2_EXTERNAL=~/src/vbox-buildroot-vagrant \
		BR2_DEFCONFIG=~/src/vbox-buildroot-vagrant/configs/vbox64-vagrant_defconfig <optional-br-target>

Once `.config` and `output/.br-external` are created usual buildroot targets can be used without appending `BR2_EXTERNAL` or `BR2_DEFCONFIG` to `make`.
    
The build generate `bzImage` and `rootfs.tar` into directory `${buildroot}/output/images/`.

## Creating raw image and converting to vdi

The script `genvdi.sh` included to help to generate the VirtualBox VDI disk image, it use `sudo` and require some host package to be pre-installed (see the script).
`genvdi.sh` **is not** included in the buildroot's build process, use it manually (**at your own risk**).

- use [syslinux](http://www.syslinux.org/) on a vfat partition
- no initrd used yet

## Add/Remove virtualbox VM to vagrant

	## add
    vagrant package --base ${VMNAME}
    vagrant box add busybox package.box
    #vagrant init busybox # (needed only once, first time)
    vagrant up

    ## remove
    vagrant destroy
    vagrant box remove busybox
    rm package.box
