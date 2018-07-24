#!/bin/bash

die() { echo "$@"; exit 1; }

show_usage() {
    echo -e "Usage:"
    echo -e "$0 <--setup repo_url | --enable | --clean | --disable>"
    echo -e "Example:"
    echo -e "$0 --setup http://download-node-02.eng.bos.redhat.com/rel-eng/latest-RHEL-7.6/compose/Server/x86_64/os/"
    echo -e "$0 --enable"
    echo -e "$0 --clean"
    echo -e "$0 --disable"
}

if [ -z "$1" ]; then
    show_usage
    die "[ERROR] Bad parameters."
fi

if [ "$1" = "--setup" ]; then

    # check the inputs
    [ -z "$2" ] && show_usage && die "[ERROR] Bad parameters."

    # create repo file
    cat << EOF > ~/rhel-debug.repo
[rhel-debug]
name=rhel-debug
baseurl=$2
enabled=0
gpgcheck=0
proxy=http://127.0.0.1:8080/
EOF
    chmod 755 ~/rhel-debug.repo

    # get repo file and install
    [ -f ~/rhel-debug.repo ] || die "[FAILED] Can not found ~/rhel-debug.repo."
    sudo mv ~/rhel-debug.repo /etc/yum.repos.d/ || die "[FAILED] install rhel-debug.repo failed."
elif [ "$1" = "--enable" ]; then

    # enable the repo
    sudo yum-config-manager --enable rhel-debug || die "[FAILED] Enable repo rhel-debug failed."
elif [ "$1" = "--clean" ]; then

    # clean the cache
    yum clean all --disablerepo=* --enablerepo=rhel-debug || die "[FAILED] yum clean failed due to error."
elif [ "$1" = "--disable" ]; then

    # disable the repo
    sudo yum-config-manager --disable rhel-debug || die "[FAILED] Disable repo rhel-debug failed."
else

    # bad parameters
    show_usage && die "[ERROR] Bad parameters."
fi

exit 0

