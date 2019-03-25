#!/bin/bash

sudo -u pi mkdir /home/pi/SUSI.AI
cd /home/pi/SUSI.AI && sudo -u pi git clone https://github.com/fossasia/susi_linux.git

# Purge Java, try to fix "the trustAnchors parameter must be non-empty" error. Ref: https://askubuntu.com/a/1006748/5871
apt-get purge -y openjdk* java-common ca-certificates-java

# Run SUSI Linux's install script
# add a change to the susi linux install script to 
# change the seeed-voicecard install script to ignore build machine
# to allow building in chroot
cd /home/pi/SUSI.AI/susi_linux && git checkout "$SUSI_REVISION" && \
	sed -i -e 's/cd seeed-voicecard/cd seeed-voicecard\nsed -i -e "s%^is_Raspberry=.*%is_Raspberry=Raspberry%" install.sh/' install.sh && \
	sudo -Hu pi ./install.sh

# After ./install.sh, the /dev is occupied by some processes and cannot be released by build script.
# We stop those processes to let the build script continue.

systemctl stop seeed-voicecard
systemctl stop systemd-udevd
sleep 5
