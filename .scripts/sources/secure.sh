#!/usr/bin/env sh

function secure {
	if test "$(choose all some)" = "all"; then
		echo 'deleting all'
		history -c
	else
		echo 'deleting some'
		echo 'all' | history delete --contains "http POST"
		echo 'all' | history delete --contains "http -f POST"
		echo 'all' | history delete --contains "vault"
		echo 'all' | history delete --contains "key"
		echo 'all' | history delete --contains "token"
		echo 'all' | history delete --contains "env"
		echo 'all' | history delete --contains "session"
		echo 'all' | history delete --contains "cookie"
		echo 'all' | history delete --contains "secret"
		echo 'all' | history delete --contains "op "
	fi
	echo 'deleted'
}