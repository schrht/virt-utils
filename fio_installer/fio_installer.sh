#!/bin/bash

# Description:
#   Help install the fio from fio-tarball.
#   You can get the tarball from https://github.com/axboe/fio/releases
#
# History:
#   v1.0  2019-06-04  charles.shih  Install fio from tarball

if [ -z "$1" ]; then
	echo -e "Usage: $0 <fio-tarball>\n"
	exit 1
else
	tarball=$1
	[ ! -e $tarball ] && echo "$tarball not found." && exit 1
fi

# install packages
paks="make gcc libaio-devel"
for pak in $paks; do
	rpm -q $pak || sudo dnf install -y $pak
	[ $? != 0 ] && exit 1
done

# untar fio tarball
ws=$(mktemp -d)
tar xvf $tarball --directory $ws

# install fio
cd $ws/fio-*
sudo make clean
./configure
make
sudo make install
rm -rf $ws

# try fio
echo "=========="
fio --version

exit 0

