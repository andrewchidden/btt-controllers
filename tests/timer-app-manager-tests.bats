#!/usr/bin/env bats

#####
# DESCRIPTION: Unit tests for the service-runner shell script.
#####


##### @interface #####
btt_usr_root=${BTT_USR_ROOT:-~/bettertouchtool}
timer_manager='./timer-app/timer-app-manager.sh'
timerapp_script="${btt_usr_root}/timer-app/timer-app.scpt"
timer_ps_mock='./tests/mocks/timer-ps-mock.sh'
test_root_directory='/tmp/btt/tests' # Passed to the service runner.
test_timer_directory="${test_root_directory}/timer-app"
test_timer_filepath="${test_timer_directory}/timer"
test_mock_return_directory='/tmp/btt/tests/mocks/timer-app'


##### @implementation #####
function set_up() {
	# Create a test root system directory for the manager.
	mkdir -p "${test_timer_directory}"

	# Create a new directory for mock message passing.
	rm -rf "${test_mock_return_directory}"
	mkdir -p "${test_mock_return_directory}"
	export BTT_TEST_MOCKED_RETURN_DIR="${test_mock_return_directory}"

	# Remove any timer test files.
	rm -f "${test_timer_filepath}"
}

function tear_down() {
	# Remove any timer test files.
	rm -f "${test_timer_filepath}"
}

# $1: Time interval in seconds (before now) when the timer started.
# $2: Duration in seconds of the timer.
# $3: Expected pid. Iff 12345 then mock verification will succeed.
function mock_timer() {
	local time_interval="$1"
	local duration="$2"
	local expected_pid="$3"
	local now
	now="$(date +%s)"
	local timer_start
	timer_start="$(expr ${now} - ${time_interval})"

	export BTT_TEST_MOCKED_TIMER_PID="${expected_pid}"
	export BTT_TEST_MOCKED_TIMER_PS_AUX="${timerapp_script}"

	# In format <pid> <timestamp> <duration>
	echo "12345 ${timer_start} ${duration}" > "${test_timer_filepath}"
}

@test 'padded time from timer file' {
	set_up

	# Given a timer is running with only seconds remaining
	mock_timer 30 60 12345
	# When timer app manager is executed
	# Then it should return the expected padded parsed time
	[ "$(${timer_manager} ${btt_usr_root} ${test_root_directory} "${timer_ps_mock}")" = '00:30' ]

	# And Given a timer is running with less than 10 minutes remaining
	mock_timer 30 135 12345
	# When timer app manager is executed
	# Then it should return the expected padded parsed time
	[ "$(${timer_manager} ${btt_usr_root} ${test_root_directory} "${timer_ps_mock}")" = '01:45' ]

	# And Given a timer is running with greater than 10 minutes remaining
	mock_timer 30 660 12345
	# When timer app manager is executed
	# Then it should return the expected parsed time
	[ "$(${timer_manager} ${btt_usr_root} ${test_root_directory} "${timer_ps_mock}")" = '10:30' ]

	# And Given a timer is running with greater than an hour remaining
	mock_timer 30 12843 12345
	# When timer app manager is executed
	# Then it should return the expected padded parsed time
	[ "$(${timer_manager} ${btt_usr_root} ${test_root_directory} "${timer_ps_mock}")" = '03:33:33' ]
	
	tear_down
}

@test 'empty status with empty timer file' {
	set_up

	# Given the timer file is blank
	> "${test_timer_filepath}"
	# When timer app manager is executed
	# Then it should return an empty status
	[ -z "$(${timer_manager} ${btt_usr_root} ${test_root_directory} "${timer_ps_mock}")" ]

	tear_down
}

@test 'empty status with no active timer process' {
	set_up

	# Given the timer process in the timer file is not running
	mock_timer 30 180 99000
	# When timer app manager is executed
	# Then it should return an empty status
	[ -z "$(${timer_manager} ${btt_usr_root} ${test_root_directory} "${timer_ps_mock}")" ]

	tear_down
}