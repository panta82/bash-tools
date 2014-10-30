THIS_DIR="$(cd $(dirname $0) && pwd)"

echo "TEST: $THIS_DIR"
echo "TEST SOURCE: ${BASH_SOURCE[0]}"

source "$THIS_DIR/sub/lib.sh"

