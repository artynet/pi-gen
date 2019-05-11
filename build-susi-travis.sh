#!/bin/bash

PWD=`pwd`

# Add config
updir="$(realpath ..)"
echo "IMG_NAME='SUSIbian'" > config
#echo -e "APT_PROXY=http://localhost:3142" >> config
echo -e "APT_PROXY=$APT_PROXY" >> config
echo -e "WORK_DIR=$updir/Work" >> config
echo -e "DEPLOY_DIR=$updir/Deploy" >> config

# Don't zip image. We will compress with xz in our way.
echo -e "DEPLOY_ZIP=0" >> config

# Create folder to cache Pip stuff
DIR_CACHE_PIP="$updir/Pip-cache"
[ -f "$DIR_CACHE_PIP" ] && rm "$DIR_CACHE_PIP"
[ ! -d "$DIR_CACHE_PIP" ] && mkdir "$DIR_CACHE_PIP"
echo -e "DIR_CACHE_PIP=$DIR_CACHE_PIP" >> config


# SUSI_REVISION, SUSI_BRANCH, SUSI_PULL_REQUEST is passed from parent Pipeline
echo -e "SUSI_REVISION=$SUSI_REVISION" >> config
echo -e "SUSI_BRANCH=$SUSI_BRANCH" >> config
echo -e "SUSI_PULL_REQUEST=$SUSI_PULL_REQUEST" >> config

# Tell pi-gen to skip the phases which are to build desktop image
touch ./stage3/SKIP ./stage4/SKIP ./stage5/SKIP
touch ./stage2/SKIP_IMAGES ./stage2.4/SKIP_IMAGES ./stage4/SKIP_IMAGES ./stage5/SKIP_IMAGES

# for travis builds we use pre-build stage2.4 files
touch ./stage2.4/SKIP

# Delete old builds
sudo rm -rf "$updir/Work/stage2.5"
sudo rm -rf "$updir/Work/export-image"
sudo rm -rf "$updir/Deploy"

wget -O "$updir/stage2.4.tar.xz" http://www.preining.info/susi.ai/stage2.4.tar.xz
mkdir -p "$updir/Work"
tar -C "$updir/Work" -xjf "$updir/stage2.4.tar.xz"
touch ./stage0/SKIP ./stage1/SKIP ./stage2/SKIP ./stage2.4/SKIP
sudo CLEAN=1 bash ./build.sh 2>&1 | tee build.log

