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

# prepare functions to fail
exit_on_error() {
   exit_code=$1
   last_command=${@:2}
   if [ $exit_code -ne 0 ]; then
      >&2 echo "\"${last_command}\" command failed with exit code ${exit_code}."
      exit $exit_code
   fi
}
# enable !! command completion
set -o history -o histexpand

# check if git can access the key
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
git clone git@github.com:nazgee/keystore.git $tmp_dir
exit_on_error $? !!

# install

printf "Installing ${cGREEN}$_TARGET${cNC} in $_INSTALLDIR; $_CONFIG_FILE used as config file\n"


sudo apt-get install golang-go gnupg git rng-tools xclip
GO111MODULE=on go get github.com/gopasspw/gopass
$_SCRIPTDIR/configline.sh "PATH=\$PATH:$_INSTALLDIR/bin" $_CONFIG_FILE
. $_CONFIG_FILE
gopass --yes setup --remote git@github.com:nazgee/keystore.git --alias nazgee --name "Michal Stawinski" --email "michal.stawinski@gmail.com"

