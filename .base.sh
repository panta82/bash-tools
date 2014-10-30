# Environment

[ -z "${_LOADED_MODULE_GENERAL_}"] && return
_LOADED_MODULE_GENERAL_=true


# Make sure that $THIS_PATH and $THIS_REL_PATH are set
_ensure_this_path() {
	[ -z "$THIS_REL_PATH" ] && THIS_REL_PATH="`dirname \"$0\"`"
	[ -z "$THIS_PATH" ] && THIS_PATH=`readlink -e $this_rel_path`
}

# Call from other partials or main code to ensure everything that is needed is included
#     _assert_partial_loaded "general"
_assert_partial_loaded() {
	local value="$(eval echo "\$_LOADED_PARTIAL_${1^^}_")"
	if [ -z "$value" ]; then
		echo "[FATAL] Partial not loaded: $1" 1>&2
		exit 1
	fi
}

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
	while [ ! -z "$1" ]; do
		echo_cmd="${echo_cmd}${separator}${1}"
		shift
	done
	echo_cmd="$echo_cmd'\""

	#local echo_args="echo \"'$*'\""
	eval $cmd "$(eval "$echo_cmd")"
}

_is_root() {
	[[ $EUID -eq 0 ]]
	return "$?"
}