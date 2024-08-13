#!/usr/bin/sh

while true
do
	networks=$(nmcli d wifi)
	if [ $(echo "$networks" | wc -l) -eq 1 ]; then
		echo "Disabled"
	else
		echo "$networks" | awk 'BEGIN {
			FS = "  +";
			OFS = ",";
			in_use = 0;
		}
		/^\*/ {
			print $2, $3, $7;
			in_use++;
		}
		END {
			if (in_use < 1)
				print "Disconnected"
		}'
	fi
	sleep 10
done
