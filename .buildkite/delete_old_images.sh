#!/bin/bash

if [ -z "$1" ]
then
	echo "Missing SSH host"
	exit 1
fi

SSH_HOST="$1"
# shellcheck disable=SC2088
REMOTE_FOLDER="~/releases"
# Get the list of old files. Ignore the 3 most recent files.
FILE_LIST=$(ssh $SSH_HOST "ls -t $REMOTE_FOLDER/*.xz" | tail -n +4 | xargs)
if [[ -n $FILE_LIST ]]; then
	echo "Delete: $FILE_LIST"
	ssh $SSH_HOST "rm $FILE_LIST"
fi
