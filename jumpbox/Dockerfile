FROM ubuntu:latest
RUN apt update && apt-get install -y curl python3.10 python3-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql
RUN pip3 install -U pip

COPY . .
