THIS_DIR="$(cd $(dirname $0) && pwd)"

source "$THIS_DIR/../tools.sh"

log "Loaded"

USAGE_HEADER="All tools demonstration, since we are lacking proper tests..."

define_option "switch1" "-s1:" "Description of switch 1"

opts_standard_sequence "$@"

log "Value of switch1: ${OPT_VALUES[switch1]}"