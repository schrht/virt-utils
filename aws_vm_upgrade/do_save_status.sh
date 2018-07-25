#!/bin/bash

# save the current kernel version
echo "$(date) : $(uname -r)" | tee -a ~/version.log

exit 0
