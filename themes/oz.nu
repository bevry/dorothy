#!/usr/bin/env nu

# https://www.nushell.sh/blog/2020-06-30-nushell_0_16_0.html#custom-prompts-jonathandturner
# https://www.nushell.sh/book/3rdpartyprompts.html#how-to-configure-3rd-party-prompts

def create_left_prompt [] {
	let last_command_exit_status =  $env.LAST_EXIT_CODE
	# todo add the test ! -d "$DOROTHY" check
	^$"($env.DOROTHY)/themes/oz" 'nu' $last_command_exit_status
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_INDICATOR = ''
