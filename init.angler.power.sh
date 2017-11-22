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
write /sys/module/msm_thermal/core_control/enabled 1
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode disable
bcl_hotplug_mask=`get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_mask 0`
bcl_hotplug_soc_mask=`get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask 0`
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode enable
write /sys/module/msm_thermal/parameters/enabled Y

# some files in /sys/devices/system/cpu are created after the restorecon of
# /sys/. These files receive the default label "sysfs".
# Restorecon again to give new files the correct label.
restorecon -R /sys/devices/system/cpu

# ensure at most one A57 is online when thermal hotplug is disabled
write /sys/devices/system/cpu/cpu5/online 0
write /sys/devices/system/cpu/cpu6/online 0
write /sys/devices/system/cpu/cpu7/online 0

#LITTLE
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu # must restore after interactive
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load 99
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay "26000 600000:20000 672000:10000"
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate 20000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq 960000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack 30000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads 90
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time 38000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/align_windows 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis 33000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration 40000

# online CPU4
write /sys/devices/system/cpu/cpu4/online 1

#big.
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu # must restore after interactive
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load 100
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay 19000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate 20000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq 1248000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack 30000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads 90
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time 40000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/align_windows 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis 30000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration 40000

# Dynamic stuneBoost
write /sys/module/cpu_boost/parameters/dynamic_stune_boost 1

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

# Enable all LPMs by default
write /sys/module/lpm_levels/parameters/sleep_disabled 0

# re-enable thermal and BCL hotplug
write /sys/module/msm_thermal/core_control/enabled 0
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode disable
get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_mask $bcl_hotplug_mask
get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask $bcl_hotplug_soc_mask
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode enable
write /sys/module/msm_thermal/parameters/enabled Y

# change GPU initial power level from 305MHz(level 4) to 180MHz(level 5) for power savings
write /sys/class/kgsl/kgsl-3d0/default_pwrlevel 5
