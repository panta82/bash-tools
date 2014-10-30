G1="start"
declare -a G3

f1() {
	G1="F1"
	G2="F1"
	declare -a G4
	G3+=("F1")
	G4+=("F1")
}

print() {
	echo "G1='$G1', G2='$G2', G3='${G3[@]}', G4='${G4[@]}'"
}

print
f1
print

