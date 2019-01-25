#!/usr/bin/env sh

function secure_history {
	WHAT="$1"
	if test -z "$WHAT"; then
		WHAT="$(choose all some)"
	fi
	if test "WHAT" = "all"; then
		echo 'deleting all'
		history -c
	else
		echo 'deleting some'
		echo 'all' | history delete --contains "auth"
		echo 'all' | history delete --contains "cookie"
		echo 'all' | history delete --contains "env"
		echo 'all' | history delete --contains "http -f POST"
		echo 'all' | history delete --contains "http POST"
		echo 'all' | history delete --contains "key"
		echo 'all' | history delete --contains "op "
		echo 'all' | history delete --contains "secret"
		echo 'all' | history delete --contains "session"
		echo 'all' | history delete --contains "token"
		echo 'all' | history delete --contains "vault"
		echo 'all' | history delete --contains "youtube-dl"
	fi
	echo 'deleted'
}