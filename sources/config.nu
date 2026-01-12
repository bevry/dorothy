#!/usr/bin/env nu

# https://www.nushell.sh/book/how_nushell_code_gets_run.html#common-mistakes
# https://www.nushell.sh/blog/2022-09-06-nushell-0_68.html#source-becomes-source-env-jt-kubouch
# https://www.nushell.sh/commands/docs/source.html#frontmatter-title-for-core
# https://www.nushell.sh/commands/docs/source-env.html#frontmatter-title-for-core

# nushell does not support dynamic sourcing, also anything it sources must exist prior to execution, as such
# if ( printf '%s\n' 'path' | path exists ) {
# 	source 'path'
# }
# is useless, as if [path] doesn't exist, [source 'path'] will still fail

def load_dorothy_config [...filenames: string] {
	echo-style --stderr --error='Nu does not support dynamic loading of configuration files.'
	return 1 # EPERM 1 Operation not permitted
}
