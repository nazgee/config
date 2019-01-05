#!/bin/bash

# include some helper functions

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../script/sourceme/pretty.sh"


# check if all params provided

_CONFIG_FILE=~/.bash_aliases
if [ ! -z $2 ]; then
        _CONFIG_FILE=$2
fi

_USAGE="
Usage:
   $ `basename $0` INSTALL_DIR [CONFIG_FILE]

   Clones dirb to INSTALL_DIR/dirb and appends config line to CONFIG_FILE (default: ~/.bash_aliases)
"
[[ $# -gt 0 ]] || printffail "$_USAGE"


# check args valid

_INSTALLDIR=`realpath $1`
[[ -d $_INSTALLDIR ]] || printffail "'$_INSTALLDIR' directory is ${cRED}invalid${cNC}\n"
_SRCDIR=$_INSTALLDIR/dirb
[[ ! -d $_SRCDIR ]] || printffail "'$_SRCDIR' directory ${cRED}already exists${cNC}\n"
[[ -f $_CONFIG_FILE ]] || printffail "Config file '$_CONFIG_FILE' does ${cRED}not${cNC} exist\n"



# install

printf "Installing ${cGREEN}dirb${cNC} in $_SRCDIR; $_CONFIG_FILE used as config file\n"

cd $_INSTALLDIR
git clone https://github.com/icyfork/dirb
echo "source $_SRCDIR/dirb.sh" >> $_CONFIG_FILE

