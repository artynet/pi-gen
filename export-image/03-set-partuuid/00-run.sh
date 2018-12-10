#!/bin/bash -e

# IMG_FILE must be the same as in ../prerun.sh
IMG_LONGNAME=${IMG_NAME}_${SUSI_BRANCH}_${IMG_DATE}_PR${SUSI_PULL_REQUEST}_rev${SUSI_REVISION:0:7}
IMG_FILE="${STAGE_WORK_DIR}/${IMG_LONGNAME}.img"

IMGID="$(dd if="${IMG_FILE}" skip=440 bs=1 count=4 2>/dev/null | xxd -e | cut -f 2 -d' ')"

BOOT_PARTUUID="${IMGID}-01"
ROOT_PARTUUID="${IMGID}-02"

sed -i "s/BOOTDEV/PARTUUID=${BOOT_PARTUUID}/" "${ROOTFS_DIR}/etc/fstab"
sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "${ROOTFS_DIR}/etc/fstab"

sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "${ROOTFS_DIR}/boot/cmdline.txt"
