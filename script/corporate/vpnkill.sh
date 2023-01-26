#!/bin/bash

#SUDO_ASKPASS=/usr/bin/ssh-askpass
killall ZSTray
systemctl stop zsaservice zstunnel
killall ZSTray
ps aux | ack zs
