#!/usr/bin/env bats

#####
# DESCRIPTION: Unit tests for the service-runner shell script.
#####


##### @interface #####
btt_usr_root=${BTT_USR_ROOT:-~/bettertouchtool}
timer_runner='./timer-app/timer-app-runner.sh'
timerapp_script="${btt_usr_root}/timer-app/timer-app.scpt"
timer_kill_mock='./tests/mocks/timer-kill-mock.sh'
timer_ps_mock='./tests/mocks/timer-ps-mock.sh'
timer_osascript_mock='./tests/mocks/timer-osascript-mock.sh'
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

	# Make timer mocks executable and cleanup the environment.
	chmod +x "${timer_kill_mock}"
	chmod +x "${timer_ps_mock}"
	chmod +x "${timer_osascript_mock}"
}

function tear_down() {
	# Kill any timer process that was created.
	touch "${test_timer_filepath}"
	local timer
	timer="$(cat ${test_timer_filepath})"
	local timer_components
	timer_components=($(echo "${timer}" | tr ' ' '\n'))
	local pid="${timer_components[0]}"
	if [[ ( -n "${pid}" ) && ( -n "$(ps -p ${pid} -o 'pid=')" ) ]]; then
		kill -9 "${pid}"
	fi

	# Remove any timer test files.
	rm -f "${test_timer_filepath}"
}

# $1: The mock timer process identifier
function verify_new_timer_started() {
	local timer_mock_pid="$1"
	local timer
	timer="$(cat ${test_timer_filepath})"
	local timer_components
	timer_components=($(echo "${timer}" | tr ' ' '\n'))
	local pid="${timer_components[0]}"
	[[ -n "${pid}" ]]
	[[ "${pid}" != "${timer_mock_pid}" ]]
	[[ -n "$(ps -p ${pid} -o 'pid=')" ]]
}

# $1: Timer process identifier to check if killed.
function verify_timer_killed() {
	[[ -z "$(ps -p $1 -o 'pid=')" ]]
}

# $1: Timer process identifier to mock.
# $2: Timer duration in seconds.
function mock_timer() {
	pid="$1"
	duration="$2"
	export BTT_TEST_MOCKED_TIMER_PID="${pid}"
	export BTT_TEST_MOCKED_TIMER_PS_AUX="${timerapp_script}"
	export BTT_TEST_MOCKED_TIMER_DURATION="${duration}"
	local now
	now="$(date +%s)"
	local timer_start
	timer_start="$(expr ${now} - 30)"
	# In format <pid> <timestamp> <duration>
	echo "${pid} ${timer_start} ${duration}" > "${test_timer_filepath}"
	echo "${pid}"
}

@test 'replaces timer process' {
	set_up

	# Given a timer process is running
	mock_timer 12345 60

	# When timer app runner is executed with a non-zero duration
	"${timer_runner}" 60 "${btt_usr_root}"\
						 "${test_root_directory}"\
						 "${timer_kill_mock}"\
						 "${timer_ps_mock}"\
						 "${timer_osascript_mock}"
	# Then it should kill mock timer process
	[ "$(cat ${test_mock_return_directory}/ps)" = "0" ]
	[ "$(cat ${test_mock_return_directory}/kill)" = "0" ]
	#   And start a new timer process
	[ "$(cat ${test_mock_return_directory}/osascript)" = "0" ]
	
	tear_down
}