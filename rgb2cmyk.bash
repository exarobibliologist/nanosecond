#!/bin/bash

function rgb2cmyk()
{
echo "Input Red 0-255"
read red
echo "Input Green 0-255"
read green
echo "Input Blue 0-255"
read blue
computedC=$(echo "1-($red/255)" | bc)
computedM=$(echo "1-($green/255)" | bc)
computedY=$(echo "1-($blue/255)" | bc)
array="${computedC}\n${computedM}\n${computedY}"
minCMY=$(echo -e "${array}" | sort -n | head -n1)
theC=$(echo "($computedC - $minCMY) / (1 - $minCMY)" | bc)
theM=$(echo "($computedM - $minCMY) / (1 - $minCMY)" | bc)
theY=$(echo "($computedY - $minCMY) / (1 - $minCMY)" | bc)
clear
echo -e "The RGB color $red / $green / $blue\nis\nC=$theC\nM=$theM\nY=$theY\nK=$minCMY"
}
