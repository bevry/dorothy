#!/usr/bin/env sh

function secure {
	if confirm "[y] to delete all history, [n] to delete some"; then
		history -c
	else
		history delete --contains "http POST"
		history delete --contains "http -f POST"
	fi
}