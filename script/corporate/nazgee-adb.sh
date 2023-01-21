#!/bin/bash

echo "killing default adb"
adb kill-server > /dev/null 2>&1

while [ true ]; do
	sleep 1
	echo "starting"
	adb -a -P 5038 nodaemon server start
done
