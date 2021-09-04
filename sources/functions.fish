#!/usr/bin/env fish

function secure_history
	set action (choose-option --question='What do you want to delete?' --filter=$argv[1] --label -- 'some' 'delete only the known risks' 'all' 'erase your entire history')
	if test "$action" = 'all'; then
		history -c
		echo 'Erased everything.'
	else
		echo 'all' | history delete --contains 'auth'
		echo 'all' | history delete --contains 'cookie'
		echo 'all' | history delete --contains 'env'
		echo 'all' | history delete --contains 'http -f POST'
		echo 'all' | history delete --contains 'http POST'
		echo 'all' | history delete --contains 'key'
		echo 'all' | history delete --contains 'op '
		echo 'all' | history delete --contains 'secret'
		echo 'all' | history delete --contains 'session'
		echo 'all' | history delete --contains 'token'
		echo 'all' | history delete --contains 'twurl'
		echo 'all' | history delete --contains 'vault'
		echo 'all' | history delete --contains 'youtube-dl'
		echo 'Erased known risks.'
	end
end