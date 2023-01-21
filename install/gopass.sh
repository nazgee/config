#!/bin/bash

# include some helper functions

_SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$_SCRIPTDIR" ]]; then _SCRIPTDIR="$PWD"; fi
_SCRIPTDIR=`realpath $_SCRIPTDIR`
. "$_SCRIPTDIR/../script/sourceme/pretty.sh"


_CONFIG_FILE=~/.bash_aliases
if [ ! -z $1 ]; then
        _CONFIG_FILE=$1
fi

_TARGET="gopass"

_USAGE="
Usage:
   $ `basename $0` [CONFIG_FILE]

   Installs gopass and appends config line to CONFIG_FILE (default: ~/.bash_aliases)
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
go install github.com/gopasspw/gopass@latest
$_SCRIPTDIR/configline.sh "PATH=\$PATH:~/go/bin" $_CONFIG_FILE
. $_CONFIG_FILE
gopass --yes setup --remote git@github.com:nazgee/keystore.git --alias nazgee --name "Michal Stawinski" --email "michal.stawinski@gmail.com"

