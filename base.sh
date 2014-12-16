# Base module system. All tools require this.

[[ -z "${_TOOLS_DIR_}" ]] || return

# Settings

_MODULE_FILE_DEFAULT_EXTENSION_=".sh"

# Declare module globals

declare -A _LOADED_MODULES_=(
	["$(readlink -e "${BASH_SOURCE[0]}")"]=true
)

[[ -z "${THIS_DIR}" ]] && THIS_DIR="$(cd $(dirname $0) && pwd)"
_TOOLS_DIR_="$(dirname ${BASH_SOURCE[0]})"

declare -a _MODULE_SEARCH_PATHS_=("${_TOOLS_DIR_}" "${THIS_DIR}")

# Load one or multiple modules. Can take absolute paths, relative paths or just names (with or without extension).
# By default, modules are searched within bash_tools and the application directory.
# Modules are loaded only once. Due to scoping issues, the output of require() calls should be executed.
#    `require "/home/user/dev/my_module.sh"`
#    $(require general output "lib/my_module")
_require() {
	local name
	local search_path
	local path
	for name in "$@"; do
		if [[ "${name:0:1}" == "/" ]]; then
			[[ ! -f "$name" ]] && echo "FATAL! Couldn't find module $name" 1>&2 && exit 1
			path="${name}"
		else
			for search_path in "${_MODULE_SEARCH_PATHS_[@]}"; do
				path="$(readlink -f "${search_path}/$name")"
				if [[ -f "$path" ]]; then
					break
				else
					path="${path}${_MODULE_FILE_DEFAULT_EXTENSION_}"
					if [[ -f "$path" ]]; then
						break
					else
						path=""
					fi
				fi
			done
			[[ ! -f "$path" ]] && echo "FATAL! Couldn't find module $name" 1>&2 && exit 1
		fi

		[[ "${_LOADED_MODULES_["$path"]}" ]] && continue

		echo eval "source '$path' ; _LOADED_MODULES_['$path']=true ; "
	done
}
require() {
	_require "$@"
}