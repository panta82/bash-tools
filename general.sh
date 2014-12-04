# General tools

[[ -z "${_TOOLS_DIR_}" ]] && echo "Base not loaded!" >&2 && exit 1

# Joins multiple arguments into a single custom-separated string
# and calls the passed command with it as the first argument
#    _join_to_string <command> <separator> <arg1> <arg2> <arg3>...
#        eg:
#    _join_to_string echo ',' 1 2 3  # > 1,2,3
_join_to_string() {
	local cmd="$1"
	shift
	local separator="$1"
	shift
	local echo_cmd="echo \"'$1"
	shift
	while [[ ! -z "$1" ]]; do
		echo_cmd="${echo_cmd}${separator}${1}"
		shift
	done
	echo_cmd="$echo_cmd'\""

	#local echo_args="echo \"'$*'\""
	eval $cmd "$(eval "$echo_cmd")"
}
join_to_string() {
	_join_to_string "$@"
}

# Returns true if current user is root
_is_root() {
	[[ $EUID -eq 0 ]]
	return "$?"
}
is_root() {
	_is_root "$@"
}