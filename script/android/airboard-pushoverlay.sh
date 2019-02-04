#!/bin/bash

AIRBOARD=192.168.1.1
OVERLAY=$1

ftp-upload --passive -h $AIRBOARD -u root -d /scripts $OVERLAY/scripts/startup.sh
ftp-upload --passive -h $AIRBOARD -u root -d /scripts $OVERLAY/scripts/android.sh
ftp-upload --passive -h $AIRBOARD -u root -d /bin     $OVERLAY/bin/qcdisplaycfg.xml
