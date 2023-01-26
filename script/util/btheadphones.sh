#!/bin/bash

HPMAC="88:C9:E8:07:E4:D1"
HPCARD="bluez_card.88_C9_E8_07_E4_D1"

function connect_headphones {
	bluetoothctl connect $HPMAC
	sleep 4
}

function reconnect {
	systemctl restart bluetooth.service
	sleep 1
	connect_headphones
}


function connect_a2dp {
        if pactl list | grep a2dp > /dev/null; then
                echo "has a2dp"
        else
                echo "no HFP, connecting"
		connect_headphones	

		if pactl list | grep a2dp > /dev/null; then
			echo "has a2dp"
		else
			echo "no a2dp, restarting bluez, connecting"
			reconnect
		fi
	fi

	notify-send "headphones: A2DP"
	pactl set-card-profile $HPCARD a2dp-sink-ldac
}


function connect_hfp {
        if pactl list | grep HFP > /dev/null; then
                echo "has HFP"
        else
                echo "no HFP, connecting"
		connect_headphones

		if pactl list | grep HFP > /dev/null; then
			echo "has HFP"
		else
			echo "no HFP, restarting bluez, connecting"
			reconnect
		fi
	fi

	notify-send "headphones: HFP"
	pactl set-card-profile $HPCARD headset-head-unit-msbc
}


if [ "$1" == "disconnect" ]; then
	bluetoothctl disconnect $HPMAC
	notify-send "headphones: disconnect"
elif [ "$1" == "hfp" ]; then
	connect_hfp
else
	connect_a2dp
fi
