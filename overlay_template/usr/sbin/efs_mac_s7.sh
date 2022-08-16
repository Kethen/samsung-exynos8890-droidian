#!/bin/bash

tries=0
while true
do
	mac_address=$(cat /efs/wifi/.mac.info || true)
	if [ -n "$mac_address" ]
	then
		echo setting mac address $mac_address from /efs
		if ip link set wlan0 addr $mac_address
		then
			break
		else
			echo failed setting mac address using ip
			if [ $tries -lt 120 ]
			then
				echo trying again: $tries
			else
				break
			fi
		fi
	else
		echo failed retriving mac address from /efs
		if [ $tries -lt 120 ]
		then
			echo trying again: $tries
		else
			break
		fi
	fi
	tries=$((tries + 1))
	sleep 0.5
done
