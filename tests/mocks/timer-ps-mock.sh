#!/bin/bash

[[ ( "$1" = '-p' ) && ( "$2" = "${BTT_TEST_MOCKED_TIMER_PID}" ) && ( "$3" = '-o' ) && ( "$4" = 'pid=' ) ]]
verify_pid="$?"

[[ ( "$1" = 'aux' ) && ( -z "$2" ) ]]
verify_aux="$?"

[[ ( "${verify_pid}" -eq 0 ) || ( "${verify_aux}" -eq 0 ) ]]
status="$?"

echo "${verify_aux} ${verify_aux} ${status} | $1 $2 $3 $4 | ${BTT_TEST_MOCKED_TIMER_PID}" > ~/wtf

echo "${status}" > "${BTT_TEST_MOCKED_RETURN_DIR}/ps"
if [[ "${status}" -eq 0 ]]; then
	if [[ "${verify_pid}" -eq 0 ]]; then
		echo "${BTT_TEST_MOCKED_TIMER_PID}"
	else
		echo "${BTT_TEST_MOCKED_TIMER_PS_AUX}"
	fi
fi