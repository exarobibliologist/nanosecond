#! /bin/bash

cp ~/.bashrc ~/.bashrc.bkup
sudo echo ". ~/GIT/nanosecond/bashrc" >> ~/.bashrc
sudo cp ~/GIT/nanosecond/sources/sources.list /etc/apt/
sudo cp ~/GIT/nanosecond/sources/sourcestopper /etc/apt/preferences.d/

sudo cp ~/GIT/nanosecond/default.nanorc /usr/share/nano/
sudo apt update