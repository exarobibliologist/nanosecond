#!/bin/bash

function networkinfo()
{
clear
	select webchoice in "Network Interface" "IP's and Subnets" "MAC Address" "MTR Google Report" "MTR Google Continuous" "Quit Without Selecting Anything"
		do
			case "$webchoice" in
				"Network Interface")
					clear
					netstat -rn
				return
				;;
				"IP's and Subnets")
					clear
					/sbin/ifconfig
				return
				;;
				"MAC Address")
					clear
					ip addr show
				return
				;;
				"MTR Google Report")
					clear
					mtr --curses -r -c 25 -o "SRDL BA JM" www.google.com
				return
				;;
				"MTR Google Continuous")
					clear
					mtr --curses -o "SRDL BA JM" www.google.com
				return
				;;
				"Quit Without Selecting Anything")
				return
				;;
			esac
		done
}
