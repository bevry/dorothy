#!/usr/bin/env fish

function secure
	if confirm "[y] to delete all history, [n] to delete some"
		history -c
	else
		history delete --contains "http POST"
		history delete --contains "http -f POST"
	end
end