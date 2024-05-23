#!/bin/bash

mkdir -p /usr/local/sentinel/

# copy files
cp sentinel.service /etc/systemd/system/sentinel.service

cp sentinel.sh /usr/local/sentinel/sentinel.sh
sudo chmod +x /usr/local/sentinel/sentinel.sh

cp -r service/timers/ /etc/systemd/system/
cp -r scripts/ /usr/local/sentinel/



# start service and timers
sudo systemctl daemon-reload
sudo systemctl enable on_reboot.timer
sudo systemctl enable service_status.timer
sudo systemctl enable resource_usage.timer
sudo systemctl enable login_check.timer
sudo systemctl enable dos_protection.timer

sudo systemctl start on_reboot.timer
sudo systemctl start service_status.timer
sudo systemctl start resource_usage.timer
sudo systemctl start login_check.timer
sudo systemctl start dos_protection.timer


# verify
sudo systemctl status on_reboot.timer
sudo systemctl status service_status.timer
sudo systemctl status resource_usage.timer
sudo systemctl status login_check.timer
sudo systemctl status dos_protection

