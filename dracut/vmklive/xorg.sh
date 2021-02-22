#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

XORG_SIZE=$(getarg XORG_SIZE)
[ -z "$XORG_SIZE" ] && XORG_SIZE="1280x960"

if [ ! -f ${NEWROOT}/etc/X11/xorg.conf ]; then
    mkdir -p ${NEWROOT}/etc/X11/
    cat > ${NEWROOT}/etc/X11/xorg.conf <<EOF
Section "Screen"
	Identifier "Screen0"
	SubSection "Display"
		Modes "${XORG_SIZE}"
	EndSubSection
EndSection
EOF
fi
