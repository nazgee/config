#!/bin/bash

# modify! (this is where your password is stored)
#PASSFILE=~/.config/fpass
# modify! (this is where socat for ARM is available on your VDI)
# for some time a copy of ARM binary will be available under
# http://nexus.private.cloud.panasonicautomotive.com:30238/repository/dev-flash-packages/stawinskim/socat
#SOCATBIN=socat

# We re interested in:
# - allowing VDI to connect to 5037 on NODE (for adb used by scrcpy)
#   (local port forwarding)
# - allowing NODE to connect to 27183 on VDI (for scrcpy client)
#   (remote port fordwarding)
#
# This works just fine:
#   VDI:27183 <-- NODE:27183
#
# Unfortunately, this does not work out of the box:
#   VDI:5037 --> NODE:5037
# For some reason, we need another jump on NODE:
#   VDI:5037 --> NODE:5038 --> NODE:5037
# I think, that adb server on NODE does not listen for connection
# on all interfaces, and using works around that.

USER="michal"
PORT=22102
NODE="$1"

echo ">>> kill any socat session on node ${NODE}..."
ssh ${USER}@${NODE} -p ${PORT} \
	killall -q socat

echo ">>> kill any adb session on node ${NODE}..."
ssh ${USER}@${NODE} -p ${PORT} \
	killall -q adb

echo ">>> kill any adb session on this machine"
killall adb

echo ">>> forward `hostname`:5037 to ${NODE}:5038..."
echo ">>> forward ${NODE}:5038 to ${NODE}:5037..."
echo ">>> forward ${NODE}:27183 to `hostname`:27183..."
echo ""
echo "on `hostname` you should be able to run e.g."
echo "  /usr/bin/adb root"
echo "  /usr/bin/adb push /tmp/foo /data/foo"
echo "  ADB=/usr/bin/adb /usr/local/bin/scrcpy --no-audio"
echo ""
echo "note1: use latest scrcpy from github"
echo "note2: make sure adb versions on VDI and NODE are the same"


ssh ${USER}@${NODE} -p ${PORT} \
	/home/michal/work/build/target_hypervisor_trinity_pasj/tools/adb -P 5037 start-server

ssh  ${USER}@${NODE} -p ${PORT} \
	-L localhost:5037:localhost:5037 \
	-R 27183:127.0.0.1:27183 \
	-N

#        /home/michal/work/build/target_hypervisor_trinity_pasj/tools/adb -P 5037 start-server
	#socat TCP-LISTEN:5038,fork TCP:localhost:5037
#ANDROID_ADB_SERVER_PORT=5037 /mnt/work/japan/build_out/target_hypervisor_trinity_pasj/tools/adb devices
#telnet localhost 5037

