#!/bin/bash

#####
# DESCRIPTION: Fetches the Git diff stats for a working directory
# and parses those stats into a compact and readable format.
#
# USAGE: ./eventkit-controller
#     <sys_root>
#         Path to the BetterTouchTool system service and caches folder.
#####


##### @interface #####
# Optionally set the `BTT_SYS_ROOT` environment variable to the internal system 
# folder used by services to save and share state. Defaults to `~/.btt`
sys_root_arg=${1:-${BTT_SYS_ROOT}}
btt_sys_root=${sys_root_arg:-~/.btt}


##### @implementation #####
status_directory="${btt_sys_root}/eventkit-service"
status_filepath="${status_directory}/status"

current_status="$(cat ${status_filepath})"
if [[ -n "${current_status}" ]]; then
	echo "${current_status}"
else
	echo 'Calendar error'
fi
