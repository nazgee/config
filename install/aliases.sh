#!/bin/bash

# include some helper functions

_SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$_SCRIPTDIR" ]]; then _SCRIPTDIR="$PWD"; fi
_SCRIPTDIR=`realpath $_SCRIPTDIR`
. "$_SCRIPTDIR/../script/sourceme/pretty.sh"

_ALIASPATH=$_SCRIPTDIR/../alias/

# check if all params provided

_CONFIG_FILE=~/.bash_aliases
if [ ! -z $2 ]; then
        _CONFIG_FILE=$2
fi

_USAGE="
Usage:
   $ `basename $0` ALIAS_FILE [CONFIG_FILE]

   Installs ALIAS_FILE in CONFIG_FILE (default: ~/.bash_aliases)
   Available ALIAS_FILEs:
`find $_ALIASPATH -name '*.alias'`
"
[[ $# -gt 0 ]] || printffail "$_USAGE"

# check args valid

_ALIAS=`realpath $1`
[[ -f $_ALIAS ]] || printffail "Alias '$_ALIASPATH' does not exist\n"
[[ -f $_CONFIG_FILE ]] || printffail "Config file '$_CONFIG_FILE' does ${cRED}not${cNC} exist\n"



# install

printf "Installing ${cGREEN}$_ALIAS${cNC} alias in ${cGREEN}$_CONFIG_FILE${cNC}\n"
$_SCRIPTDIR/configline.sh "source $_ALIAS" $_CONFIG_FILE

