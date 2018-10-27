#!/bin/bash

sudo -u pi mkdir /home/pi/SUSI.AI
cd /home/pi/SUSI.AI && sudo -u pi git clone --single-branch https://github.com/fossasia/susi_linux.git

# Purge Java, try to fix "the trustAnchors parameter must be non-empty" error. Ref: https://askubuntu.com/a/1006748/5871
apt-get purge -y openjdk* java-common ca-certificates-java

# Run SUSI Linux's install script
cd /home/pi/SUSI.AI/susi_linux && sudo -Hu pi ./install.sh

# After ./install.sh, the /dev is occupied by some processes and cannot be released by build script.
# We stop those processes to let the build script continue.

systemctl stop seeed-voicecard
systemctl stop systemd-udevd
sleep 5
