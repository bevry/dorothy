#!/usr/bin/env sh

function secure {
	if test "$(choice all some)" = "all"; then
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
	fi
	echo 'deleted'
}