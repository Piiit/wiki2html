#!/bin/bash


function showHelp {
	echo "Command: $0 [OPTIONS]... [FILES]..."
	echo "Compiles wiki2html and runs test-cases for it, compares the output of a method with an expected-output file."
	echo "Returns SUCCEEDED for outputs that are equal to the expected file content."
	echo "Needed: A input file (<something>.txt) and an expected output file (<something>_expected.txt)."
	echo
	echo "OPTIONS:"
	echo "  -h, --help          Show this help message"
	echo "  -v, --verbose       Prints additional information, if a test fails"
}

OPTIND=1
VERBOSE=0

while getopts "hv" key
do
	case $key in
		h)
			showHelp	
			exit 0
		;;
		v)
			VERBOSE=1
		;;
		*)
			echo "'$0 -h' gives you more information."
			exit 1
		;;
	esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

clear && make clean >&2 && make >&2 || exit 1

ERRCOUNT=0
SKIPCOUNT=0
TESTCOUNT=0

for ARG in "$@"
do
	if [[ ! "$ARG" =~ "_expected.txt" ]]; then 
		if [ -f "${ARG%.*}_expected.txt" ]; then 
			let TESTCOUNT=TESTCOUNT+1
			test $VERBOSE -eq 1 && echo ============================================================================= >&2
			test $VERBOSE -eq 1 && echo TESTING: $ARG >&2
			./wiki < "$ARG" 2>/tmp/wiki2html_tests_debug | diff -Bbc ${ARG%.*}_expected.txt - >&2
			if [ $? -eq 0 ]; then
				echo "TEST SUCCEEDED: $ARG"
			else
				test $VERBOSE -eq 1 && cat /tmp/wiki2html_tests_debug
				echo "TEST FAILED   : $ARG"
				let ERRCOUNT=ERRCOUNT+1
			fi
			test $VERBOSE -eq 1 && echo ============================================================================= >&2
		else
			let SKIPCOUNT=SKIPCOUNT+1
			test $VERBOSE -eq 1 && echo "TEST SKIPPED: '$ARG' (no EXPECTED RESULT file)"
		fi
	fi
done

echo ">>> DONE: $TESTCOUNT tests, $ERRCOUNT failures, $SKIPCOUNT skipped."
test $ERRCOUNT -eq 0 && echo ">>> RESULT: ALL TESTS PASSED!" || echo ">>> RESULT: ERRORS REPORTED!"

exit 0
