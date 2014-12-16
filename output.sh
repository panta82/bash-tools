# Output to stdout and stderr

[[ -z "${_TOOLS_DIR_}" ]] && echo "Base not loaded!" >&2 && exit 1

# Global settings

	# If nothing is supplied, this is the signal process will error out with
	_DEFAULT_ERROR_SIGNAL_=1

	# Verbosity level, influences the way all output functions are acting
	_VERBOSITY_LEVEL_=3

	# Equalize all badges to this width. Clear to disable
	_BADGE_WIDTH_=7

	# If true, output is colorized. Without this, color arguments are ignored
	_COLORS_=true

# Output message to stdout.
#     msg: Message to print
#     badge: Optional badge to add before msg
#     badge_color: Style to use for badge, if COLORS is enabled. Otherwise, uses [BADGE] style.
#     msg_color: Style to use for msg, if COLORS is enabled
# Colors should be strings compiled from standard escape codes, see here: http://misc.flogisoft.com/bash/tip_colors_and_formatting
_stdout() {
	local msg="$1"
	local badge="$2"
	local badge_color="$3"
	local msg_color="$4"
	
	[[ -z "$msg" ]] && echo '' && return

	$_COLORS_ && [[ ! -z "$msg_color" ]] && msg="${msg_color}$msg\\e[0m"
	
	if [[ ! -z $badge ]]; then
		if [[ ! -z $_BADGE_WIDTH_ ]]; then
			local before_badge
			local after_badge
			(( before_badge = ( ${_BADGE_WIDTH_} - ${#badge} ) / 2 ))
			(( after_badge = ${_BADGE_WIDTH_} - $before_badge - ${#badge} ))
			badge=$( printf "%${before_badge}s%s%${after_badge}s" '' $badge '' )
		fi
		if $_COLORS_ ; then
			[[ ! -z "$badge_color" ]] && badge="${badge_color}$badge\\e[0m"
		else
			badge="[$badge]"
		fi
	fi

	echo -e "${badge} ${msg}"
}

# Output to stderr
_stderr() {
	_stdout "$@" 1>&2
}

# Exit with _DEFAULT_ERROR_SIGNAL_ or provided signal
_exit_with_error() {
	local exit_signal="$1"
	[[ -z "$exit_signal" ]] && exit_signal=${_DEFAULT_ERROR_SIGNAL_}
	exit $exit_signal
}

# Print INFO message, verbosity 3+
log() {
	[[ $_VERBOSITY_LEVEL_ -lt 3 ]] && return
	_stdout "$1" "INFO" '\e[42m'
}

# Print WARNING message, verbosity 2+
warn() {
	[[ $_VERBOSITY_LEVEL_ -lt 2 ]] && return
	_stderr "$1" "WARNING" '\e[103m\e[90m' '\e[93m'
}

# Print ERROR message, verbosity 1+
error() {
	[[ $_VERBOSITY_LEVEL_ -lt 1 ]] && return
	_stderr "$1" "ERROR" '\e[41m' '\e[31m'
}

# Print DEBUG LVL 1 message, verbosity 4+
dbg1() {
	[[ $_VERBOSITY_LEVEL_ -lt 4 ]] && return
	_stdout "$1" "DBG1" '\e[44m\e[37m'
}

# Print DEBUG LVL 2 message, verbosity 5+
dbg2() {
	[[ $_VERBOSITY_LEVEL_ -lt 5 ]] && return
	_stdout "$1" "DBG2" '\e[100m' '\e[90m'
}

# Print fatal error and exit with error code, verbosity 1+
fatal() {
	if [[ $_VERBOSITY_LEVEL_ -ge 1 ]]; then
		_stderr ""
		_stderr "$1" "FATAL" '\e[41m' '\e[31m'
	fi
	_exit_with_error "$2"
}

# Print and execute command
printexec() {
	local cmd=$@
	_stdout "$cmd" "CMD"
	eval "$cmd"
}