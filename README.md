# vbox-buildroot-vagrant
[External buildroot](https://buildroot.org/downloads/manual/manual.html#outside-br-custom) to build a minimal VirtualBox disk image with busybox, Vagrant ready.

Some note
- the `-lamp-` config enable apache2, php (fpm-php), mysqld, phpmyadmin
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

The script `genvdi-syslinux.sh` included to help to generate the VirtualBox VDI disk image, it use `sudo` and require some host package to be pre-installed (see the script).
`genvdi-syslinux.sh` **is not** included in the buildroot's build process, use it manually (**at your own risk**).

- use [syslinux](http://www.syslinux.org/) on a vfat partition
- no initrd used yet

## Vagrantfile

- add `config.ssh.shell = "/bin/sh"`
- optionally for `-lamp-` configs:
  - add `config.vm.network "httpd", guest: 80, host: 8080` [http://localhost:8080](http://localhost:8080)
  - add `config.vm.synced_folder "htdocs", "/usr/htdocs"` and create a local directory `htdocs/`(the default `DocumentRoot` for installed apache2)

## Add/Remove virtualbox VM to vagrant

	## add
    vagrant package --base ${VMNAME}     # the name of the current VirtualBox VM
    vagrant box add busybox package.box  # busybox and package just names see vagrant manual
    #vagrant init busybox                # (needed only once, first time)
    vagrant up

    ## remove
    vagrant destroy
    vagrant box remove busybox
    rm package.box

## phpmyadmin

phpMyAdmin is installed without configuration, with the exception for `AllowNoPassword = true` in `config.inc.php`
Access at [http://localhost:8080/phpmyadmin/](http://localhost:8080/phpmyadmin/)

## MySQL server

MySQL is installed as it is, without configuration, boot with the GUI active to see suggested steps by MySQL scripts.

