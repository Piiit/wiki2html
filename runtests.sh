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

for ARG in "$@"
do
	if [[ ! "$ARG" =~ "_expected.txt" ]]; then 
		if [ -f "${ARG%.*}_expected.txt" ]; then 
			echo ============================================================================= >&2
			echo TESTING: $ARG >&2
			./wiki < "$ARG" 2>/tmp/wiki2html_tests_debug | diff -Bbc ${ARG%.*}_expected.txt - >&2
			if [ $? -eq 0 ]; then
				echo "TEST SUCCEEDED: $ARG"
			else
				if [ $VERBOSE -eq 1 ]; then
					cat	/tmp/wiki2html_tests_debug
				fi
				echo "TEST FAILED: $ARG"
			fi
			echo ============================================================================= >&2
		else
			echo "TEST SKIPPED: '$ARG' (no EXPECTED RESULT file)"
		fi
	fi
done


exit 0
