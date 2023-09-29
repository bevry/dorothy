#!/usr/bin/env xonsh

# https://xon.sh/t

def oz_prompt():
	last_cmd = __xonsh__.history[-1] if __xonsh__.history else None
	status = last_cmd.rtn if last_cmd else 0
	return $(@($DOROTHY + '/themes/oz') 'xonsh' @(status) | cat)

$PROMPT = oz_prompt
