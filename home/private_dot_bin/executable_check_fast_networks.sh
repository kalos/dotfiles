#!/usr/bin/env bash

# desegno
MAC_ADDRESSES="00:0d:b9:49:b7:64
00:00:5e:00:01:04
00:00:5e:00:01:05
00:0d:b9:49:b4:1c"

# casa kalos & ely
MAC_ADDRESSES="${MAC_ADDRESSES}
10:13:31:d6:2d:ee"

# casa genitori (b&b)
MAC_ADDRESSES="${MAC_ADDRESSES}
04:81:9b:6f:8b:21"

# check connectivity and if it's metered
if [[ $(nmcli networking connectivity check) = 'full' ]] && [[ "$(nmcli -t -f GENERAL.METERED dev show `ip route list 0/0 |head -1| sed -r 's/.*dev (\S*).*/\1/g'` | cut -d':' -f2)" != yes* ]]
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
