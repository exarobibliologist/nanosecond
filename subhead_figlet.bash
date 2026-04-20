#! /bin/bash

function subhead_figlet() {
	figlet -f standard -w 2000 "$1" | sed 's/^/##/' > output.txt
	# Notify user of output location
	echo "Figlet output written to output.txt"
}
