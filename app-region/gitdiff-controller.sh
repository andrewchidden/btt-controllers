#!/bin/bash

#####
# DESCRIPTION: Fetches the Git diff stats for a working directory
# and parses those stats into a compact and readable format.
#
# USAGE: ./gitdiff-controller.sh
#     <sys_root>
#         Path to the BetterTouchTool system service and caches folder.
#     <git_path>
#         Optional path to the Git executable to use. Only used under test.
#     <working_directory>
#         Optional path to the Git working directory to perform diff on. If
#         not specified, the environment variable `BTT_GIT_WORKING_DIR` is
#         used instead.
#####


##### @interface #####
# Optionally set the `BTT_SYS_ROOT` environment variable to the internal system 
# folder used by services to save and share state. Defaults to `~/.btt`
sys_root_arg=${1:-${BTT_SYS_ROOT}}
btt_sys_root=${sys_root_arg:-~/.btt}

# Path to the Git executable to use. Only used for mocks during testing.
git_bin_path=${2:-'git'}

# The working directory to use for Git diff stats. Set the `BTT_GIT_WORKING_DIR`
# environment variable to control the Git working directory BetterTouchTool will
# perform actions on (including command+option+control macros).
working_directory_arg=${3:-${BTT_GIT_WORKING_DIR}}
working_directory=${working_directory_arg:-''}


##### @implementation #####
if [[ -z "${working_directory}" ]]; then
	echo 'No working directory'
	exit 0
fi
cd "${working_directory}"

status_directory="${btt_sys_root}/gitdiff-controller"
status_filepath="${status_directory}/cached-status"
mkdir -p "${status_directory}"
touch "${status_filepath}"

cached_status="$(cat ${status_filepath})"
current_status="$(${git_bin_path} --no-optional-locks status -vv)"

cached_diff_path="${status_directory}/cached-diff"
cached_diff="$(cat ${cached_diff_path})"

if [[ ( "${cached_status}" != "${current_status}" ) || ( -z "${cached_diff}" ) ]]; then
	current_diff="$(${git_bin_path} diff HEAD --shortstat)"

	if [[ -z "${current_diff}" ]]; then
		current_diff="Working tree is clean"
	else
		if ! [[ "${current_diff}" = *"insertion"* ]]; then
			current_diff="${current_diff/ deletions(-)/)}"
			current_diff="${current_diff/ deletion(-)/)}"
			current_diff="${current_diff/changed, /changed (+0 / −}"
		elif ! [[ "${current_diff}" = *"deletion"* ]]; then
			current_diff="${current_diff/ insertions(+)/ / −0)}"
			current_diff="${current_diff/ insertion(+)/ / −0)}"
			current_diff="${current_diff/changed, /changed (+}"
		else
			current_diff="${current_diff/changed, /changed (+}"
			current_diff="${current_diff/ insertions(+), / / −}"
			current_diff="${current_diff/ insertion(+), / / −}"
			current_diff="${current_diff/ deletions(-)/)}"
			current_diff="${current_diff/ deletion(-)/)}"
		fi

		current_diff="${current_diff/ changed/}"
	fi
	
	echo "${current_diff}" > "${cached_diff_path}"
	echo "${current_status}" > "${status_filepath}"

	echo "${current_diff}"
else
	echo "${cached_diff}"
fi