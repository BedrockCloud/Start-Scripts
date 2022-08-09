#!/bin/bash
DIR="$(cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "$DIR"

DO_LOOP="yes"

while getopts "p:f:l" OPTION 2> /dev/null; do
	case ${OPTION} in
		p)
			PHP_BINARY="$OPTARG"
			;;
		f)
			CLOUD_FILE="$OPTARG"
			;;
		l)
			DO_LOOP="yes"
			;;
		\?)
			break
			;;
	esac
done

if [ "$PHP_BINARY" == "" ]; then
	if [ -f bin/php7/bin/php ]; then
		export PHPRC=""
		PHP_BINARY="bin/php7/bin/php"
	elif [[ ! -z $(type php) ]]; then
		PHP_BINARY=$(type -p php)
	else
		echo "No PHP Binary found."
		exit 1
	fi
fi

if [ "$CLOUD_FILE" == "" ]; then
	if [ -f src/Cloud/CloudStarter.php ]; then
		CLOUD_FILE="src/Cloud/CloudStarter.php"
	else
		echo "Cloud not found"
		exit 1
	fi
fi



LOOPS=0

set +e
while [ "$LOOPS" -eq 0 ] || [ "$DO_LOOP" == "yes" ]; do
	if [ "$DO_LOOP" == "yes" ]; then
		"$PHP_BINARY" "$CLOUD_FILE" $@
	else
		exec "$PHP_BINARY" "$CLOUD_FILE" $@
	fi
	if [ "$DO_LOOP" == "yes" ]; then
		if [ ${LOOPS} -gt 0 ]; then
			echo "Restarted $LOOPS times"
		fi 
		echo "To escape the loop, press CTRL+C now. Otherwise, wait 3 seconds for the server to restart."
		echo ""
		sleep 2
		((LOOPS++))
	fi
done
