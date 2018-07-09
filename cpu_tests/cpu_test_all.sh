#!/bin/bash

#export dryrun=1

log=cpu_test_all.$$.log

./online.sh 0-95 2>&1 | tee -a $log
./offline.sh 48-71,24-47,72-95 2>&1 | tee -a $log
./cpu_test.sh 2>&1 | tee -a $log

./online.sh 0-95 2>&1 | tee -a $log
./offline.sh 0-23,24-47,72-95 2>&1 | tee -a $log
./cpu_test.sh 2>&1 | tee -a $log

./online.sh 0-95 2>&1 | tee -a $log
./offline.sh 0-23,48-71,72-95 2>&1 | tee -a $log
./cpu_test.sh 2>&1 | tee -a $log

./online.sh 0-95 2>&1 | tee -a $log
./offline.sh 0-23,48-71,24-47 2>&1 | tee -a $log
./cpu_test.sh 2>&1 | tee -a $log

./online.sh 0-95 2>&1 | tee -a $log

echo -e "\nCheck log in file: $log"

exit 0

