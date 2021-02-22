#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

FONT=$(getarg FONT)
[ -z "$FONT" ] && FONT="ter-124b"

if [ -f ${NEWROOT}/etc/vconsole.conf ]; then
    sed -e "s,^FONT=.*,FONT=$FONT," -i $NEWROOT/etc/vconsole.conf
elif [ -f ${NEWROOT}/etc/rc.conf ]; then
    sed -e "s,^#FONT=.*,FONT=$FONT," -i $NEWROOT/etc/rc.conf
fi
