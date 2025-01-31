#!/bin/bash

echo "stopping pipe processes"
sudo systemctl stop dcdnd.service
sudo systemctl disable dcdnd.service
sudo rm /etc/systemd/system/dcdnd.service
sudo systemctl daemon-reload
echo "pipe processes stopped"
