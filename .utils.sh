UTILS_PATH="${BASH_SOURCE[0]}"
if [ -z "$UTILS_PATH" ]; then
	echo "FATAL: This file must be sourced, shouldn't be run on its own" 2>&1
	exit 1
fi

UTILS_PATH="$(readlink -e $(dirname ${UTILS_PATH}))"

source $UTILS_PATH/.utils-general.sh
source $UTILS_PATH/.utils-output.sh
source $UTILS_PATH/.utils-options.sh