#!/bin/sh

TARGETDIR=$1
BR_ROOT=$PWD

#echo "post build do nothing yet"

# FIXME workaround for php-fpm
cd $TARGETDIR/usr/lib
ln -sf mysql/libmysqlclient.so.16
