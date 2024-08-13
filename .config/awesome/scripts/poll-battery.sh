#!/usr/bin/sh

while true
do
	acpi -b | sed 's/Battery [0-9]\+:\s\+//'
	sleep 10
done
