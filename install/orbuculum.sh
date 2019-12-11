#!/bin/bash

# include some helper functions

_SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$_SCRIPTDIR" ]]; then _SCRIPTDIR="$PWD"; fi
_SCRIPTDIR=`realpath $_SCRIPTDIR`
. "$_SCRIPTDIR/../script/sourceme/pretty.sh"


# check if all params provided
_INSTALLDIR=`realpath ~/workspace`
if [ ! -z $1 ]; then
        _INSTALLDIR=`realpath $1`
fi

_CONFIG_FILE=~/.bash_aliases
if [ ! -z $2 ]; then
        _CONFIG_FILE=$2
fi

_TARGET="orbuculum"

_USAGE="
Usage:
   $ `basename $0` [INSTALL_DIR] [CONFIG_FILE]

   Installs gopass in INSTALL_DIR/orbuculum (default: ~/workspace) and appends config line to CONFIG_FILE (default: ~/.bash_aliases)
"

# check args valid

[[ -d $_INSTALLDIR ]] || printffail "Install dir '$_INSTALLDIR' does ${cRED}not${cNC} exist\n"
[[ -f $_CONFIG_FILE ]] || printffail "Config file '$_CONFIG_FILE' does ${cRED}not${cNC} exist\n"

# install

printf "Installing ${cGREEN}$_TARGET${cNC} in $_INSTALLDIR; $_CONFIG_FILE used as config file\n"


cd $_INSTALLDIR
git clone git@github.com:nazgee/orbuculum.git || printffail "Cloning repo failed\n"
$_SCRIPTDIR/configline.sh "export PATH=\$PATH:$_INSTALLDIR/orbuculum" $_CONFIG_FILE
. $_CONFIG_FILE

