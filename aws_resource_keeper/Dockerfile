FROM fedora:30
LABEL MAINTAINER="Charles Shih"

RUN yum install -y python3-pyyaml
RUN pip3 install boto3 prettytable

RUN mkdir -p /app
COPY resource_keeper.* report_template.html /app
RUN mkdir -p /root/.aws
COPY credentials /root/.aws

WORKDIR /app
CMD ["/app/resource_keeper.py"]

