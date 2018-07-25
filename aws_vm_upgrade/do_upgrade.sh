#!/bin/bash

die() { echo "$@"; exit 1; }

# print title
echo -e "\n=================================================="
echo -e "do_upgrade.sh"
echo -e "==================================================\n"

# do upgrade
sudo yum update -y || die "[FAILED] yum update failed due to error."

exit 0
