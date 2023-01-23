#!/bin/bash

echo "Replace all occurences of '$2' to '$3' under '$1' directory recursively"

read -p "Are you sure? [Y/n]" -n 1 -r
echo 

if [[ $REPLY =~ ^[Yy]$ || $REPLY = '' ]]
then
	echo "Replacing..."
	find $1 -type f | xargs sed -i  "s|$2|$3|g"
fi
echo "Bye!"
