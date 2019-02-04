#!/bin/bash

# include some helper functions

_SCRIPTDIR="${BASH_SOURCE%/*}"
if [[ ! -d "$_SCRIPTDIR" ]]; then _SCRIPTDIR="$PWD"; fi
_SCRIPTDIR=`realpath $_SCRIPTDIR`
. "$_SCRIPTDIR/../script/sourceme/pretty.sh"

_ALIASPATH=$_SCRIPTDIR/../alias/

# check if all params provided

_CONFIG_FILE=~/.bash_aliases
if [ ! -z $1 ]; then
        _CONFIG_FILE=$2
fi

_USAGE="
Usage:
   $ `basename $0` [CONFIG_FILE]

   Adds 'script' director to CONFIG_FILE (default: ~/.bash_aliases)
"

# check args valid

[[ -f $_CONFIG_FILE ]] || printffail "Config file '$_CONFIG_FILE' does ${cRED}not${cNC} exist\n"

_BINDIR=`realpath $_SCRIPTDIR/../script`


# install

$_SCRIPTDIR/configline.sh "export PATH=\$PATH:$_BINDIR" $_CONFIG_FILE
$_SCRIPTDIR/configline.sh "export PATH=\$PATH:$_BINDIR/android" $_CONFIG_FILE
$_SCRIPTDIR/configline.sh "export PATH=\$PATH:$_BINDIR/util" $_CONFIG_FILE
$_SCRIPTDIR/configline.sh "export PATH=\$PATH:$_BINDIR/corporate" $_CONFIG_FILE

