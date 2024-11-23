# Source global definitions
if [ -f /etc/bash.bashrc ]; then
        . /etc/bash.bashrc
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Add timestamps to the history function
export HISTTIMEFORMAT="%d/%m/%y %T "

# Defaults Section
LinuxVersion=$(inxi -S)
iamme=$(whoami)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

###################
# Sourced Scripts #
###################
. ~/GIT/nanosecond/aliases
. ~/GIT/nanosecond/apt-search
. ~/GIT/nanosecond/apt-show
. ~/GIT/nanosecond/apt-stuff
. ~/GIT/nanosecond/catgrapple
. ~/GIT/nanosecond/colorize
. ~/GIT/nanosecond/debinstall
. ~/GIT/nanosecond/ducolor
. ~/GIT/nanosecond/encoder
. ~/GIT/nanosecond/extract
. ~/GIT/nanosecond/fixmouse
. ~/GIT/nanosecond/forcefsck
. ~/GIT/nanosecond/installstuff
. ~/GIT/nanosecond/julian
. ~/GIT/nanosecond/lamer
. ~/GIT/nanosecond/lsabcd
. ~/GIT/nanosecond/namechanger
. ~/GIT/nanosecond/networkinfo
. ~/GIT/nanosecond/owned
. ~/GIT/nanosecond/passwordmaker
. ~/GIT/nanosecond/pressanykey
. ~/GIT/nanosecond/progress-bar
. ~/GIT/nanosecond/psa
. ~/GIT/nanosecond/rebash
. ~/GIT/nanosecond/reconk
. ~/GIT/nanosecond/refont
. ~/GIT/nanosecond/rgb2cmyk
. ~/GIT/nanosecond/slideshower
. ~/GIT/nanosecond/soundfix
. ~/GIT/nanosecond/subhead_figlet
. ~/GIT/nanosecond/system_backup_and_restore
. ~/GIT/nanosecond/title_figlet
. ~/GIT/nanosecond/toplag
. ~/GIT/nanosecond/unlockdpkg
. ~/GIT/nanosecond/wallchange
. ~/GIT/nanosecond/welcome
. ~/GIT/nanosecond/welcome1
. ~/GIT/nanosecond/welcomeontime
. ~/GIT/nanosecond/welcomeaptcount
. ~/GIT/nanosecond/zangmath

## LSandPS1 must be loaded after the other scripts, or PS1 colors will not display correctly.
. ~/GIT/nanosecond/LSandPS1

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#########################
# The Terminal Greeting #
#########################

welcome

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
