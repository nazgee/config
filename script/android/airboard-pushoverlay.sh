#!/bin/bash

AIRBOARD=192.168.1.115
OVERLAY=$1

ftp-upload --passive -h $AIRBOARD -u root -d /scripts $OVERLAY/scripts/startup.sh
ftp-upload --passive -h $AIRBOARD -u root -d /scripts $OVERLAY/scripts/android.sh
ftp-upload --passive -h $AIRBOARD -u root -d /bin     $OVERLAY/bin/qcdisplaycfg.xml
ftp-upload --passive -h $AIRBOARD -u root -d /lib64   $OVERLAY/lib64/graphics.conf
ftp-upload --passive -h $AIRBOARD -u root -d /etc/system/config $OVERLAY/etc/system/config/mtouch_lilliput_1080p_eGalax_FIRST.conf
ftp-upload --passive -h $AIRBOARD -u root -d /etc/system/config $OVERLAY/etc/system/config/mtouch_lilliput_1080p_eGalax_FIRST
