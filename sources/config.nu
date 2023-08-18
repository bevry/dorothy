#!/usr/bin/env nu

# https://www.nushell.sh/book/how_nushell_code_gets_run.html#common-mistakes
# https://www.nushell.sh/blog/2022-09-06-nushell-0_68.html#source-becomes-source-env-jt-kubouch
# https://www.nushell.sh/commands/docs/source.html#frontmatter-title-for-core
# https://www.nushell.sh/commands/docs/source-env.html#frontmatter-title-for-core

# nushell does not support dynamic sourcing

def load_dorothy_config [...filenames: string] {
	echo-style --error='Nushell does not support dynamic loading of configuration files.' >/dev/stderr
	return 2  # No such file or directory
}
