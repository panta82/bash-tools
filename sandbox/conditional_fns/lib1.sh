if ! declare -p INFO &>/dev/null; then
	INFO() {
		echo "TEMP: $1"
	}
fi

INFO "Loading 1..."
INFO "1 loaded"