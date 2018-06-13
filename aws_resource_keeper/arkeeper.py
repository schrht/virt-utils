#!/usr/bin/env python
"""AWS Resource Keeper.

Use this script to find unused AWS resources.

History:
v1.0    2018-06-13  charles.shih  Finish basic the functions.
"""

import boto3
import prettytable


class AwsResourceCollector():
    """Collect unused resources for AWS."""

    def __init__(self):
        """Do some initialization."""
        self.instance_table = None
        self.region_list = [
            'ap-south-1', 'eu-west-3', 'eu-west-2', 'eu-west-1',
            'ap-northeast-3', 'ap-northeast-2', 'ap-northeast-1', 'sa-east-1',
            'ca-central-1', 'ap-southeast-1', 'ap-southeast-2', 'eu-central-1',
            'us-east-1', 'us-east-2', 'us-west-1', 'us-west-2'
        ]
        self.keyname_list = ['cheshi', 'linl', 'xiliang']

    def scan_all(self):
        """Scan all types of resources from all specified regions."""
        for region in self.region_list:
            self.scan_instance(region=region)

    def scan_instance(self, region='us-west-2'):
        """Scan running instance from specified regions.

        This function use BOTO3 to describe running instances from specified
        region. Then filter the keynames which is from the self.keyname_list.
        It stores the instance tuples into self.instance_table.

        Args:
            region: the specified region to be scaned;
        Returns:
            None
        Updates:
            self.instance_table: store the instance tuples.

        """
        instance_list = []

        ec2_resource = boto3.resource('ec2', region_name=region)
        running_instances = ec2_resource.instances.filter(
            Filters=[{
                'Name': 'instance-state-name',
                'Values': ['running']
            }])

        for instance in running_instances:
            if not self.keyname_list or instance.key_name in self.keyname_list:
                # Get the "name" of instance
                try:
                    name = filter(lambda x: x[u'Key'] == 'Name',
                                  instance.tags)[0][u'Value']
                except:
                    name = 'n/a'

                instance_list.append(
                    (region, name, instance.id, instance.instance_type,
                     instance.key_name))

        if instance_list:
            if self.instance_table is None:
                # Create instance table
                self.instance_table = prettytable.PrettyTable([
                    'Region', 'tag:Name', 'InstanceId', 'InstanceType',
                    'KeyName'
                ])
                self.instance_table.align = 'l'

            # Add rows to the table
            for item in instance_list:
                self.instance_table.add_row(item)

        return None


if __name__ == "__main__":
    collector = AwsResourceCollector()
    collector.scan_all()
    print collector.instance_table
