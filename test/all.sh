THIS_DIR="$(cd $(dirname $0) && pwd)"

source "$THIS_DIR/../tools.sh"

log "Loaded"

USAGE_HEADER="All tools demonstration, since we are lacking proper tests..."

define_option "switch1" "-s1:" "Description of switch 1"

opts_standard_sequence "$@"

log "Value of switch1: ${OPT_VALUES[switch1]}"

warn "Test of a warning!"
error "Test of an error!"

_VERBOSITY_LEVEL_=2

warn "Lowered verbosity, you should no longer see infos!"
log "You shouldn't see this"

_VERBOSITY_LEVEL_=1

error "You should see only errors now"
warn "You shouldn't see this"
log "You shouldn't see this"

_VERBOSITY_LEVEL_=0

error "You shouldn't see this"
warn "You shouldn't see this"
log "You shouldn't see this"

_VERBOSITY_LEVEL_=5

log "Testing fatal..."
fatal "Nothing bad happened, just a test"