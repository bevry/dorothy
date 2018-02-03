#!/usr/bin/env sh

function secure {
	if confirm "[y] to delete all history, [n] to delete some"; then
		echo 'deleting all'
		history -c
	else
		echo 'deleting some'
		echo 'all' | history delete --contains "http POST"
		echo 'all' | history delete --contains "http -f POST"
		echo 'all' | history delete --contains "vault"
		echo 'all' | history delete --contains "key"
		echo 'all' | history delete --contains "token"
	fi
	echo 'deleted'
}