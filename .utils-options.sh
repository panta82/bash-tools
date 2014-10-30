# Environment

_assert_partial_loaded "general"
_assert_partial_loaded "output"
_LOADED_PARTIAL_OPTIONS_=true

# Global settings

_OPTION_EQUALS_REGEX_="^([a-zA-Z0-9_-]+) *= *(.*)$"
_OPTION_NUMBER_REGEX_=""
_OPTIONS_FILE_NAME_SUFFIX_=".conf"

# Global variables

USAGE_HEADER=
OPTIONS_FILE=false

declare -A OPT_DEFINITIONS
OPT_DEFINITIONS=(
	["help"]="-h,--help"
	["verbose"]="-v+,--verbose:"
)

declare -A OPT_DESCRIPTIONS
OPT_DESCRIPTIONS=(
	["help"]="This help screen"
	["verbose"]="Verbosity level (default: <default>)"
)

declare -A OPT_DEFAULTS
OPT_DEFAULTS=(
	["help"]="false"
	["verbose"]="0"
)

declare -A OPT_VALUES
OPT_VALUES=()

declare -a OPT_UNPARSED

# Call as a shorthand to define an option
# First two arguments are mandatory
#     define_option help "-h,--help" "Show help screen" false
_define_option() {
	local key="$1"
	local definition="$2"
	OPT_DEFINITIONS[$key]=$definition
	if [ ! -z "$3" ]; then
		OPT_DESCRIPTIONS[$key]="$3"
	fi
	if [ ! -z "$4" ]; then
		OPT_DEFAULTS[$key]="$4"
	fi
}

# Check if the user is root. If not, prints out a message and exits
_assert_root() {
	_is_root || FATAL "This script must be run as root"
}

# Print usage with switches
# Uses OPT_NAMES global
_print_usage() {
	local header="$1"
	local key
	local -a defs
	local def
	local def_type
	local -a def_parts
	local usage_line
	local def_string
	local -A def_strings
	local longest_def_string=0
	local switch_format
	local description

	# Build up and print the usage line (eg: /script.sh [-h][-foo]...)
	# Also fill up def_strings array and determine the longest string there
	usage_line="Usage: $0 "
	for key in "${!OPT_DEFINITIONS[@]}"; do
		def_parts=()
		IFS=',' read -a defs <<< "${OPT_DEFINITIONS[$key]}"
		for def in "${defs[@]}"; do
			def_type="${def: -1}"
			case $def_type in
				:)
					def_parts+=("${def:0:-1} ${key^^}")
					;;
				=)
					def_parts+=("${def}${key^^}")
					;;
				+)
					def_parts+=("${def:0:-1}[${def:1:-1}+]")
					;;
				*)
					def_parts+=("$def")
					;;
			esac
		done
		def_string="$(_join_to_string 'echo' ', ' "${def_parts[@]}")"
		usage_line="$usage_line[$def_string]"
		def_strings[$key]="$def_string"
		if [ ${#def_string} -gt "$longest_def_string" ]; then
			longest_def_string=${#def_string}
		fi
	done
	_stdout "$usage_line"

	# Print provided header or default header set through a global variable
	[ -z "$header" ] && header="$USAGE_HEADER"
	if [ ! -z "$header" ]; then
		_stdout ""
		_stdout "$header"
	fi

	# Print out option descriptions
	switch_format="%-${longest_def_string}s"
	_stdout ""
	for key in "${!def_strings[@]}"; do
		description="${OPT_DESCRIPTIONS[$key]}"
		description="${description/<default>/${OPT_DEFAULTS[$key]}}"
		_stdout "    $(printf "$switch_format" "${def_strings[$key]}")    ${description}"
	done
}

# Overridable version
print_usage() {
	_print_usage "$@"
}

# A quick shortcut to print usage and exit if supplied -h argument
_try_show_help_and_exit() {
	if [ "${OPT_VALUES["help"]}" = true ]; then
		print_usage
		exit 0
	fi
}

# Load default options. Should be called once all the options have been loaded
_opts_from_defaults() {
	for key in "${!OPT_DEFAULTS[@]}"; do
		if [ ! -z "${OPT_DEFAULTS[$key]}" ]; then
			OPT_VALUES[$key]="${OPT_DEFAULTS[$key]}"
		fi
	done
}

# Parse arguments, which should be passed along
#     _opts_from_args "$@"
_opts_from_args() {
	local key
	local arg
	local def
	local -a defs
	local -A opt_reverse
	local def_type
	local waiting_key=
	local option_found
	local arg_key
	local arg_value
	local plus_regex
	local plus_value
	local list_delimiter

	for key in "${!OPT_DEFINITIONS[@]}"; do
		IFS=',' read -a defs <<< "${OPT_DEFINITIONS[$key]}"
		for def in "${defs[@]}"; do
			opt_reverse["$def"]="$key"
		done
	done

	for arg in "$@"; do
		if [ ! -z "$waiting_key" ]; then
			OPT_VALUES[$waiting_key]="$arg"
			waiting_key=
			continue
		fi

		if [[ $arg =~ $_OPTION_EQUALS_REGEX_ ]]; then
			arg_key="${BASH_REMATCH[1]}"
			arg_value="${BASH_REMATCH[2]}"
		else
			arg_key=
		fi

		option_found=false
		for def in "${!opt_reverse[@]}"; do
			def_type="${def: -1}"
			key=${opt_reverse["$def"]}
			case $def_type in
				:)
					# Whitespace style --switch value, -s value
					if [ "${def:0:-1}" = "$arg" ]; then
						waiting_key="$key"
						option_found=true
					fi
					;;
				=)
					# Equals style --switch=value, -s=value
					if [ "$arg_key" = "${def:0:-1}" ]; then
						OPT_VALUES[$key]="$arg_value"
						option_found=true
					fi
					;;
				+)
					# Additive: -d, -dd, -ddd
					plus_regex="^-(${def:1:-1}+)$"
					if [[ $arg =~ $plus_regex ]]; then
						plus_value="${BASH_REMATCH[1]}"
						plus_value="${#plus_value}"
						OPT_VALUES[$key]="$(expr "${OPT_VALUES[$key]}" + $plus_value 2>/dev/null || echo $plus_value)"
						option_found=true
					fi
					;;
				*)
					# Switches: -h, -y, --once
					if [ "${def}" = "$arg" ]; then
						OPT_VALUES[$key]=true
						option_found=true
					fi
					;;
			esac
			if [ "$option_found" = true ]; then
				break
			fi
		done

		if [ "$option_found" = false ]; then
			OPT_UNPARSED+=($arg)
		fi
	done
}

# Writes out options file path. For a program /home/jack/test.sh, path will be /home/jack/test.conf
_options_file_get_path() {
	_ensure_this_path
	local options_file_name="$(basename "$0")"
	options_file_name="${options_file_name%.*}${_OPTIONS_FILE_NAME_SUFFIX_}"
	echo "$THIS_PATH/$options_file_name"
}

# Load options from a conf file. First argument is custom config file path. If the second argument
# is 'true', options will be loaded even if they were not predefined using _define_option
#     _opts_from_file /etc/myscript.conf true
_opts_from_file() {
	local options_file="$1"
	local dynamic="$2"

	if [ -z "$options_file" ] && [ "$OPTIONS_FILE" = false ]; then
		# We don't want to load options file
		return 0
	fi

	# Try to set options file from global value
	[ -z "$options_file" ] && [ "$OPTIONS_FILE" != true ] && options_file="$OPTIONS_FILE"
	
	# Use default global file
	[ -z "$options_file" ] && options_file="$(_options_file_get_path)"
	
	if [ ! -f "$options_file" ]; then
		WARN "Options file $options_file not found"
		return 1
	fi

	local line
	while read line; do
		if [[ $line =~ $_OPTION_EQUALS_REGEX_ ]]; then
			local key="${BASH_REMATCH[1]}"
			local value="${BASH_REMATCH[2]}"
			
			if [ ! -z "${OPT_DEFINITIONS[$key]}" ] || [ "$dynamic" = "true" ]; then
				OPT_VALUES[$key]="$value"
			else
				OPT_UNPARSED+=($key)
			fi
		fi
	done < "$options_file"
}

# Standard loading sequence of setting up options from multiple sources
# Should be given all command line arguments
#     _opts_standard_sequence "$@"
_opts_standard_sequence() {
	_opts_from_defaults

	_opts_from_file

	if [ ${#OPT_UNPARSED[@]} -gt 0 ]; then
		FATAL "Unsupported options in $(_options_file_get_path): $(_join_to_string echo ', ' "${OPT_UNPARSED[@]}"). Run with -h for more info."
	fi

	_opts_from_args "$@"

	_try_show_help_and_exit

	if [ ${#OPT_UNPARSED[@]} -gt 0 ]; then
		FATAL "Unsupported command line arguments: $(_join_to_string echo ', ' "${OPT_UNPARSED[@]}"). Run with -h for more info."
	fi
}
