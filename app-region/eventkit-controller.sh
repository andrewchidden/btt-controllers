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

# Optionally set the `BTT_EVENTKIT_MAXLENGTH` environment variable to control
# the maximum length of the calendar text status.
eventkit_maxlength_arg=${2:-${BTT_EVENTKIT_MAXLENGTH}}
btt_eventkit_maxlength=${eventkit_maxlength_arg:-40}

##### @implementation #####
status_directory="${btt_sys_root}/eventkit-service"
status_filepath="${status_directory}/status"

current_status="$(cat ${status_filepath})"
if [[ -n "${current_status}" ]]; then
	echo "${current_status}" | \
	     awk "{str = \$0; \
		     if (length - 1 > ${btt_eventkit_maxlength}) \
		     	print substr(str, 1, ${btt_eventkit_maxlength} / 2) \"…\" \
		              substr(str, length - ${btt_eventkit_maxlength} / 2 + 1, length); \
		     else \
		     	print str}"
else
	echo 'Calendar error'
fi
