#!/bin/bash

# setup service
cp sentinel.timer /etc/systemd/system/sentinel.timer
cp sentinel.service /etc/systemd/system/sentinel.service

# copy files
cp sentinel.sh /usr/local/sentinel/sentinel.sh
sudo chmod +x /usr/local/sentinel/sentinel.sh

# start service
sudo systemctl daemon-reload
sudo systemctl enable sentinel.timer
sudo systemctl start sentinel.timer
