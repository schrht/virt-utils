#!/bin/bash

die() { echo "$@"; exit 1; }

# save the current kernel version
echo "$(date) : $(uname -r)" | tee -a ~/version.log

# do upgrade
sudo yum update -y || die "[FAILED] yum update failed due to error."

exit 0

