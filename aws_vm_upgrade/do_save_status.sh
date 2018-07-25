#!/bin/bash

# print title
echo -e "\n=================================================="
echo -e "do_save_status.sh"
echo -e "==================================================\n"

# save the current kernel version
echo "$(date) : $(uname -r)" | tee -a ~/version.log

exit 0
