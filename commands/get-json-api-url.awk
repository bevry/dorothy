{
	last_inner = ""
	url = ""
	while ( match($0, /"[^"]*"/) ) {
		inner = substr($0, RSTART + 1, RLENGTH - 2)
		if ( last_inner == "url" && inner ~ /\/releases\/[0-9]+$/ ) {
			url = inner
		} else if ( last_inner == "tag_name" && inner == option_tag ) {
			print url
			exit
		}
		last_inner = inner
		$0 = substr($0, RSTART + RLENGTH)
	}
}
