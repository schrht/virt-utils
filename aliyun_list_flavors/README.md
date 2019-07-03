# Description

List all the available flavors (instance types) in Alibaba Cloud by the available zones.

# Usage

1. Install `aliyun` CLI tools.
2. Install `jq` parsing tool by `dnf` command.
3. Configure with `aliyun configure`.
4. Run `./update_datasource.sh` to generate the datasource file.
   This operation takes a while and generates `/tmp/aliyun_flavor_list_raw_data.json` for you.
5. Run `./list_flavors.py` to get the results in a CSV format.

# Example

```
$ ./list_flavors.py | head
cn-qingdao-c,ecs.i2.2xlarge,Available
cn-qingdao-c,ecs.hfg5.xlarge,Available
cn-qingdao-c,ecs.mn4.small,Available
cn-qingdao-c,ecs.gn5i-c16g1.4xlarge,Available
cn-qingdao-c,ecs.xn4.small,Available
cn-qingdao-c,ecs.c5.8xlarge,Available
cn-qingdao-c,ecs.se1.xlarge,Available
cn-qingdao-c,ecs.d1ne.4xlarge,Available
cn-qingdao-c,ecs.ic5.xlarge,Available
cn-qingdao-c,ecs.re4.40xlarge,Available
```

Enjoy it!

