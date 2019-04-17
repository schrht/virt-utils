#!/usr/bin/env bash

# Description:
#   Update the available flavor list from Alibaba Cloud,
#   save the raw data into json file for further parsing.
#
# Dependence:
#   aliyun - CLI tool for Alibaba Cloud
#   jq     - Command-line JSON processor
#
# History:
#   v1.0  2019-04-16  charles.shih  init version

# Get all regions
x=$(aliyun ecs DescribeRegions | jq -r '.Regions.Region[].RegionId')
if [ $? = 0 ]; then
    regions=$x
else
    exit 1
fi

# Create and empty the file
file=/tmp/aliyun_flavor_list_raw_data.json
:> $file

# Save all flavors in each region
for region in $regions; do
    for iovalue in optimized none; do
        x=$(aliyun ecs DescribeAvailableResource --RegionId $region \
            --DestinationResource InstanceType --IoOptimized $iovalue \
            | jq -r '.AvailableZones.AvailableZone[]' 2>/dev/null)
        [ $? = 0 ] && echo $x | jq -r '.' >> $file
    done
done

# Update the file to json format
sed -i -e '1s/{/[{/' -e '$s/}/}]/' -e 's/^}$/},/' $file

exit 0
