bash-tools
==========

Some bash tools to ease up scripting. Targeted bash version: 4.1

## Usage

<sup>terminal:</sup>
```bash
git clone git@github.com:panta82/bash-tools.git
touch myscript.sh
chmod +x myscript.sh
nano myscript.sh
```

<sup>myscript.sh:</sup>
```bash
THIS_DIR="$(cd $(dirname $0) && pwd)"
source "$THIS_DIR/bash-tools/tools.sh"

# Process command line arguments and options

USAGE_HEADER="Description of my script"
define_option "switch1" "-s1:" "Description of switch 1"

opts_standard_sequence "$@"

log "Value of switch1: ${OPT_VALUES[switch1]}"

# Load your own modules

$(require module1 ./subdir/module2.sh)

```

You can also use just the module you need

<sup>myscript.sh:</sup>
```bash
THIS_DIR="$(cd $(dirname $0) && pwd)"
source "$THIS_DIR/bash-tools/base.sh"

$(require general output)

```

## Licence

Apache 2.0
