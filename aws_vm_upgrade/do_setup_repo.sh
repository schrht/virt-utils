#!/bin/bash

die() { echo "$@"; exit 1; }

if [ -z "$1" ]; then
    die "[ERROR] Usage: $0 <--enable|--disable>"
fi

if [ "$1" = "--enable" ]; then
    # get repo file and install
    [ -f ~/rhel-debug.repo ] || die "[FAILED] Can not found ~/rhel-debug.repo."
    sudo mv ~/rhel-debug.repo /etc/yum.repos.d/ || die "[FAILED] install rhel-debug.repo failed."

    # enable the repo
    sudo yum-config-manager --enable rhel-debug || die "[FAILED] Enable repo rhel-debug failed."

    # clean the cache
    yum clean all --disablerepo=* --enablerepo=rhel-debug || die "[FAILED] yum clean failed due to error."
elif [ "$1" = "--disable" ]; then
    # disable the repo
    sudo yum-config-manager --disable rhel-debug || die "[FAILED] Disable repo rhel-debug failed."
else
    die "[ERROR] Usage: $0 <--enable|--disable>"
fi

exit 0
