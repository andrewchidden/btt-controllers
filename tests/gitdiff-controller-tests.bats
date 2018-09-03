#!/usr/bin/env bats

#####
# DESCRIPTION: Unit tests for the gitdiff-controller shell script.
#####


##### @interface #####
btt_usr_root=${BTT_USR_ROOT:-~/bettertouchtool}
gitdiff_controller='./app-region/gitdiff-controller.sh'
git_mock="${btt_usr_root}/tests/mocks/gitdiff-git-mock.sh" # Passed to the controller.
git_mock_local='./tests/mocks/gitdiff-git-mock.sh'
test_root_directory='/tmp/btt/tests' # Passed to the controller.
test_directory="${test_root_directory}/gitdiff-controller" # Passed to the controller (workspace).
test_status_filepath="${test_root_directory}/gitdiff-controller/cached-status"
test_diff_filepath="${test_root_directory}/gitdiff-controller/cached-diff"

##### @implementation #####
function set_up() {
	# Ensure the Git mock is executable.
	chmod +x "${git_mock_local}"

	# Create empty cache files.
	mkdir -p "${test_directory}"
	> "${test_status_filepath}"
	> "${test_diff_filepath}"
}

function tear_down() {
	# Remove any created cache files.
	rm -f "${test_status_filepath}"
	rm -f "${test_diff_filepath}"
}

# $1: The message that Git diff should return.
function mock_new_git_diff() {
	# Ensure the cached status does not equal the one returned by Git
	echo 'a-cached-status' > "${test_status_filepath}"
	export BTT_TEST_MOCKED_GITSTATUS_RETURN='a-new-status'
	#   And Git diff returns some value.
	export BTT_TEST_MOCKED_GITDIFF_RETURN="$1"
}

@test 'diff message for new status with insertions deletions' {
	set_up

	# Given a Git diff message with both insertions and deletions
	mock_new_git_diff '12 files changed, 345 insertions(+), 678 deletions(-)'	
	# When the controller is run with the Git mock
	# Then it should return the expected status.
	[ "$(${gitdiff_controller} ${test_root_directory} ${git_mock} ${test_directory})" = '12 files (+345 / −678)' ]

	tear_down
}

@test 'diff message for new status with only insertions' {
	set_up

	# Given a Git diff message with only insertions
	mock_new_git_diff '12 files changed, 345 insertions(+)'
	# When the controller is run with the Git mock
	# Then it should return the expected status.
	[ "$(${gitdiff_controller} ${test_root_directory} ${git_mock} ${test_directory})" = '12 files (+345 / −0)' ]

	tear_down
}

@test 'diff message for new status with only deletions' {
	set_up

	# Given a Git diff message with only deletions
	mock_new_git_diff '12 files changed, 678 deletions(-)'
	# When the controller is run with the Git mock
	# Then it should return the expected status.
	[ "$(${gitdiff_controller} ${test_root_directory} ${git_mock} ${test_directory})" = '12 files (+0 / −678)' ]

	tear_down
}

@test 'diff message for new status with only files changed' {
	set_up

	# Given a Git diff message with only files changed
	mock_new_git_diff '12 files changed'
	# When the controller is run with the Git mock
	# Then it should return the expected status.
	[ "$(${gitdiff_controller} ${test_root_directory} ${git_mock} ${test_directory})" = '12 files' ]

	tear_down
}

@test 'diff message single file changed' {
	set_up
	
	# Given a Git diff message with only one file changed
	mock_new_git_diff '1 file changed'
	# When the controller is run with the Git mock
	# Then it should return the expected status.
	[ "$(${gitdiff_controller} ${test_root_directory} ${git_mock} ${test_directory})" = '1 file' ]

	tear_down
}

@test 'ignore blank cached diff' {
	set_up

	# Given the cached diff is blank
	> "${test_diff_filepath}"
	#   And a valid Git diff
	mock_new_git_diff '12 files changed, 345 insertions(+), 678 deletions(-)'	
	# When the controller is run with the Git mock
	# Then it should return the expected status.
	[ "$(${gitdiff_controller} ${test_root_directory} ${git_mock} ${test_directory})" = '12 files (+345 / −678)' ]

	tear_down
}

@test 'cached diff for unchanged status' {
	set_up

	# Given the cached status equals the one returned by Git
	echo 'a-cached-status' > "${test_status_filepath}"
	export BTT_TEST_MOCKED_GITSTATUS_RETURN='a-cached-status'
	#   And the cached diff exists
	echo 'a-cached-diff' > "${test_diff_filepath}"

	# When the controller is run with the Git mock
	# Then it should return the cached diff.
	[ "$(${gitdiff_controller} ${test_root_directory} ${git_mock} ${test_directory})" = 'a-cached-diff' ]

	tear_down
}

@test 'diff for clean working tree' {
	set_up

	# Given an empty Git diff message (clean working tree)
	mock_new_git_diff ''
	# When the controller is run with the Git mock
	# Then it should return the expected status.
	[ "$(${gitdiff_controller} ${test_root_directory} ${git_mock} ${test_directory})" = 'Working tree is clean' ]

	tear_down
}

@test 'handles no working directory' {
	set_up

	# Pop the current working directory preference.
	saved_working_directory=${BTT_GIT_WORKING_DIR:-''}
	export BTT_GIT_WORKING_DIR=''

	# When the controller is run with no working directory
	local message
	message="$(${gitdiff_controller} ${test_root_directory} ${git_mock})"

	# Then the controller should return an error message.
	[ "${message}" = 'No working directory' ]

	# Restore the current working directory preference.
	if [[ -n "${saved_working_directory}" ]]; then
		export BTT_GIT_WORKING_DIR="${saved_working_directory}"
	fi

	tear_down
}