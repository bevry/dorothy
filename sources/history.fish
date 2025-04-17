#!/usr/bin/env fish

function secure_history
	set action (choose --question='What do you want to delete?' --default=$argv[1] --label -- 'some' 'delete only the known risks' 'all' 'erase your entire history')
	if test "$action" = 'all'; then
		history -c
		printf '%s\n' 'Erased everything.'
	else
		printf '%s\n' 'all' | history delete --contains 'auth'
		printf '%s\n' 'all' | history delete --contains 'cookie'
		printf '%s\n' 'all' | history delete --contains 'env'
		printf '%s\n' 'all' | history delete --contains 'http -f POST'
		printf '%s\n' 'all' | history delete --contains 'http POST'
		printf '%s\n' 'all' | history delete --contains 'key'
		printf '%s\n' 'all' | history delete --contains 'op '
		printf '%s\n' 'all' | history delete --contains 'secret'
		printf '%s\n' 'all' | history delete --contains 'session'
		printf '%s\n' 'all' | history delete --contains 'token'
		printf '%s\n' 'all' | history delete --contains 'twurl'
		printf '%s\n' 'all' | history delete --contains 'vault'
		printf '%s\n' 'all' | history delete --contains 'youtube-dl'
		printf '%s\n' 'all' | history delete --contains 'coda register'
		printf '%s\n' 'Erased known risks.'
	end
end
