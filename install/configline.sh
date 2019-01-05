#!/bin/bash

# include some helper functions

_SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$_SCRIPTDIR" ]]; then _SCRIPTDIR="$PWD"; fi
_SCRIPTDIR=`realpath $_SCRIPTDIR`
. "$_SCRIPTDIR/../script/sourceme/pretty.sh"

# check if all params provided

_CONFIG_FILE=~/.bash_aliases
if [ ! -z $2 ]; then
        _CONFIG_FILE=$2
fi

_USAGE="
Usage:
   $ `basename $0` CONFIG_LINE [CONFIG_FILE]

   Adds CONFIG_LINE to CONFIG_FILE (default: ~/.bash_aliases)
"
[[ $# -gt 0 ]] || printffail "$_USAGE"

# check args valid

_CONFIG_LINE=$1
[[ -f $_CONFIG_FILE ]] || printffail "Config file '$_CONFIG_FILE' does ${cRED}not${cNC} exist\n"



# install

printf "Adding ${cGREEN}$_CONFIG_LINE${cNC} to ${cGREEN}$_CONFIG_FILE${cNC}\n"
echo "$_CONFIG_LINE" >> $_CONFIG_FILE

