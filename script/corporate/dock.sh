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

docker run -u $(id -u ${USER}):$(id -g ${USER}) -v ~/.profile:/.profile -v ~/.bashrc:/.bashrc -v ~/.bash_aliases:/.bash_aliases -v ~/.config/OpenRGB:/.config/OpenRGB -v ~/work/extensions/config:/home/michal/work/extensions/config -v "${WORKSPACE}:${WORKSPACE}" -v ~/.gitconfig:/etc/gitconfig -v ~/qnx710:/qnx710 -v ~/flexserver:/flexserver -v ~/.qnx:/root/.qnx -v ~/.flexlmrc:/root/.flexlmrc -w "${WORKSPACE}" --add-host=host.docker.internal:host-gateway -i -t "${1}"
