#!/usr/bin/env python
"""AWS Resource Keeper.

Use this script to find unused AWS resources.

History:
v1.0    2018-06-13  charles.shih  Finish basic the functions
v1.1    2018-06-14  charles.shih  Read user configuration from yaml file
v1.2    2018-06-14  charles.shih  Support email notificaiton
"""

import boto3
import prettytable
import yaml
import os
import smtplib
from email.mime.text import MIMEText
from email.header import Header


class AwsResourceCollector():
    """Collect unused resources for AWS."""

    instance_table = None
    region_list = ['us-west-2']
    keyname_list = None

    def __init__(self):
        """Read user configuration from yaml file."""
        try:
            with open(os.path.expanduser('~/.arkeeper.yaml'), 'r') as f:
                yaml_dict = yaml.load(f)

            if self.__class__.__name__ in yaml_dict:
                user_config = yaml_dict[self.__class__.__name__]

                if 'RegionList' in user_config:
                    self.region_list = user_config['RegionList']

                if 'KeynameList' in user_config:
                    self.keyname_list = user_config['KeynameList']

        except Exception as err:
            print 'WARNING: encounter an error while parsing user config.'
            print err

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


class AwsResourceReporter():
    """Reporter with html and email notification supported."""

    smtp_server = 'smtp.corp.redhat.com'
    smtp_port = '25'
    smtp_user = smtp_pass = ''
    sender = 'cheshi@redhat.com'
    receivers = ['cheshi@redhat.com']
    email_subject = '[TEST] AWS Resource Report'

    def __init__(self):
        """Read user configuration from yaml file."""
        try:
            with open(os.path.expanduser('~/.arkeeper.yaml'), 'r') as f:
                yaml_dict = yaml.load(f)

            if self.__class__.__name__ in yaml_dict:
                user_config = yaml_dict[self.__class__.__name__]

                if 'SmtpServer' in user_config:
                    self.smtp_server = user_config['SmtpServer']

                if 'SmtpPort' in user_config:
                    self.smtp_port = user_config['SmtpPort']

                if 'SmtpUser' in user_config:
                    self.smtp_user = user_config['SmtpUser']

                if 'SmtpPass' in user_config:
                    self.smtp_pass = user_config['SmtpPass']

                if 'Sender' in user_config:
                    self.sender = user_config['Sender']

                if 'Receivers' in user_config:
                    self.receivers = user_config['Receivers']

                if 'EmailSubject' in user_config:
                    self.email_subject = user_config['EmailSubject']

        except Exception as err:
            print 'WARNING: encounter an error while parsing user config.'
            print err

    def send_email(self, mail_msg='Message body...'):
        """Send out the report as email notification."""
        subtype = 'plain'  # 'html' or 'plain'
        message = MIMEText(mail_msg, subtype, 'utf-8')
        message['Subject'] = Header(self.email_subject, 'utf-8')
        message['From'] = Header(self.sender, 'ascii')
        message['To'] = Header(str.join(',', self.receivers), 'ascii')

        try:
            smtpObj = smtplib.SMTP()
            smtpObj.connect(self.smtp_server, self.smtp_port)
            if self.smtp_user and self.smtp_pass:
                smtpObj.login(self.smtp_user, self.smtp_pass)
            smtpObj.sendmail(self.sender, self.receivers, message.as_string())
            print 'NOTE: Email notification sent!'
        except smtplib.SMTPException:
            print 'ERROR: error while sending email notification.'


if __name__ == "__main__":
    # collector = AwsResourceCollector()
    # collector.scan_all()
    # table= collector.instance_table.get_string()
    # print table

    reporter = AwsResourceReporter()
    reporter.send_email()