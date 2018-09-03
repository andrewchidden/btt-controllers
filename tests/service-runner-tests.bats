#!/usr/bin/env bats

#####
# DESCRIPTION: Unit tests for the service-runner shell script.
#####


##### @interface #####
btt_usr_root=${BTT_USR_ROOT:-~/bettertouchtool}
service_runner='./utils/service-runner.sh'
test_root_directory='/tmp/btt/tests' # Passed to the service runner.
test_pid_filepaths=(
	"${test_root_directory}/volume-service/pid"
	"${test_root_directory}/eventkit-service/pid"
)


##### @implementation #####
function set_up() {
	# Create a test root system directory for the servicer runner.
	mkdir -p "${test_root_directory}"

	# Remove any existing pid test files.
	for filepath in "${test_pid_filepaths[@]}"; do
		rm -f "${filepath}"
	done
}

function tear_down() {
	# Kill any service processes that were created.
	for filepath in "${test_pid_filepaths[@]}"; do
		touch "${filepath}"
		pid="$(cat $filepath)"
		if [[ ( -n "${pid}" ) && ( -n "$(ps -p${pid} -o 'pid=')" ) ]]; then
			kill -9 "${pid}"
		fi
		rm -f "${filepath}"
	done
}

function mock_killed_pids() {
	for filepath in "${test_pid_filepaths[@]}"; do
		echo 99000 > "${filepath}"
	done
}

# $1: Process identifier to check.
function verify_service_start() {
	if [[ ( -z "$1" ) || ( -z "$(ps -p$1 -o 'pid=')" ) ]]; then
		exit 1
	fi
}

# $1: Expected process identifier.
# $2: Path to pid file.
function verify_pid_matches() {
	local expected_pid="$1"
	local pid
	pid="$(cat $2)"
	[[ "${pid}" = "${expected_pid}" ]]
}

@test 'start services' {
	set_up

	# When service runner is executed
	"${service_runner}" "${btt_usr_root}" "${test_root_directory}"
	# Then it should start all services.
	local pid_array=()
	for filepath in "${test_pid_filepaths[@]}"; do
		local pid
		pid="$(cat ${filepath})"
		verify_service_start "${pid}"
		pid_array+=("${pid}")
	done

	# When the service runner is executed again
	"${service_runner}" "${test_root_directory}"
	# Then it should not re-initialize any services.
	local index=0
	for saved_pid in "${pid_array[@]}"; do
		local filepath="${test_pid_filepaths[$index]}"
		verify_pid_matches "${saved_pid}" "${filepath}"
		((index++))
	done

	tear_down
}

@test 're-starts killed services' {
	set_up

	mock_killed_pids

	# When service runner is executed
	"${service_runner}" "${btt_usr_root}" "${test_root_directory}"
	# Then it should start all previously killed services.
	for filepath in "${test_pid_filepaths[@]}"; do
		local pid
		pid="$(cat ${filepath})"
		verify_service_start "${pid}"
	done

	tear_down
}