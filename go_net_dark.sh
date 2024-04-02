#!/bin/bash

# Settings
# Allowed local open ports seperated by spaces.
whitelist="22 58 3350 3389"

# List Open Local Ports
# ss -alntuw | awk -F ' ' '{print $5}' | egrep -o ":((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$" | egrep -o "[0-9]+$" | sort -n --unique
localports="$(ss -alntuw | awk -F ' ' '{print $5}' | egrep -o ':((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$' | egrep -o '[0-9]+$' | sort -n --unique)"
echo -e $localports

# Find process information about who/what uses that port
for port in $localports
do
	isallowed=0
	for w in $whitelist
	do
		if [ "$w" == "$port" ]; then
			isallowed=1
			break
		fi
	done
	if [ "$isallowed" == "1" ]; then
		continue
	fi
	cmds="$(sudo lsof -i :$port | awk '{print $1}' | egrep -v '(COMMAND)' | sort --unique )"
	echo -e $cmds
	pids="$(sudo lsof -i :$port | awk '{print $2}' | egrep -o '[0-9]+$' | sort --unique)"
	echo -e $pids
	for cmd in $cmds
	do
		sudo systemctl mask "$cmd${*}.socket" 2>/dev/null
		sudo systemctl stop "$(ps -o unit= -C $cmd)" 2>/dev/null
		sudo systemctl stop "$cmd${*}" 2>/dev/null
		sudo rcconf --off "$cmd" 2>/dev/null
		sudo update-rc.d -f "$cmd" stop 2>/dev/null
	done
	for pid in $pids
	do
		sudo kill "$pid" 2>/dev/null
		sleep 3
		sudo kill -9 "$pid" 2>/dev/null
	done
done
