#!/usr/bin/sh

while true
do
	networks=$(nmcli d wifi)
	if [ $(echo "$networks" | wc -l) -eq 1 ]; then
		echo "Disabled"
	else
		echo "$networks" | awk 'BEGIN {
			FS = "  +";
			OFS = ","
		}
		/^\*/ {
			print $2, $3, $7;
		}'
	fi
	sleep 10
done
