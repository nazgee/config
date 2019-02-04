#!/bin/bash
adb shell ps | grep -i $1 | awk '{print $2}'
