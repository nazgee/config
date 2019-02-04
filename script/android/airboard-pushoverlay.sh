#!/bin/bash

AIRBOARD=192.168.1.1
OVERLAY=$1

curl -T $OVERLAY/scripts/startup.sh ftp://$AIRBOARD/scripts --user root:
curl -T $OVERLAY/scripts/android.sh ftp://$AIRBOARD/scripts --user root:
curl -T $OVERLAY/bin/qcdisplaycfg.xml ftp://$AIRBOARD/bin --user root:
