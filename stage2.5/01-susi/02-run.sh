#!/bin/bash

lsof +c0 ${STAGE_DIR}/dev
on_chroot << EOF
systemcl stop systemd-udevd
EOF
