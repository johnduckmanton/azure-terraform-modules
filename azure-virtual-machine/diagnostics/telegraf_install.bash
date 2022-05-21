#!/bin/bash

wget https://repos.influxdata.com/rhel/7Server/amd64/stable/telegraf-1.14.3-1.x86_64.rpm
sudo rpm -i telegraf-1.14.3-1.x86_64.rpm
sudo systemctl start telegraf
telegraf --input-filter cpu:mem:disk --output-filter azure_monitor config > azm-telegraf.conf
sudo cp azm-telegraf.conf /etc/telegraf/telegraf.conf
sudo systemctl stop telegraf
sudo systemctl start telegraf
