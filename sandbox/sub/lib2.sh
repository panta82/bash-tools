echo
echo "inside lib2.sh"
echo

echo "THIS SCRIPT: $0"
echo "THIS_PATH: $(cd $(dirname $0) && pwd)"
echo "SOURCE 0: ${BASH_SOURCE[0]}"
echo "SOURCE 0 PATH: $(dirname ${BASH_SOURCE[0]})"
echo "SOURCE 1: ${BASH_SOURCE[1]}"
echo "SOURCE 2: ${BASH_SOURCE[2]}"