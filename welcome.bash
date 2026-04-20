#! /bin/bash

function welcome()
{
# who am i?
username=$(whoami)

###########################################################
# You could add a Tasklist to your BASH prompt like this! #
###########################################################
#taskline="$(color 201)Task List$(reset)\n$(cat -n $HOME/BASH/Tasklist)"


###################
# Welcome Options #
###################

#screenfetch

##################
# Welcome Prompt #
##################
welcome1
welcomeaptcount
welcomeontime
echo
}
