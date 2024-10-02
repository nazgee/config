#!/bin/bash

ADB_OPSY=/mnt/work/japan/build_out/target_hypervisor_trinity_pasj/tools/adb
ADB=adb
SERIAL=92417044

ARG_OUTPUT_DIR="./"
ARG_PREVIEW_FILTER=".*"
ARG_INIT='echo "=== Init completed"'
ARG_SERIAL="$SERIAL"
ARG_CLEAR=""
ARG_ADBOPSY=""
ARG_PID=""
ARG_PROC=""

# if "--vm $VM" is passed as an argument, use the $VM as suffix to SERIAL. use getopt to parse the argument
# if "--out $OUT" is passed as an argument, use the $OUT as the output directory. use getopt to parse the argument

# Parse the arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --serial)
      ARG_SERIAL="$2"
      shift
      ;;
    --vm)
      ARG_SERIAL="$SERIAL-$2"
      shift
      ;;
    --out)
      ARG_OUTPUT_DIR=$2
      shift
      ;;
    --preview)
      ARG_PREVIEW_FILTER=$2
      shift
      ;;
    --clear)
      ARG_CLEAR="clear"
      ;;
    --adbopsy)
      ARG_ADBOPSY="adbopsy"
      ;;
    --adbcustom)
      ADB=$2
      shift
      ;;
    --pid)
      ARG_PROC="$2"
      shift
      ;;
    --file)
      ARG_USE_FILE="file"
      shift
      ;;
    *)
      echo "Usage: $0 [--vm <vm>] [--out <output_dir>] [--preview <filter>] [--serial <serial>] [--clear] [--adbopsy] [--adbcustom <adb>]"
      echo "  --vm <vm>           Use the <vm> as suffix to the serial number"
      echo "  --out <output_dir>  Save the logcat to the <output_dir>"
      echo "  --preview <filter>  Show only the lines that match the <filter> (all lines will be saved -- use this to preview the logcat)"
      echo "  --serial <serial>   Use the <serial> as the device serial number"
      echo "  --clear             Clear the logcat before starting"
      echo "  --adbopsy           Use the adb from OPSY"
      echo "  --adbcustom <adb>   Use the custom adb binary"
      echo "  --pid <pid>         Fetch only the lines that match the <pid>, can be specified only once (only lines from specified pids will be saved)"
      echo "  --file              Use the file as input"
      exit 1
      ;;
  esac
  shift
done

#update adb
if [ "$ARG_ADBOPSY" == "adbopsy" ]; then
  ADB=$ADB_OPSY
fi

#update arg init
if [ "$ARG_CLEAR" == "clear" ]; then
  ARG_INIT="$ADB -s $ARG_SERIAL logcat -c; $ARG_INIT"
fi

#make root if file is used
if [ "$ARG_USE_FILE" == "file" ]; then
  ARG_INIT="$ADB -s $ARG_SERIAL root; $ADB -s $ARG_SERIAL wait-for-device; $ARG_INIT"
fi

# fetch the PIDs for the specified processes
if [ -z "$ARG_PROC" ]; then
  echo "No PID specified"
else
  PID_COLUMN=$($ADB -s $ARG_SERIAL shell ps | ack --nocolor "$ARG_PROC" | awk '{print $2}')
  if [ -z "$PID_COLUMN" ]; then
    echo "No PID found for ${ARG_PROC}"
    exit 1
  fi
  # check if only one PID is found
  if [ "$(echo "$PID_COLUMN" | wc -l)" -gt 1 ]; then
    echo "Multiple PIDs found for ${ARG_PROC}"
    echo "$PID_COLUMN" | wc -l
    exit 1
  fi
  ARG_PID+="--pid $PID_COLUMN"
fi


echo "<output_dir> = $ARG_OUTPUT_DIR"
echo "<preview_filter> = $ARG_PREVIEW_FILTER"
echo "<device_serial> = $ARG_SERIAL"
echo "<adb> = $ADB"
echo "<init> = $ARG_INIT"
echo "<pid> = \"${ARG_PROC[*]}\" --> \"${ARG_PID[*]}\""


# Create the output directory
mkdir -p $ARG_OUTPUT_DIR

eval "${ARG_INIT}"

# Define a function to stop the logcat process and pull the file
stop_logcat() {
    echo "=== Stopping logcat..."
    # Stop the background logcat process
    kill $LOGCAT_PID
    wait $LOGCAT_PID 2>/dev/null
}

NEVER_SHOW="nng-test:S Unity:S CommVIP:S"

# Start the logcat
while [ true ]; do
  #datebased suffix
  DATE=$(date +"%Y%m%d-%H%M%S")
  FILE="logcat-$DATE.txt"
  FILE_ON_TARGET="/data/logcat-$DATE.txt"
  echo "=== Saving logcat to ${ARG_OUTPUT_DIR}/${FILE}"
  if [ "$ARG_USE_FILE" == "file" ]; then
    $ADB -s "${ARG_SERIAL}" root
    $ADB -s "${ARG_SERIAL}" wait-for-device;
    $ADB -s "${ARG_SERIAL}" logcat "${NEVER_SHOW}" "${ARG_PID}" --format=color -f "${FILE_ON_TARGET}" &
    LOGCAT_PID=$!
    echo "=== logcat started, pid: ${LOGCAT_PID}, press ENTER to fetch..."
    read
    stop_logcat
    echo "=== logcat stopped, pulling the file..."

    $ADB -s "${ARG_SERIAL}" pull "${FILE_ON_TARGET}" "${ARG_OUTPUT_DIR}/"
    $ADB -s "${ARG_SERIAL}" shell rm "${FILE_ON_TARGET}"
    cat "${ARG_OUTPUT_DIR}/${FILE}" | ack --nocolor --smart-case "$ARG_PREVIEW_FILTER"
    echo "^ preview of ${ARG_OUTPUT_DIR}/${FILE}; ${ARG_PREVIEW_FILTER} ^"
  else
    #$ADB -s "${ARG_SERIAL}" logcat --format=color | tee "$ARG_OUTPUT_DIR/logcat-$DATE.txt" | ack --nocolor --smart-case "$ARG_PREVIEW_FILTER"
    $ADB -s "${ARG_SERIAL}" logcat "${NEVER_SHOW}" "${ARG_PID}" --format=color | tee "$ARG_OUTPUT_DIR/logcat-$DATE.txt" | ack --nocolor --smart-case "$ARG_PREVIEW_FILTER"
  fi

done





