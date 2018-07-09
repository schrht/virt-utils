
run() { echo -e "\n> $@" && [ -z $dryrun ] && eval $@; }

split() {

	# Basic check
	[ -z "$1" ] && return 1
	[ ! -z $(echo "$1" | tr -d "0-9\-\,\.") ] && return 1

	# Split
	numstr=$(echo "$1" | sed 's/-/../g')

	if [ -z $(echo "$numstr" | tr -d "[:digit:]") ]; then
		nums="$numstr"
	else
		for num in $(eval echo {$numstr}); do
			if [[ $num =~ ".." ]]; then
				[ -z "$nums" ] && nums="$(eval echo {$num})" || nums="$nums $(eval echo {$num})"
			else
				[ -z "$nums" ] && nums=$num || nums="$nums $num"
			fi
		done
	fi

	echo $nums

	return 0
}

