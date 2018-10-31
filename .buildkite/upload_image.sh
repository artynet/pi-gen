#!/bin/bash
set -euo pipefail

SCRIPT_PATH=$(realpath "$0")
DIR_PATH=$(dirname "$SCRIPT_PATH")
DEPLOY_PATH=$(realpath "$DIR_PATH"/../../Deploy)

IMG_PATH=$(find "$DEPLOY_PATH" -name "*.img.xz" -type f | tail -n1)
IMG_FILENAME=$(basename "$IMG_PATH")

if [ -z "$1" ]
then
	echo "Missing SSH host"
	exit 1
fi
if [ -z "$2" ]
then
	echo "Missing remote folder for uploading"
	exit 1
fi
SSH_HOST="$1"
REMOTE_FOLDER="$2"

# Create remote folder for upload
ssh "$SSH_HOST" "mkdir /tmp/$BUILDKITE_ORGANIZATION_SLUG || true"
set -x  # Enable debugging
# Upload the image file to SSH host
scp "$IMG_PATH" "$SSH_HOST":/tmp/$BUILDKITE_ORGANIZATION_SLUG/
# Move the file to FTP's root document folder
ssh "$SSH_HOST" "mv /tmp/$BUILDKITE_ORGANIZATION_SLUG/$IMG_FILENAME $REMOTE_FOLDER"
set +x  # Disable debugging
