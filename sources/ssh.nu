#!/usr/bin/env nu

# https://www.nushell.sh/cookbook/ssh_agent.html#manage-ssh-passphrases
# https://www.nushell.sh/cookbook/ssh_agent.html
# https://www.nushell.sh/commands/docs/def-env.html#examples
# https://www.nushell.sh/commands/docs/load-env.html#frontmatter-title-for-filesystem

# ssh-agent handling
command-exists 'ssh-agent' | complete; if $env.LAST_EXIT_CODE == 0 {
	# start ssh-agent and export SSH_AUTH_SOCK and SSH_AGENT_PID
	if 'SSH_AUTH_SOCK' not-in $env {
		ssh-agent -c
			| lines
			| first 2
			| parse 'setenv {name} {value};'
			| transpose -r
			| into record
			| load-env
	}

	# trap not supported yet by nushell
	# https://github.com/nushell/nushell/issues/8360
}
