#!/usr/bin/env python
"""AWS Resource Keeper.

Use this script to find unused AWS resources.

History:
v1.0    2018-06-13  charles.shih  Finish basic the functions
v1.1    2018-06-14  charles.shih  Read user configuration from yaml file
v1.2    2018-06-14  charles.shih  Support email notificaiton
v1.3    2018-06-14  charles.shih  Support HTML report as dumpped file
v1.4    2018-06-14  charles.shih  Support HTML report as email notification
v1.4.1  2018-06-25  charles.shih  Bugfix for no unused resource found
v1.5    2018-06-25  charles.shih  Get available regions when they not specified
v1.5.1  2018-06-25  charles.shih  Bugfix for generating html report
v1.5.2  2018-06-26  charles.shih  Modify the words in HTML report
v1.5.3  2018-07-02  charles.shih  Modify the output words
v1.6    2018-07-02  charles.shih  Read ./arkeeper.yaml first
"""

import boto3
import prettytable
import yaml
import os
import getpass
import datetime
import smtplib
from email.mime.text import MIMEText
from email.header import Header


class AwsResourceCollector():
    """Collect unused resources for AWS."""

    instance_table = None
    region_list = []
    keyname_list = None

    def __init__(self):
        """Read user configuration from yaml file."""
        try:
            if os.path.exists('./arkeeper.yaml'):
                config_file = './arkeeper.yaml'
            else:
                config_file = os.path.expanduser('~/.arkeeper.yaml')

            with open(config_file, 'r') as f:
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

    def _get_available_regions(self):
        """Get available regions."""
        session = boto3.session.Session()
        available_regions = session.get_available_regions('ec2')
        return available_regions

    def scan_all(self):
        """Scan all types of resources from all specified regions."""
        if not self.region_list:
            self.region_list = self._get_available_regions()

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

        print 'NOTE: Scan running instance in region "%s".' % region
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

    def get_instance_table(self, format='string'):
        """Get instance table in specified format or as PrettyTable object."""
        if type(self.instance_table) is not prettytable.PrettyTable:
            return ''

        if format == 'string':
            return self.instance_table.get_string()
        elif format == 'html':
            return self.instance_table.get_html_string()
        else:
            return self.instance_table


class AwsResourceReporter():
    """Reporter with html and email notification supported."""

    smtp_server = 'smtp.example.com'
    smtp_port = '25'
    smtp_user = smtp_pass = ''
    sender = 'name@example.com'
    receivers = ['name@example.com']
    email_subject = '[TEST] AWS Resource Report'

    html_report = ''

    def __init__(self):
        """Read user configuration."""
        try:
            if os.path.exists('./arkeeper.yaml'):
                config_file = './arkeeper.yaml'
            else:
                config_file = os.path.expanduser('~/.arkeeper.yaml')

            with open(config_file, 'r') as f:
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

            with open('./report_template.html', 'r') as f:
                self.html_report = f.read()

        except Exception as err:
            print 'WARNING: encounter an error while parsing user config.'
            print err

    def send_email(self, mail_msg='Message body...', subtype='plain'):
        """Send out the report as email notification."""
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
        except smtplib.SMTPException as err:
            print 'ERROR: error while sending email notification.'
            print err

    def html_append(self, content):
        """Append content to the html report."""
        # The content should be inserted before '</body>'
        origin = self.html_report
        self.html_report = origin.replace('</body>', content + '\n</body>', 1)

    def html_get_string(self):
        """Get html report as string."""
        return self.html_report

    def html_dump(self, file='./report.html'):
        """Dump html report as an html file."""
        try:
            with open(file, 'w') as f:
                f.write(self.html_report)
        except Exception as err:
            print 'ERROR: error while dumping html file.'
            print err

        print 'NOTE: html file dumpped! (%s)' % file

    def html_send(self):
        """Send html report as an Email notification."""
        self.send_email(mail_msg=self.html_report, subtype='html')


if __name__ == "__main__":

    user = getpass.getuser()
    date = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print '\nNOTE: [%s] %s' % (user, date)

    collector = AwsResourceCollector()
    collector.scan_all()

    table = collector.get_instance_table(format='html')

    if table:
        reporter = AwsResourceReporter()
        reporter.html_append(
            '<h1 style="color:red">Did you forget something?</h1>')
        reporter.html_append('<h2>Running Instance</h2>')
        reporter.html_append(table)
        reporter.html_append(
            '<h3>Search in: %s</h3>' % str.join(', ', collector.region_list))
        reporter.html_append(
            '<h3>Filter by: %s</h3>' % str.join(', ', collector.keyname_list))

        reporter.html_dump()
        reporter.html_send()
    else:
        print 'NOTE: No unused resource found.'
