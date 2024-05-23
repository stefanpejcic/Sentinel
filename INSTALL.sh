#!/bin/bash

# setup service
cp sentinel.timer /etc/systemd/system/sentinel.timer
cp sentinel.service /etc/systemd/system/sentinel.service







# copy files
cp sentinel.sh /usr/local/sentinel/sentinel.sh
sudo chmod +x /usr/local/sentinel/sentinel.sh

cp service/timers/on_reboot.timer /etc/systemd/system/on_reboot.timer
cp service/timers/service_status.timer /etc/systemd/system/service_status.timer
cp service/timers/resource_usage.timer /etc/systemd/system/resource_usage.timer
cp service/timers/login_check.timer /etc/systemd/system/login_check.timer
cp service/timers/dos_protection.timer /etc/systemd/system/dos_protection.timer




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

