#!/usr/bin/env fish

function secure_history
	set what $argv[1]
	if is-empty-string "$what"
		set what (choose all some)
	end
	if test "what" = "all"
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
		echo 'all' | history delete --contains "twurl"
		echo 'all' | history delete --contains "vault"
		echo 'all' | history delete --contains "youtube-dl"
	end
	echo 'deleted'
end