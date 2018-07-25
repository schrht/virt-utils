#!/bin/bash

# clean up logs for creating AMI
[ -f /var/log/messages ] && sudo bash -c ":>/var/log/messages"
[ -f /var/log/cloud-init.log ] && sudo bash -c ":>/var/log/cloud-init.log"
[ -f /var/log/cloud-init-output.log ] && sudo bash -c ":>cloud-init-output.log"

exit 0
