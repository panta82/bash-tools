# Load all modules. Replacement for source base.sh

source "$(dirname ${BASH_SOURCE[0]})/base.sh"

$(_require "general" "output" "options")
#$(_require "general")
#$(_require "output")
#$(_require "options")
