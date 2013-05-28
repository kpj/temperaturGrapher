#!/bin/bash

file="data.dat"
intv="1s"

function getTemp() {
	data=`sensors`

	core0=`echo "$data" | grep "Core 0" | cut -d" " -f9`
	core0=${core0#+}
	core0=${core0%.0°C}

	core1=`echo "$data" | grep "Core 1" | cut -d" " -f9`
	core1=${core1#+}
	core1=${core1%.0°C}

	if [[ $core0 -ge $core1 ]] ; then
		echo $core0
	else
		echo $core1
	fi
}

function append() {
	if [[ -f $file ]] ; then
		lastDigit=`tail -n1 $file | cut -d" " -f1`
		nextDigit=$((lastDigit + 1))
	else
		nextDigit=1
	fi
	echo "$nextDigit $1" >> $file
}

function genPlot() {
	gnup="
set autoscale
unset log
unset label
set term png
set output '$file.png'
set xtic auto
set ytic auto
set title \"Heat developement over time\"
set xlabel \"Time [$intv]\"
set ylabel \"Heat [°C]\"
#set xr [0:10]
set yr [0:110]
plot '$file' with linespoints pointtype -1
"

	echo "$gnup" > "gnuppi"
	gnuplot "gnuppi"
	rm "gnuppi"

	echo "Generated graph..."
}

function finish() {
	echo "Finishing up..."
	genPlot
	exit
}

function getData() {
	echo "Collecting data now..."
	while true ; do
		append `getTemp`
		sleep $intv
	done
}

trap finish SIGINT

getData
