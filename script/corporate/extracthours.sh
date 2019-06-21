#!/bin/bash
cat $1 | sed 's/.*sum="//; s/".*//; s|.*</div>||' | grep -v '^$'
