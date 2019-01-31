#!/bin/bash

curl -T $1/scripts/startup.sh ftp://192.168.1.1/scripts --user root:
curl -T $1/scripts/android.sh ftp://192.168.1.1/scripts --user root:

curl -T $1/bin/qcdisplaycfg.xml ftp://192.168.1.1/bin --user root:
