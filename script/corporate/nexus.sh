#!/bin/bash

# edit these 2
username=`cat ~/.nexus_user`
password=`cat ~/.nexus_pass`


dirname="${username}"
proto="http://"
server="10.140.3.215:30238"
#server="100.64.1.11:30501"
repo="repository/dev-flash-packages"
serverrepo="${server}/${repo}"
binname=`basename $0`

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NORMAL="\033[0m"

UP=0
DOWN=0
FILE=""
EXTRACT=0
DIR=0
KEEPPATH=0

function upload {
	local filename=`basename "$1"`
	nfo "uploading \"${filename}\" to \"${proto}${serverrepo}/${dirname}/${filename}\" ..."
	# use PIPASTATUs to check curl status, not grep
	if curl --fail --user "${username}:${password}" -T $1 ${proto}${serverrepo}/${dirname}/${filename} -# | tee -a /dev/null ; test ${PIPESTATUS[0]} -eq 0; then
		nfo "upload ok"
	else
		err "upload failed"
	fi
}

function download_curl() {
	local filename=`basename "$1"`
	if [ ${KEEPPATH} -eq 1 ]; then
		filename="$1"
	fi
	if curl --fail --user "${username}:${password}" -o $1 ${proto}${serverrepo}/${dirname}/$filename; then
		nfo "download ok"
	else
		err "download failed"
	fi
}

function download_axel() {
	local filename=`basename "$1"`
	if [ ${KEEPPATH} -eq 1 ]; then
		filename="$1"
	fi
	#echo "cmd: axel ${proto}${username}:${password}@${serverrepo}/${dirname}/${filename}"
	# use PIPASTATUs to check axel status, not grep or awk
	# hide password using grep. grep makes ncurses output multiline, so use awk to squeze it into one line
	if axel "${proto}${username}:${password}@${serverrepo}/${dirname}/${filename}" | grep -v --line-buffered "Initializing download" | awk '{printf "\r%s                                                           ",$0}'; test ${PIPESTATUS[0]} -eq 0;
	then
		echo ""
		nfo "download ok"
	else
		echo ""
		wrn "\"axel\" failed, trying \"curl\"..."
		download_curl "$1"
	fi
}

function download {
	local filename=`basename "$1"`
	if [ ${KEEPPATH} -eq 1 ]; then
		filename="$1"
	fi
	nfo "downloading \"${proto}${serverrepo}/${dirname}/${filename}\" to \"$1\" ..."
	if [ -f $1 ]; then
		wrn "$1 already exists, removing it before re-downloading..."
		rm $1
	fi

	if command -v axel > /dev/null
	then
		msg "using \"axel\", fast mode"
		download_axel "$1"
	else
		msg "using \"curl\", normal mode (install \"axel\" to enable fast mode: \"sudo apt install axel\""
		download_curl "$1"
	fi
}

smart-extract() {
    if [[ "$1" == *.gz ]]; then
        if command -v pigz > /dev/null 2>&1; then
            tar -I pigz -xf "$1";
        else
            tar -xzf "$1";
        fi;
    else
        if [[ "$1" == *.xz ]]; then
            if command -v pxz > /dev/null 2>&1; then
                tar -I 'pxz -d' -xf "$1";
            else
                tar -xJf "$1";
            fi;
        else
            err "Unknown file type: $1";
        fi;
    fi
}


function extract() {
	local DIRNAME="${FILE%%.*}"
	mkdir "$DIRNAME" -p
	nfo "unpacking \"$FILE\"..."
	mv "${FILE}" "${DIRNAME}/"
	cd "$DIRNAME"
	smart-extract "${FILE}"
}

function msg() {
	printf ">>> ${1}\n"
}

function nfo() {
	printf ">>> ${GREEN}${1}${NORMAL}\n"
}

function wrn() {
	printf ">>> ${YELLOW}${1}${NORMAL}\n"
}

function err() {
	printf ">>> ${RED}${1}${NORMAL}\n"
}

function help() {
	echo "Usage:"
	echo ""
	echo "to download a file from nexus:"
	echo "   ${binname} [--dir DIR] --up PATH_TO_FILE "
	echo "to upload a file to nexus:"
	echo "   ${binname} [--dir DIR] [--extract] --down FILE"
	echo ""
	echo "OPTIONS:"
	echo "  --up PATH_TO_FILE         upload FILE from PATH_TO_FILE to ${serverrepo}/${dirname}/FILE"
	echo "                            (using curl)"
	echo "  --prv  BUILDNUM           download ${serverrepo}/CI/HQX-CI-sg3/<BUILDNUM>/jenkins-HQX-CI-sg3-<BUILDNUM>.tar.xz"
	echo "  --down FILE               download ${serverrepo}/${dirname}/FILE to current directory"
	echo "                            (using axel if available, curl if axel not isntalled)"
	echo "  --extract                 extract downloaded .tar.gz FILE after download"
	echo "                            (using pigz, multithreaded)"
	echo "  --dir DIR                 change nexus DIR from default \"${serverrepo}/${dirname}\" to \"${server}/${repo}/DIR\""
	echo "  --keeppath                keep filename as-is (normally, basename would be extracted, e.g. foo/bar.sh would become bar.sh)"
}

while [[ $# -gt 0 ]]; do
	case $1 in
		--up)
			UP=1
			FILE="$2"
			shift
			shift
			;;
		--prv)
			buildnum="$2"
			DOWN=1
			FILE="jenkins-HQX-CI-sg3-${buildnum}.tar.xz"
			DIR=1
			dirname="CI/HQX-CI-sg3/${buildnum}"
			shift
			shift
			;;
		--down)
			DOWN=1
			FILE="$2"
			shift
			shift
			;;
		--extract)
			EXTRACT=1
			shift
			;;
		--keeppath)
			KEEPPATH=1
			shift
			;;
		--dir)
			dirname="$2"
			DIR=1
			shift
			shift
			;;
		--help)
			help
			exit 0
			;;
		*)
			err "Unknown option \"${1}\""
			help
			exit 1
	esac
done

if [[ -z ${UP} && -z ${DOWN} ]]; then
	err "--up and --down are mutually exclusive"
	help
	exit 1
fi

if [ ${UP} -eq 1 ]; then
	upload "$FILE"
fi

if [ ${DOWN} -eq 1 ]; then
	download "$FILE"
	if [ ${EXTRACT} -eq 1 ]; then
		extract "$FILE"
	fi
fi
