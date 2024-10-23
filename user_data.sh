#!/bin/sh
sudo dnf update -y > /tmp/user_data.log 2>&1
sudo dnf install postgresql16 -y >> /tmp/user_data.log 2>&1