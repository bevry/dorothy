{
	while ( match($0, /"[^"]*"|: false|: true|: [0-9]+/) ) {
		inner = substr($0, RSTART, RLENGTH)
		if ( inner ~ /^: / ) {
			inner = substr(inner, 3)
		} else if ( inner ~ /^"/ ) {
			inner = substr(inner, 2, length(inner) - 2)
		}
		if ( inner == option_property ) {
			found = 1
		} else if ( found ) {
			print inner
			exit
		}
		$0 = substr($0, RSTART + RLENGTH)
	}
}
