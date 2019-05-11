#!/bin/bash -e

set -x

IMG_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"
INFO_FILE="${STAGE_WORK_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.info"

on_chroot << EOF
/etc/init.d/fake-hwclock stop
hardlink -t /usr/share/doc
EOF

if [ -d "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config" ]; then
	chmod 700 "${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config"
fi

rm -f "${ROOTFS_DIR}/etc/apt/apt.conf.d/51cache"
rm -f "${ROOTFS_DIR}/usr/bin/qemu-arm-static"

rm -f "${ROOTFS_DIR}/etc/apt/sources.list~"
rm -f "${ROOTFS_DIR}/etc/apt/trusted.gpg~"

rm -f "${ROOTFS_DIR}/etc/passwd-"
rm -f "${ROOTFS_DIR}/etc/group-"
rm -f "${ROOTFS_DIR}/etc/shadow-"
rm -f "${ROOTFS_DIR}/etc/gshadow-"
rm -f "${ROOTFS_DIR}/etc/subuid-"
rm -f "${ROOTFS_DIR}/etc/subgid-"

rm -f "${ROOTFS_DIR}"/var/cache/debconf/*-old
rm -f "${ROOTFS_DIR}"/var/lib/dpkg/*-old

rm -f "${ROOTFS_DIR}"/usr/share/icons/*/icon-theme.cache

rm -f "${ROOTFS_DIR}/var/lib/dbus/machine-id"

true > "${ROOTFS_DIR}/etc/machine-id"

ln -nsf /proc/mounts "${ROOTFS_DIR}/etc/mtab"

find "${ROOTFS_DIR}/var/log/" -type f -exec cp /dev/null {} \;

rm -f "${ROOTFS_DIR}/root/.vnc/private.key"
rm -f "${ROOTFS_DIR}/etc/vnc/updateid"

update_issue "$(basename "${EXPORT_DIR}")"
install -m 644 "${ROOTFS_DIR}/etc/rpi-issue" "${ROOTFS_DIR}/boot/issue.txt"
install files/LICENSE.oracle "${ROOTFS_DIR}/boot/"


cp "$ROOTFS_DIR/etc/rpi-issue" "$INFO_FILE"

ROOT_DEV="$(mount | grep "${ROOTFS_DIR} " | cut -f1 -d' ')"

unmount "${ROOTFS_DIR}"
zerofree "${ROOT_DEV}"

unmount_image "${IMG_FILE}"

mkdir -p "${DEPLOY_DIR}"

rm -f "${DEPLOY_DIR}/${ZIP_FILENAME}${IMG_SUFFIX}.zip"
rm -f "${DEPLOY_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"

if [ "${DEPLOY_ZIP}" == "1" ]; then
	pushd "${STAGE_WORK_DIR}" > /dev/null
	zip "${DEPLOY_DIR}/${ZIP_FILENAME}${IMG_SUFFIX}.zip" \
		"$(basename "${IMG_FILE}")"
	popd > /dev/null
else
	cp "$IMG_FILE" "$DEPLOY_DIR"
fi

# FOSSASIA customization: Compress image with xz

# Remove file copied in the above step and possible remnant compressed images
rm -f "${DEPLOY_DIR}/${IMG_FILENAME}${IMG_SUFFIX}.img"
rm -f "${DEPLOY_DIR}/${IMG_FILENAME}.img.xz"

pushd "${STAGE_WORK_DIR}" > /dev/null

echo "Compressing $IMG_FILE..."
xz -T0 -c "$(basename "${IMG_FILE}")" > "${DEPLOY_DIR}/${IMG_FILENAME}.img.xz"

popd > /dev/null

cp "$INFO_FILE" "$DEPLOY_DIR"
