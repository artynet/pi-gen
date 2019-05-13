#!/bin/bash

PWD=`pwd`

################
# try to fix debootstrap 
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=921815
# https://salsa.debian.org/installer-team/debootstrap/merge_requests/26
currdir=$PWD
pushd /usr/share/debootstrap
patch -p1 < "$currdir/fix-debootstrap-proc.patch"
popd
########## end fixing debootstrap

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
# Delete old builds
sudo rm -rf "$updir/Work/stage2.5"
sudo rm -rf "$updir/Work/export-image"
sudo rm -rf "$updir/Deploy"
# If $FULL_BUILD is not set and the Work/stage2/rootfs folder exists, we do incremental build, based on Raspbian Lite (stage2).
if [ -z "$FULL_BUILD" ] && [ -d "$updir/Work/stage2.4/rootfs" ]; then
	touch ./stage0/SKIP ./stage1/SKIP ./stage2/SKIP ./stage2.4/SKIP
else 
	rm -f ./stage0/SKIP ./stage1/SKIP ./stage2/SKIP ./stage2.4/SKIP
	sudo rm -rf "$updir/Work"
fi
if [ -z "$FULL_BUILD" ] && [ -d "$updir/Work/stage2.4/rootfs" ]; then
	sudo CLEAN=1 bash ./build.sh 2>&1 | tee build.log
else
	sudo bash ./build.sh 2>&1 | tee build.log
fi

