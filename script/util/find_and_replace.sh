#!/bin/bash

[ $# -ge 2 ] || {
	echo "Usage:"
	echo "$(basename $0) MATCH REPLACE [DIR]"
	echo "Replace all occurences of MATCH to REPLACE in all files under DIR"
	exit 1
}

DIR="${3:-.}"
MATCH="${1}"
REPLACE="${2}"

echo "Replace all occurences of '$MATCH' to '$REPLACE' in all files under '$DIR'"

read -p "Are you sure? [Y/n]" -n 1 -r
echo 

if [[ $REPLY =~ ^[Yy]$ || $REPLY = '' ]]
then
	echo "Replacing..."
	find $DIR -type f | xargs sed -i  "s|$MATCH|$REPLACE|g"
fi
echo "Bye!"
