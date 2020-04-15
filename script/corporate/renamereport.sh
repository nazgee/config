#!/bin/bash

function get_date_delivered() {
        LAST_CURR_SEC=`date -d "-$(date +%d) days +1 month" +%s`
        LAST_PREV_SEC=`date -d "-$(date +%d) days -0 month" +%s`
        CURR_SEC=`date +%s`
        DELIVERED=`echo "$LAST_PREV_SEC  $CURR_SEC  $LAST_CURR_SEC" \
                | awk \
                        '($2 - $1) <= ($3 - $2) { \
                                printf $1 ; \
                        } ($2 - $1) > ($3 - $2) { \
                                print $3 ; \
                        }'`
        date -d "@$DELIVERED" +%Y.%m
}

_reportname="$HOME/PDF/attachment - $(get_date_delivered) - Stawinski Michal.pdf"
_targetfile="$HOME/PDF/Crystal_Reports_ActiveX_Designer_-_WorkingTimeExternNear_s__e.g-job_`ls ~/PDF/ | grep Crystal_Reports_ActiveX_Designer | sed 's/\.pdf//; s/.*job_//' | sort -g | tail -n 1`.pdf"

echo $_targetfile


if [ -f $_targetfile ]; then
#	echo $_reportname | xclip -selection c
#	echo "'$_reportname' copied to clipboard"
	cp "$_targetfile" "$_reportname"
	echo "$_reportname"
	echo "$_reportname" | xclip -selection c
else
	echo "Oops... do it manually"	
fi
