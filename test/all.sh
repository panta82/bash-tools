THIS_DIR="$(cd $(dirname $0) && pwd)"

source "$THIS_DIR/../.utils.sh"

INFO "Loaded"

_define_option opt1 "-o" "Test option" "default"

_opts_standard_sequence "$@"

INFO "Started"