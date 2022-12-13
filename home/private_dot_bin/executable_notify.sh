#!/usr/bin/env bash

# Send desktop notification (Xorg & Wayland support)
#
# Example:
#  /home/kalos/.bin/notify.sh -u critical restic-age "backup is too old!"

# detect the user id of the user logged in
_EUID=$(loginctl | head -n2 | tail -1 |  sed -e 's/^[ \t]*//' | cut -f2 -d' ')

# if var il already set, skip export
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    if [ -S /run/user/$_EUID/bus ]; then
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$_EUID/bus"
    else
        SESSION=$(loginctl -p Display show-user "$LOGNAME" | cut -d= -f2)
        [ -z "$SESSION" ] && exit
        LEADER=$(loginctl -p Leader show-session "$SESSION" | cut -d= -f2)
        [ -z $LEADER ] && exit
        OLDEST=$(pgrep -o -P $LEADER)
        [ -z $OLDEST ] && exit
        export $(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$OLDEST/environ)
        [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && exit
    fi
fi

# use sudo with UID to send notification (configure sudo properly)
sudo -u '#'$_EUID DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS} notify-send "$@"
