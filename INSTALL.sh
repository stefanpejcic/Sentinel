#!/bin/bash


cp sentinel.timer /etc/systemd/system/sentinel.timer
cp sentinel.sh /usr/local/bin/sentinel.sh


sudo systemctl daemon-reload
sudo systemctl enable sentinel.timer
sudo systemctl start sentinel.timer
