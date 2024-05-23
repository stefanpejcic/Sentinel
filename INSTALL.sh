#!/bin/bash

mkdir -p /usr/local/sentinel/

# copy files
cp sentinel.service /etc/systemd/system/sentinel.service

cp sentinel.sh /usr/local/sentinel/sentinel.sh
cp -r service/timers/ /etc/systemd/system/
cp -r scripts/ /usr/local/sentinel/
chmod +x /usr/local/sentinel/*.sh


# start service and timers
systemctl daemon-reload
systemctl enable on_reboot.timer
systemctl enable service_status.timer
systemctl enable resource_usage.timer
systemctl enable login_check.timer
systemctl enable dos_protection.timer

systemctl start on_reboot.timer
systemctl start service_status.timer
systemctl start resource_usage.timer
systemctl start login_check.timer
systemctl start dos_protection.timer


# verify
sudo systemctl status on_reboot.timer
sudo systemctl status service_status.timer
sudo systemctl status resource_usage.timer
sudo systemctl status login_check.timer
sudo systemctl status dos_protection

