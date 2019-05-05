#!/bin/bash

# include some helper functions

_SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$_SCRIPTDIR" ]]; then _SCRIPTDIR="$PWD"; fi
_SCRIPTDIR=`realpath $_SCRIPTDIR`
. "$_SCRIPTDIR/../script/sourceme/pretty.sh"


# check if all params provided
_INSTALLDIR=`realpath ~/go`
if [ ! -z $1 ]; then
        _INSTALLDIR=`realpath $1`
fi

_CONFIG_FILE=~/.bash_aliases
if [ ! -z $2 ]; then
        _CONFIG_FILE=$2
fi

_TARGET="gopass"

_USAGE="
Usage:
   $ `basename $0` [INSTALL_DIR] [CONFIG_FILE]

   Installs gopass in INSTALL_DIR/bin (default: ~/go) and appends config line to CONFIG_FILE (default: ~/.bash_aliases)
"
#[[ $# -gt 3 ]] || printffail "$_USAGE"


# check args valid

[[ -f $_CONFIG_FILE ]] || printffail "Config file '$_CONFIG_FILE' does ${cRED}not${cNC} exist\n"


export GOPATH=$_INSTALLDIR

# install

printf "Installing ${cGREEN}$_TARGET${cNC} in $_INSTALLDIR; $_CONFIG_FILE used as config file\n"


sudo apt-get install golang-go gnupg git rng-tools xclip
go get github.com/gopasspw/gopass
$_SCRIPTDIR/configline.sh "PATH=\$PATH:$_INSTALLDIR/bin" $_CONFIG_FILE
. $_CONFIG_FILE
gopass --yes setup --remote git@github.com:nazgee/keystore.git --alias nazgee --name "Michal Stawinski" --email "michal.stawinski@gmail.com"

