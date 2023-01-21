#!/bin/bash

CARD="88_C9_E8_07_E4_D1"

#### Toggle listen/speak
if [ "$1" == "" -o "$1" == "toggle" ] ; then
  bluetoothctl connect 88:C9:E8:07:E4:D1
  sleep 1

  LINE=`pacmd list-sinks  | grep '\(name:\|alias\)' | grep -B1 1000XM5  | head -1`
  if [ "$LINE" == "" ]; then
	  notify-send "Listen" "1000XM5 not found"
	  echo "1000XM5 headset not found"
	  exit
  fi

  SINK_NAME="bluez_sink.88_C9_E8_07_E4_D1.a2dp_sink"
  if $(echo "$LINE" | grep $SINK_NAME &> /dev/null) ; then
    echo "Switch to Headset"
    $0 speak
  else
    echo "Switch to Headphones"
    $0 listen
  fi
fi

#### Change the output to 1000XM5
if [ "$1" == "listen" ] ; then
  bluetoothctl connect 88:C9:E8:07:E4:D1
  sleep 1

  LINE=`pacmd list-sinks  | grep '\(name:\|alias\)' | grep -B1 1000XM5  | head -1`
  if [ "$LINE" == "" ] ; then
	  echo "100XM5 phones not found"
	  notify-send "Listen" "1000XM5 not found"
	  exit
  fi

  echo "Switching audio profile to a2dp_sink";
  pacmd set-card-profile "bluez_card.$CARD" a2dp_sink

  echo "Switching audio output to a2dp_sink";
  pacmd set-default-sink "bluez_sink.$CARD.a2dp_sink"
  notify-send "1000XM5 music mode" "Headphones"
  exit
fi

#### Input
if [ "$1" == "speak" ] ; then
  bluetoothctl connect 88:C9:E8:07:E4:D1
  sleep 1

  echo "Switching audio profile to handsfree_head_unit"
  pacmd set-card-profile "bluez_card.$CARD" handsfree_head_unit

  echo "Switching audio input to handsfree_head_unit";
  pacmd set-default-source "bluez_source.$CARD.handsfree_head_unit"
  notify-send "1000XM5 microphone mode" "Headset"
fi

if [ $1 == "disconnect" ]; then
	bluetoothctl disconnect 88:C9:E8:07:E4:D1
	notify-send "1000XM5 disconnected" "Bye!"
fi


####  Resources:

##  Why this is needed
# https://jimshaver.net/2015/03/31/going-a2dp-only-on-linux/

##  My original question
# https://askubuntu.com/questions/1004712/audio-profile-changes-automatically-to-hsp-bad-quality-when-i-change-input-to/1009156#1009156

##  Script to monitor plugged earphones and switch when unplugged (Ubuntu does that, but nice script):
# https://github.com/freundTech/linux-helper-scripts/blob/master/padevswitch/padevswitch
