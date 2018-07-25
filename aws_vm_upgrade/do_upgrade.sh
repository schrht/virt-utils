#!/bin/bash

die() { echo "$@"; exit 1; }

# do upgrade
sudo yum update -y || die "[FAILED] yum update failed due to error."

exit 0
