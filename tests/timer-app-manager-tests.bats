#!/usr/bin/env bats

#####
# DESCRIPTION: Unit tests for the service-runner shell script.
#####


##### @interface #####
timer_manager='./timer-app/timer-app-manager.sh'
test_root_directory='/tmp/btt/tests' # Passed to the service runner.
test_timer_directory="${test_root_directory}/timer-app"
test_timer_filepath="${test_timer_directory}/timer"


##### @implementation #####
function set_up() {
	# Create a test root system directory for the manager.
	mkdir -p "${test_timer_directory}"

	# Remove any timer test files.
	rm -f "${test_timer_filepath}"
}

function tear_down() {
	# Remove any timer test files.
	rm -f "${test_timer_filepath}"
}

# $1: Time interval in seconds (before now) when the timer started.
# $2: Duration in seconds of the timer.
function mock_timer() {
	local time_interval="$1"
	local duration="$2"
	local now
	now="$(date +%s)"
	local timer_start
	timer_start="$(expr ${now} - ${time_interval})"
	# In format <pid> <timestamp> <duration>
	echo "1 ${timer_start} ${duration}" > "${test_timer_filepath}" # uses launchd pid=1
}

@test 'padded time from timer file' {
	set_up

	# Given a timer is running with only seconds remaining
	mock_timer 30 60
	# When timer app manager is executed
	# Then it should return the expected padded parsed time
	[ "$(${timer_manager} ${test_root_directory})" = '00:30' ]

	# And Given a timer is running with less than 10 minutes remaining
	mock_timer 30 135
	# When timer app manager is executed
	# Then it should return the expected padded parsed time
	[ "$(${timer_manager} ${test_root_directory})" = '01:45' ]

	# And Given a timer is running with greater than 10 minutes remaining
	mock_timer 30 660
	# When timer app manager is executed
	# Then it should return the expected parsed time
	[ "$(${timer_manager} ${test_root_directory})" = '10:30' ]

	# And Given a timer is running with greater than an hour remaining
	mock_timer 30 12843
	# When timer app manager is executed
	# Then it should return the expected padded parsed time
	[ "$(${timer_manager} ${test_root_directory})" = '03:33:33' ]
	
	tear_down
}

@test 'empty status with empty timer file' {
	set_up

	# Given the timer file is blank
	> "${test_timer_filepath}"
	# When timer app manager is executed
	# Then it should return an empty status
	[ -z "$(${timer_manager} ${test_root_directory})" ]

	tear_down
}

@test 'empty status with no active timer process' {
	set_up

	# Given the timer process in the timer file is not running
	local now
	now="$(date +%s)"
	local timer_start
	timer_start="$(expr ${now} - 30)"
	echo "99000 ${now} 180" > "${test_timer_filepath}"
	# When timer app manager is executed
	# Then it should return an empty status
	[ -z "$(${timer_manager} ${test_root_directory})" ]

	tear_down
}