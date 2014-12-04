declare -A hash
hash=()

hash[a]="A"
hash[b]=B

echo "All elements: ${hash[@]}"
echo "All keys: ${!hash[@]}"

#echo "a: ${hash[a]}"
#echo "b: ${hash[b]}"
#echo "c: ${hash[c]}"

check() {
	[[ ${hash[$1]} ]] && echo "Has $1" || echo "Doesn't have $1"
}

check a
check b
check c