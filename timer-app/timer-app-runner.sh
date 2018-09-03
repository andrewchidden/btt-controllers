#!/bin/bash

#####
# DESCRIPTION: Starts a new timer or cancels the exiting timer.
#
# USAGE: ./timer-app-runner
#     <time>       
#         The amount of time in seconds. Replaces any ongoing timer. If not
#         specified, any ongoing timer is canceled.
#     <usr_root>
#         Path to the BetterTouchTool public preset resource folder.
#     <sys_root>
#         Path to the BetterTouchTool system service and caches folder.
#####


##### @interface #####
# Duration of the timer in seconds.
duration="$1"

# Set the `BTT_USR_ROOT` environment variable to the folder with preset scripts
# and configurations. Defaults to `~/bettertouchtool`.
usr_root_arg=${2:-${BTT_USR_ROOT}}
btt_usr_root=${usr_root_arg:-~/bettertouchtool}

# Optionally set the `BTT_SYS_ROOT` environment variable to the internal system 
# folder used by services to save and share state. Defaults to `~/.btt`
sys_root_arg=${3:-${BTT_SYS_ROOT}}
btt_sys_root=${sys_root_arg:-~/.btt}

# Path to the kill executable to use. Only used for mocks during testing.
kill_bin_path=${4:-'kill'}

# Path to the ps executable to use. Only used for mocks during testing.
ps_bin_path=${5:-'ps'}

# Path to the osascript executable to use. Only used for mocks during testing.
osascript_bin_path=${6:-'osascript'}


##### @implementation #####
# Internal config.
timerapp_directory="${btt_sys_root}/timer-app"
timerapp_timerfile="${timerapp_directory}/timer"
timerapp_script="${btt_usr_root}/timer-app/timer-app.scpt"

mkdir -p "${timerapp_directory}"
touch "${timerapp_timerfile}"

# Kill the ongoing timer, if one exists.
timer="$(cat ${timerapp_timerfile})"
if [[ -n "${timer}" ]]; then
	timer_components=($(echo "${timer}" | tr ' ' '\n'))
	pid="${timer_components[0]}"
	timer_script_path="${timerapp_directory}/"
	if [[ ( -n "${pid}" ) && \
		  ( -n "$(${ps_bin_path} -p ${pid} -o 'pid=')" ) && \
		  ( -n "$(${ps_bin_path} aux | grep ${timerapp_script} | grep -v grep)" ) ]]; then
		"${kill_bin_path}" -9 "${pid}"
	fi
fi

if [[ ( -n "${duration}" ) && ( "${duration}" -gt 0 ) ]]; then
	# Start a new timer.
	"${osascript_bin_path}" "${timerapp_script}" "${duration}" &
	pid="$!"
	timestamp="$(date +%s)"
	echo "${pid} ${timestamp} ${duration}" > "${timerapp_timerfile}"
fi