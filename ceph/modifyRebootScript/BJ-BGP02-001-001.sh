#!/bin/bash

# Shut down energy saving for all cores
echo performance | tee /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_governor > /dev/null

# Adjust the maximum kernel pid
echo 4194303 > /proc/sys/kernel/pid_max

# Adjust the readahead size for all SATAs
echo 8192 | tee /sys/block/sd[bf-k]/queue/read_ahead_kb > /dev/null
