#!/usr/bin/env bats

#####
# DESCRIPTION: Unit tests for the eventkit-controller shell script.
#####


##### @interface #####
eventkit_controller='./app-region/eventkit-controller.sh'
test_status_root_directory='/tmp/btt/tests' # Passed to the controller.
test_status_directory="${test_status_root_directory}/eventkit-service"
test_status_filepath="${test_status_directory}/status"


##### @implementation #####
function set_up() {
	# Create a tmp status file for the controller during the test.
	mkdir -p "${test_status_directory}"
	touch "${test_status_filepath}"
}

function tear_down() {
	# Remove the tmp status file.
	rm "${test_status_filepath}"
}

@test 'message equals non-empty status' {
	set_up

	# Given the status is non-empty
	local expected_message='Some meeting in 3.1 hrs'
	echo "${expected_message}" > "${test_status_filepath}"
	# When the controller is run
	local message
	message="$(${eventkit_controller} ${test_status_root_directory})"
	# Then it should be the same non-empty status.
	[ "${message}" = "${expected_message}" ]

	tear_down
}

@test 'message equals long status' {
	set_up

	# Given the status is too long
	local message='Some long meeting name that does not fit in 3.1 hrs'
	local expected_result='Some long meeti… fit in 3.1 hrs'
	echo "${message}" > "${test_status_filepath}"
	# When the controller is run
	local message
	message="$(${eventkit_controller} ${test_status_root_directory})"
	# Then it should be the same with three dots in between
	# the first and last 15 characters
	[ "${message}" = "${expected_result}" ]

	tear_down
}

@test 'error message for empty status' {
	set_up

	# Given the status is empty
	echo '' > "${test_status_filepath}"
	# When the controller is run
	local message
	message="$(${eventkit_controller} ${test_status_root_directory})"
	# Then the controller should return an error message.
	[ "${message}" = 'Calendar error' ]

	tear_down
}
