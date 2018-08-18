#!/bin/bash

#####
# DESCRIPTION: Starts a new timer or cancels the exiting timer.
#
# USAGE: ./timer-app-manager
#     <sys_root>
#         Path to the BetterTouchTool system service and caches folder.
#####


##### @interface #####
# Optionally set the `BTT_SYS_ROOT` environment variable to the internal system 
# folder used by services to save and share state. Defaults to `~/.btt`
sys_root_arg=${1:-${BTT_SYS_ROOT}}
btt_sys_root=${sys_root_arg:-~/.btt}


##### @implementation #####
# Internal config.
timerapp_directory="${btt_sys_root}/timer-app"
timerapp_timerfile="${timerapp_directory}/timer"

mkdir -p "${timerapp_directory}"
touch "${timerapp_timerfile}"

timer="$(cat ${timerapp_timerfile})"

if [[ -n "${timer}" ]]; then
	timer_components=($(echo "${timer}" | tr ' ' '\n'))

	# Extract information from timer save file.
	pid="${timer_components[0]}"
	timestamp="${timer_components[1]}"
	duration="${timer_components[2]}"

	if [[ -n "$(ps -p${pid} -o 'pid=')" ]]; then 
		# Timer is running.
		cur_timestamp="$(date +%s)"
		dtime="$(expr ${cur_timestamp} - ${timestamp})"
		timeleft="$(expr ${duration} - ${dtime})"
		if [[ "${timeleft}" -lt 0 ]]; then
			echo '00:00'
		elif [[ "${timeleft}" -lt 3600 ]]; then
			printf '%02d:%02d' "$((${timeleft}%3600/60))" "$((${timeleft}%60))"
		else
			printf '%02d:%02d:%02d' "$((${timeleft}/3600))" "$((${timeleft}%3600/60))" "$((${timeleft}%60))"
		fi
	fi
fi