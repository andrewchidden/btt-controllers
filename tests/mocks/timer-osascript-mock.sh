#!/bin/bash

btt_usr_root=${BTT_USR_ROOT:-~/bettertouchtool}

[[ ( "$1" = "${btt_usr_root}/timer-app/timer-app.scpt" ) && ( "$2" = "${BTT_TEST_MOCKED_TIMER_DURATION}" ) ]]
echo "$?" > "${BTT_TEST_MOCKED_RETURN_DIR}/osascript"