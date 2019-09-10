#!/bin/bash

echo -e "TUNE CPU" 
cpupower frequency-set -g performance 
echo " "
echo " "
echo "= = check = = "
for A in $(ls -l /sys/devices/system/cpu | grep cpu | sort | awk '{print $9}') ; do echo "$A Config : $(cat /sys/devices/system/cpu/$A/cpufreq/scaling_governor)" ; done 
