#! /bin/bash

function welcomeaptcount()
{
## List number of available updates
aptcount=$(aptitude search "~U" | wc -l)

#List updates available
if [ "$aptcount" = "0" ] # if there are no updates available
        then
                echo -e "$(color 3)There are no known upgrades available for your system.$(reset)"
elif [ "$aptcount" = "1" ] # if there is 1 update only
        then
                echo -e "There is $(bold 11)1 known upgrade$(reset) available for your system.\nType $(color 14)rebash$(reset) to begin the update/upgrade process."
else [ "$aptcount" != "1" ] # there is more than 1 update
                echo -e "There are $(bold 9)$aptcount known upgrades$(reset) available for your system.\nType $(color 14)rebash$(reset) to begin the update/upgrade process."
fi
}
