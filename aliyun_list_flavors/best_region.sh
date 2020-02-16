#!/bin/bash
#
# Description:
#   Find best region to go based on instace types in full.txt and pass.txt
#
# Help:
#   (The avocado_cloud test results...)
#   cat results.json | jq -r '.tests[].id' | sed 's/.*-\(ecs.*\)-Image.*/\1/' | sort -u | tee ./full.txt
#   cat results.json | jq -r '.tests[] | select(.status=="PASS") | .id' | sed 's/.*-\(ecs.*\)-Image.*/\1/' | sort -u | tee ./pass.txt
#
# Owner:
#   Charles Shih
#
# History:
#   v1.0  2020-02-16  charles.shih  Init Version

PATH=$PATH:.

touch ./pass.txt ./full.txt
todolist=$(grep -v -f ./pass.txt ./full.txt)

[ -z "$todolist" ] && exit 1

echo -e "\nYou may want to run update_datasource.sh first..."

: >/tmp/type-region.txt
for type in $todolist; do
	echo -e "\nSearch instance type: $type ..."
	list_flavors.py | grep $type | tee -a /tmp/type-region.txt
done

echo -e "\nFinal results (types):"
grep Available /tmp/type-region.txt | cut -d',' -f2 | sort | uniq -c | sort -n -r

echo -e "\nFinal results (regions):"
grep Available /tmp/type-region.txt | cut -d',' -f1 | sort | uniq -c | sort -n -r

exit 0
