#! /bin/bash

function unlockdpkg()
{
sudo rm -fv /var/lib/apt/lists/lock
sudo rm -fv /var/lib/dpkg/lock
sudo rm -fv /var/cache/apt/archives/lock
}
