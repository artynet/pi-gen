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

SSH_HOST="$1"
REMOTE_FOLDER="~/releases"

# Create remote folder for upload
UPLOADING_DIR="~/uploading/$BUILDKITE_AGENT_NAME"
ssh "$SSH_HOST" "mkdir $UPLOADING_DIR || true"
set -x  # Enable debugging
# Upload the image file to SSH host
scp "$IMG_PATH" "$SSH_HOST":"$UPLOADING_DIR/"
# Move the file to FTP's root document folder
ssh "$SSH_HOST" "mv $UPLOADING_DIR/$IMG_FILENAME $REMOTE_FOLDER"
set +x  # Disable debugging
