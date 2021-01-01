#!/bin/sh
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh
USERNAME=$(getarg live.user)
[ -z "$USERNAME" ] && USERNAME=anon

if [ -x ${NEWROOT}/usr/bin/enlightenment_start ]; then
    SESSION="enlightenment.desktop"
elif [ -x ${NEWROOT}/usr/bin/startxfce4 ]; then
    SESSION="xfce.desktop"
elif [ -x ${NEWROOT}/usr/bin/mate-session ]; then
    SESSION="mate.desktop"
elif [ -x ${NEWROOT}/usr/bin/cinnamon-session ]; then
    SESSION="cinnamon.desktop"
elif [ -x ${NEWROOT}/usr/bin/plasma_session ]; then
    SESSION="plasma.desktop"
elif [ -x ${NEWROOT}/usr/bin/gnome-session ]; then
    SESSION="gnome.desktop"
elif [ -x ${NEWROOT}/usr/bin/i3 ]; then
    SESSION="i3.desktop"
elif [ -x ${NEWROOT}/usr/bin/startlxde ]; then
    SESSION="lxde.desktop"
elif [ -x ${NEWROOT}/usr/bin/startlxqt ]; then
    SESSION="lxqt.desktop"
elif [ -x ${NEWROOT}/usr/bin/startfluxbox ]; then
    SESSION="fluxbox.desktop"
fi

# Configure GDM autologin
if [ -d ${NEWROOT}/etc/gdm ]; then
    GDMCustomFile=${NEWROOT}/etc/gdm/custom.conf
    AutologinParameters="AutomaticLoginEnable=true\nAutomaticLogin=$USERNAME"

    # Prevent from updating if parameters already present (persistent usb key)
    if ! `grep -qs 'AutomaticLoginEnable' $GDMCustomFile` ; then
        if ! `grep -qs '\[daemon\]' $GDMCustomFile` ; then
            echo '[daemon]' >> $GDMCustomFile
        fi
        sed -i "s/\[daemon\]/\[daemon\]\n$AutologinParameters/" $GDMCustomFile
    fi
fi

# Configure sddm autologin for the desktop environment iso.
if [ -x ${NEWROOT}/usr/bin/sddm ]; then
    cat > ${NEWROOT}/etc/sddm.conf <<_EOF
[Autologin]
User=$USERNAME
Session=$SESSION
_EOF
fi

# Configure lightdm autologin.
if [ -r ${NEWROOT}/etc/lightdm.conf ]; then
    sed -i -e "s|^\#\(autologin-user=\).*|\1$USERNAME|" \
        ${NEWROOT}/etc/lightdm.conf
    sed -i -e "s|^\#\(default-user=\).*|\1$USERNAME|" \
        ${NEWROOT}/etc/lightdm.conf
    sed -i -e "s|^\#\(default-user-timeout=\).*|\10|" \
        ${NEWROOT}/etc/lightdm.conf
fi

# Configure lxdm autologin.
if [ -r ${NEWROOT}/etc/lxdm/lxdm.conf ]; then
    sed -e "s,.*autologin.*=.*,autologin=$USERNAME," -i ${NEWROOT}/etc/lxdm/lxdm.conf
    for f in enlightenment_start startxfce4 mate-session cinnamon-session \
          startlxde startlxqt startfluxbox plasma_session gnome-session i3; do
    	! [ -x ${NEWROOT}/usr/bin/$f ] && continue
        sed -e "s,.*session.*=.*,session=/usr/bin/$f," -i ${NEWROOT}/etc/lxdm/lxdm.conf
        break
    done
fi
