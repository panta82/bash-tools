THIS_DIR="$(cd $(dirname $0) && pwd)"
source "$THIS_DIR/../tools.sh"

echo "${!_LOADED_MODULES_[@]}"

log "WTF?"


_require "general" "output" "options"