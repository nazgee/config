#!/bin/bash
_reportname="$HOME/PDF/attachment - `date +%Y.%m` - Stawinski Michal.pdf"
_targetfile="$HOME/PDF/Crystal_Reports_ActiveX_Designer_-_WorkingTimeExternNear_s__e.g-job_`ls ~/PDF/ | grep Crystal_Reports_ActiveX_Designer | sed 's/\.pdf//; s/.*job_//' | sort -g | tail -n 1`.pdf"

echo $_targetfile

if [ -f $_targetfile ]; then
#	echo $_reportname | xclip -selection c
#	echo "'$_reportname' copied to clipboard"
	cp "$_targetfile" "$_reportname"
	echo "$_reportname" | xclip -selection c
else
	echo "Oops... do it manually"	
fi
