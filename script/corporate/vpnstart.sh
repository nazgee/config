#!/bin/bash
#SUDO_ASKPASS=/usr/bin/ssh-askpass

systemctl start zsaservice
sleep 1
/opt/zscaler/bin/ZSTray &
sleep 10
#sudo systemctl start zsaservice
