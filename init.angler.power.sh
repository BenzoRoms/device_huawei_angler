#!/system/bin/sh

################################################################################
# helper functions to allow Android init like script

function write() {
    echo -n $2 > $1
}

function copy() {
    cat $1 > $2
}

function get-set-forall() {
    for f in $1 ; do
        cat $f
        write $f $2
    done
}

################################################################################
# disable thermal bcl hotplug to switch governor
write /sys/module/msm_thermal/core_control/enabled 0
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode disable
bcl_hotplug_mask=`get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_mask 0`
bcl_hotplug_soc_mask=`get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask 0`
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode enable

# some files in /sys/devices/system/cpu are created after the restorecon of
# /sys/. These files receive the default label "sysfs".
# Restorecon again to give new files the correct label.
restorecon -R /sys/devices/system/cpu

# ensure at most one A57 is online when thermal hotplug is disabled
write /sys/devices/system/cpu/cpu5/online 0
write /sys/devices/system/cpu/cpu6/online 0
write /sys/devices/system/cpu/cpu7/online 0

# LITTLE
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor cultivation
restorecon -R /sys/devices/system/cpu # must restore after interactive
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/above_hispeed_delay 20000
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/fastlane 0
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/go_hispeed_load 99
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/go_lowspeed_load 10
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/hispeed_freq 1555200
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/io_is_busy 0
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/max_freq_hysteresis 80000
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/min_sample_time 40000
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/powersave_bias 1
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/target_loads 90
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/timer_rate 20000
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/timer_rate_screenoff 50000
write /sys/devices/system/cpu/cpu0/cpufreq/cultivation/timer_slack 80000

# online CPU4
write /sys/devices/system/cpu/cpu4/online 1

#big.
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor cultivation
restorecon -R /sys/devices/system/cpu
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/above_hispeed_delay 20000
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/fastlane 0
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/go_hispeed_load 99
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/go_lowspeed_load 10
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/hispeed_freq 1958400
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/io_is_busy 0
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/max_freq_hysteresis 80000
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/min_sample_time 40000
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/powersave_bias 1
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/target_loads 90
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/timer_rate 20000
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/timer_rate_screenoff 50000
write /sys/devices/system/cpu/cpu4/cpufreq/cultivation/timer_slack 800000

# restore A57's max
copy /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq

# plugin remaining A57s
write /sys/devices/system/cpu/cpu5/online 1
write /sys/devices/system/cpu/cpu6/online 1
write /sys/devices/system/cpu/cpu7/online 1

# input boost configuration
write /sys/module/cpu_boost/parameters/input_boost_freq
write /sys/module/cpu_boost/parameters/input_boost_ms 40

# Setting B.L scheduler parameters
write /proc/sys/kernel/sched_migration_fixup 1
write /proc/sys/kernel/sched_upmigrate 95
write /proc/sys/kernel/sched_downmigrate 85
write /proc/sys/kernel/sched_freq_inc_notify 400000
write /proc/sys/kernel/sched_freq_dec_notify 400000

# android background processes are set to nice 10. Never schedule these on the a57s.
write /proc/sys/kernel/sched_upmigrate_min_nice 9

get-set-forall  /sys/class/devfreq/qcom,cpubw*/governor bw_hwmon

# Disable sched_boost
write /proc/sys/kernel/sched_boost 0

# re-enable thermal and BCL hotplug
write /sys/module/msm_thermal/core_control/enabled 1
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode disable
get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_mask $bcl_hotplug_mask
get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask $bcl_hotplug_soc_mask
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode enable

# change GPU initial power level from 305MHz(level 4) to 180MHz(level 5) for power savings
write /sys/class/kgsl/kgsl-3d0/default_pwrlevel 5
