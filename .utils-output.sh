# Environment

_assert_partial_loaded "general"
_LOADED_PARTIAL_OUTPUT_=true

# Global settings

_DEFAULT_ERROR_SIGNAL_=1

# Global variables

# Output message to stdout. Optional suffix as second arg
_stdout() {
	local msg="$1"
	local prefix="$2"
	if [ -z "$prefix" ]; then
		echo "$msg"
	else
		if [ ! -z "$msg" ]; then
			echo "[$prefix] $msg"
		else
			echo ""
		fi
	fi
}

# Output to std err
_stderr() {
	_stdout "$1" "$2" 1>&2
}

# Exit with _DEFAULT_ERROR_SIGNAL_ or provided signal
_exit_with_error() {
	local exit_signal="$1"
	[ -z "$exit_signal" ] && exit_signal=${_DEFAULT_ERROR_SIGNAL_}
	exit $exit_signal
}

# Print INFO message
INFO() {
	_stdout "$1" "INFO"
}

# Print WARNING message
WARN() {
	_stderr "$1" "WARNING"
}

# Print fatal error and exit with error code
FATAL() {
	_stderr ""
	_stderr "$1" "FATAL"
	_exit_with_error "$2"
}

# Print and execute command
printexec() {
	local cmd=$@
	_stdout "$cmd" "CMD"
	eval "$cmd"
}