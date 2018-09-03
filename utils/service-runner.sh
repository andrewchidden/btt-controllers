#!/bin/bash

#####
# DESCRIPTION: Initializes service file system dependencies and checks that 
# the services are running based on pid. If a service is not running it is
# restarted and its pid saved to disk.
#
# INSTALLATION: Turn on BetterTouchTool's integrated web server under 
# advanced settings to enable push updates from services to widgets.
#
# USAGE: Modify the values below, particularly the widget UUID and webserver
# URL parameters. Note that using HTTPS for the web server introduces some
# additional latency between the push and BetterTouchTool updating.
#
# ./service-runner.sh
#     <usr_root>
#         Path to the BetterTouchTool public preset resource folder.
#     <sys_root>
#         Path to the BetterTouchTool system service and caches folder.
#####


##### @interface #####
# Set the `BTT_USR_ROOT` environment variable to the folder with preset scripts
# and configurations. Defaults to `~/bettertouchtool`.
usr_root_arg=${1:-${BTT_USR_ROOT}}
btt_usr_root=${usr_root_arg:-~/bettertouchtool}

# Optionally set the `BTT_SYS_ROOT` environment variable to the internal system 
# folder used by services to save and share state. Defaults to `~/.btt`
sys_root_arg=${2:-${BTT_SYS_ROOT}}
btt_sys_root=${sys_root_arg:-~/.btt}

# Optionally set the `BTT_EVENTKIT_CALENDAR_NAMES` environment variable to the
# set of calendar names to check for events. If the environment variable is not
# set then all calendars will be checked.
calendar_names=${BTT_EVENTKIT_CALENDAR_NAMES:-''}

# Set the `BTT_WEBSERVER_URL` environment variable to the BetterTouchTool web
# server address and port. This is _required_ for services to work. If not
# specified, will default to `http://127.0.0.1:64875`. Be advised that HTTPS
# incurs some latency to the pushes.
webserver_url=${BTT_WEBSERVER_URL:-'http://127.0.0.1:64875'}
# Optionally set the `BTT_WEBSERVER_SHAREDSECRET` environment variable to the
# BetterTouchTool web server shared secret. Leave blank if not using a shared
# secret to authenticate pushes.
webserver_sharedsecret=${BTT_WEBSERVER_SHAREDSECRET:-''}


##### @implementation #####
# Set up service file system dependencies and run if not already running.
function setup_service() {
	mkdir -p "${status_directory}"
	touch "${status_filepath}"
	touch "${service_pid_filepath}"

	service_pid="$(cat ${service_pid_filepath})"
	if [[ ( -z "${service_pid}" ) || \
	      ( -z "$(ps -p ${service_pid} -o 'pid=')" ) || \
	      ( -z "$(ps aux | grep ${service_cli_filepath} | grep -v grep)" ) ]]; then
		# Start new service instance and save its pid.
		"${service_cli_filepath}" "${service_cli_args[@]}" &
		pid=$!
		echo "${pid}" > "${service_pid_filepath}"
	fi
}


##### volume-service runner #####
widget_uuid='7DAAE846-1CB7-406C-AA2F-18A925E267F6'

service_cli_filepath="${btt_usr_root}/control-strip/volume-service"
status_directory="${btt_sys_root}/volume-service"
status_filepath="${status_directory}/status"
service_pid_filepath="${status_directory}/pid"
service_cli_args=(
	"--status-path=${status_filepath}"
	"--btt-url=${webserver_url}"
	"--widget-uuid=${widget_uuid}"
	'--use-threshold=1'
)
if [[ -n "${webserver_sharedsecret}" ]]; then
	service_cli_args+=("--btt-secret=${webserver_sharedsecret}")
fi
setup_service


##### eventkit-service-runner #####
lookahead=1440 # in minutes
widget_uuid='10331142-3579-4C40-B44F-6883F03EBC15'

service_cli_filepath="${btt_usr_root}/app-region/eventkit-service"
status_directory="${btt_sys_root}/eventkit-service"
status_filepath="${status_directory}/status"
service_pid_filepath="${status_directory}/pid"
service_cli_args=(
	"--lookahead=${lookahead}"
	"--status-path=${status_filepath}"
	"--btt-url=${webserver_url}"
	"--widget-uuid=${widget_uuid}"
)
if [[ -n "${webserver_sharedsecret}" ]]; then
	service_cli_args+=("--btt-secret=${webserver_sharedsecret}")
fi
if [[ -n "${calendar_names}" ]]; then
	service_cli_args+=("--calendars=${calendar_names}")
fi
setup_service