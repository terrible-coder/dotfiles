#!/bin/bash

equalPad() {
	str="$@"
	str_len=${#str}
	if [ $str_len == 1 ]; then
		echo -n "  $C"
	elif [ $str_len == 2 ]; then
		echo -n " $C"
	else
		echo -n "$C"
	fi
}

# primary 16 colours
# first 8
for C in $(seq 0 7); do
	if [ `echo "$C % 8" | bc` -eq 0 ]; then
		echo -n "  "
	fi
	tput setab $C
	tput setaf 16
	equalPad $C
	tput sgr0
	echo -n " "
done
echo
# last 8
for C in $(seq 8 15); do
	if [ `echo "$C % 8" | bc` -eq 0 ]; then
		echo -n "  "
	fi
	tput setab $C
	tput setaf 16
	equalPad $C
	tput sgr0
	echo -n " "
done
echo
echo

# colours 16 through 46
for i in $(seq 16 6 46); do
	echo -n " "
	for j in $(seq 0 36 88); do
		startCol="$(expr $i + $j)"
		for k in $(seq 0 5); do
			C="$(expr $startCol + $k)"
			if [ $i -ge 34 ]; then
				tput setaf 16
			fi
			tput setab $C
			equalPad $C
			tput sgr0
			echo -n " "
		done
		echo -n "  "
	done
	echo
done
tput sgr0
echo

# colours 124 through 154
for i in $(seq 124 6 154); do
	echo -n " "
	for j in $(seq 0 36 88); do
		startCol="$(expr $i + $j)"
		for k in $(seq 0 5); do
			C="$(expr $startCol + $k)"
			if [ $i -ge 142 ]; then
				tput setaf 16
			fi
			tput setab $C
			equalPad $C
			tput sgr0
			echo -n " "
		done
		echo -n "  "
	done
	echo
done
tput sgr0
echo

for i in $(seq 0 1); do
	echo -n " "
	for j in $(seq 232 243); do
		C=$j
		if [ $i -eq 1 ]; then
			C="$(expr $C + 12)"
			tput setaf 16
		fi
		tput setab $C
		equalPad $C
		tput sgr0
		echo -n " "
	done
	echo
done
