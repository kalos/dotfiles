#!/usr/bin/env bash

# desegno
MAC_ADDRESSES="00:0d:b9:49:b7:64
00:00:5e:00:01:04
00:00:5e:00:01:05
00:0d:b9:49:b4:1c"

# check connectivity
if [[ $(nmcli networking connectivity check) = 'full' ]]
then
    # save local macs
    local_macs="$(ip neigh)"

    # cycle accepted macs
    for whitelist_mac in "${MAC_ADDRESSES}"; do

        # return 0 if there is a whitelist mac in a local macs
        if [[ -n $(echo "${local_macs}" | grep "$whitelist_mac") ]]
        then
	    exit 0
        fi
    done
fi

# return 1 if there isn't whitelist mac
exit 1
