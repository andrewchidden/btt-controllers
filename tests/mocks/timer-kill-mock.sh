#!/bin/bash

[[ ( "$1" = "-9" ) && ( "$2" = "${BTT_TEST_MOCKED_TIMER_PID}" ) ]]
echo "$?" > "${BTT_TEST_MOCKED_RETURN_DIR}/kill"