#!/bin/bash
#

echo "Router will be available @ http://localhost:8080"
ssh michal@slow.hopto.org -p 22106 -L localhost:8080:192.168.0.1:80 -N
