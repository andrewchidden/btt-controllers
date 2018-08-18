#!/bin/bash

if [[ ( "$1" = '--no-optional-locks' ) && ( "$2" = 'status' ) && ( "$3" = '-vv' ) ]]; then
	echo "${BTT_TEST_MOCKED_GITSTATUS_RETURN}"
elif [[ ( "$1" = 'diff' ) && ( "$2" = 'HEAD' ) && ( "$3" = '--shortstat' ) ]]; then
	echo "${BTT_TEST_MOCKED_GITDIFF_RETURN}"
else
	exit 1
fi