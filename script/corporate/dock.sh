#!/usr/bin/bash

failexit() {
	echo "$1"
	echo ""
	usage
	exit 1
}

usage() {
	echo "Usage:"
	echo "   ${0} <DOCKER_IMAGE_TAG> <SOURCE_CODE_DIR>"
}

[ -z ${1} ] && failexit "no DOCKER_IMAGE_TAG provided, exiting"
[ -z ${2} ] && failexit "no SOURCE_CODE_DIR provided, exiting"
[ ! -d ${2} ] && failexit "invalid SOURCE_CODE_DIR provided, exiting"

WORKSPACE=`realpath "${2}"`

	#-u $(id -u ${USER}):$(id -g ${USER}) \
docker run \
	--cpus 31 \
	-m 48g \
	-u michal \
	-v ~/.profile:/home/michal/.profile -v ~/.bashrc:/home/michal/.bashrc -v ~/.bash_aliases:/home/michal/.bash_aliases -v ~/.config/OpenRGB:/home/michal/.config/OpenRGB \
	-v /mnt/work/extensions/config:/mnt/work/extensions/config \
	-v "${WORKSPACE}:${WORKSPACE}" -v ~/.gitconfig:/home/michal/gitconfig \
	-v ~/qnx710:/home/michal/qnx710 -v ~/flexserver:/home/michal/flexserver -v ~/.qnx:/home/michal/.qnx -v ~/.flexlmrc:/home/michal/.flexlmrc \
	-v ~/.cache:/home/michal/.cache \
	-v ~/.citnames:/home/michal/.citnames \
	-v ~/.shellb/:/home/michal/.shellb \
	-v ~/.shellbrc/:/home/michal/.shellbrc \
	-v /mnt/work/extensions/shellb:/mnt/work/extensions/shellb \
	-w "${WORKSPACE}" --add-host=host.docker.internal:host-gateway -i -t "${1}"
