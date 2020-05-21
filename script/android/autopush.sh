#!/bin/bash

# root device and remount filesystem
#adb root && sleep 2s && adb remount && sleep 1s

# add some colors
WHITE='\033[1;37m'
GREEN='\033[0;32m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

FAILED=0
SUCCEDED=0
STATICLIB=0
FAILLIST=()
while read line; do
    if [[ $(echo $line | grep 'Install:') != '' ]]
    then
        path=`echo "$line" | sed 's/.*Install: //'`
        pathremote=`echo $path | sed 's:out/target/product/[^/]*::'`

        printf "${GREEN}Install:${NC} ${WHITE}${ANDROID_BUILD_TOP}/${path}${NC} to ${WHITE}$(dirname $pathremote)${NC}\n"
        adb push "$ANDROID_BUILD_TOP/$path" $pathremote

        if [ $? -ne 0 ]
        then
            FAILED=$((FAILED+1))
            FAILLIST+=($pathremote\n)
	    printf "${RED}Failed to install $pathremote ${NC}\n"
        else
            SUCCEDED=$((SUCCEDED+1))
        fi
    elif [[ $(echo $line | grep '^target StaticLib:') != '' ]]
    then
        staticlib=`echo $line | awk '{print $3}'`
        STATICLIB=$((STATICLIB+1))
        printf "$line\n${PURPLE}Static:${NC} ${WHITE}$staticlib.a${NC}\n"
    else
        echo "$line"
    fi
done

printf "\n${GREEN}Pass${NC}: $SUCCEDED\n"

# print static lib if were
if [ $STATICLIB -ne 0 ]
then
    printf "${PURPLE}Stat${NC}: $STATICLIB\n"
fi

# print failed cases if were
if [ $FAILED -ne 0 ]
then
    printf "${RED}Fail${NC}: $FAILED\n\n"
    printf "${RED}--- Fail List ---${NC}\n"
    printf "${FAILLIST[@]}\n\n"
    exit 1
fi

# reboot at the end if everything goes fine
if [ $SUCCEDED -ne 0 ]
then
    printf "\nRebooting ...\n"
    #adb reboot
fi

printf "\n"
exit 0

