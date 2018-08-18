#!/bin/bash

[[ ( "$1" = "-p${BTT_TEST_MOCKED_TIMER_PID}" ) && ( "$2" = '-o' ) && ( "$3" = 'pid=' ) ]]
status="$?"
echo "${status}" > "${BTT_TEST_MOCKED_RETURN_DIR}/ps"
if [[ "${status}" -eq 0 ]]; then
	echo "${BTT_TEST_MOCKED_TIMER_PID}"
fi