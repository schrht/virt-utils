#!/bin/bash

set -e

source ./config.txt
source ./functions.sh


image_url=${1:-http://download.eng.pek2.redhat.com/pub/rhel-8/rel-eng/RHEL-8/RHEL-8.2.0-Beta-1.0/compose/BaseOS/x86_64/images/rhel-guest-image-8.2-128.x86_64.qcow2}

download_image
process_image
customize_ha_image

echo -e "\n########################################"
echo -e "THE UPDATED IMAGE IS:"
echo -e "$workspace/$image_file"
echo -e "########################################\n"

exit 0

