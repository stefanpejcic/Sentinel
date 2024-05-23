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



# verify service and timers
if sudo systemctl is-active --quiet on_reboot.timer; then
    echo "on_reboot.timer is active"
else
    echo "on_reboot.timer is not active"
    echo "To manually create and start on_reboot.timer, run:"
    echo "sudo cp service/timers/on_reboot.timer /etc/systemd/system/on_reboot.timer && sudo systemctl enable --now on_reboot.timer"
fi

if sudo systemctl is-active --quiet service_status.timer; then
    echo "service_status.timer is active"
else
    echo "service_status.timer is not active"
    echo "To manually create and start service_status.timer, run:"
    echo "sudo cp service/timers/service_status.timer /etc/systemd/system/service_status.timer && sudo systemctl enable --now service_status.timer"
fi

if sudo systemctl is-active --quiet resource_usage.timer; then
    echo "resource_usage.timer is active"
else
    echo "resource_usage.timer is not active"
    echo "To manually create and start resource_usage.timer, run:"
    echo "sudo cp service/timers/resource_usage.timer /etc/systemd/system/resource_usage.timer && sudo systemctl enable --now resource_usage.timer"
fi

if sudo systemctl is-active --quiet login_check.timer; then
    echo "login_check.timer is active"
else
    echo "login_check.timer is not active"
    echo "To manually create and start login_check.timer, run:"
    echo "sudo cp service/timers/login_check.timer /etc/systemd/system/login_check.timer && sudo systemctl enable --now login_check.timer"
fi

if sudo systemctl is-active --quiet dos_protection.timer; then
    echo "dos_protection.timer is active"
else
    echo "dos_protection.timer is not active"
    echo "To manually create and start dos_protection.timer, run:"
    echo "sudo cp service/timers/dos_protection.timer /etc/systemd/system/dos_protection.timer && sudo systemctl enable --now dos_protection.timer"
fi



