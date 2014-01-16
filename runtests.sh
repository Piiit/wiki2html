#!/bin/bash

clear
make clean >&2
make >&2

for ARG in "$@"
do
	if [[ ! "$ARG" =~ "_expected.txt" ]]; then 
		if [ -f "${ARG%.*}_expected.txt" ]; then 
			echo ============================================================================= >&2
			echo TESTING: $ARG >&2
			./wiki < "$ARG" 2>/dev/null | diff -c ${ARG%.*}_expected.txt - >&2
			if [ $? -eq 0 ]; then
				echo "TEST SUCCEEDED: $ARG"
			else
				echo "TEST FAILED: $ARG"
			fi
			echo ============================================================================= >&2
		else
			echo "TEST SKIPPED: '$ARG' (no EXPECTED RESULT file)"
		fi
	fi
done


exit 0
