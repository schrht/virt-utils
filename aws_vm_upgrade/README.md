# Preparation

## Configure local proxy server

1. Install the squid service: `yum install -y squid`
2. Do initialization: `squid -z`
3. Start the service: `systemctl start squid.service`

After finishing VM upgrade, you can stop the proxy service by `systemctl stop squid.service` command.

# Upgrade the VM

## Usage

`./vm_upgrade.sh <pem file> <instance ip / hostname> <the baseurl to be placed in repo file>`

- `pem file`: The sshkey crediential.
- `instance ip`: The IP address of the VM.
- `baseurl`: The URL of a private repo.

## Example

`./vm_upgrade.sh ~/.pem/cheshi.pem ec2-34-217-96-64.us-west-2.compute.amazonaws.com http://server.redhat.com/path/RHEL-7.6-20180724.0/compose/Server/x86_64/os/`

# Q&A

Q: Can it be used in public cloud other than AWS? Such as Azure?
A: Currently you have to modify the scripts, such as replacing the hard-code "ec2-user" to "root".

Q: Can it be used in other Linux other than RHEL? Such as Fedora?
A: Theoretically speaking, the scripts work on all YUM based distros of Linux. All it needs are `squid` + `ssh` + `yum`.
