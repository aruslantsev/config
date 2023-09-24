#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Usage: ${0} [PATH] [NUM_FILES]"
	exit 1
fi

find $1 -type f -exec stat --format '%Y :%y %n' "{}" \; | sort -nr | cut -d: -f2- | head -n $2
