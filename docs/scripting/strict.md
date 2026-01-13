# Strict Mode

## bash version

The first line of any bash command should be:

```bash
#!/usr/bin/env bash
```

This first line tells the loader of the script to invoke it through the `bash` executable that is preferred by our `PATH` order, aka the `bash` version which is found at `which bash`. This allows the scripts to be invoked across many different environments, and with the preferred bash version the environment has. In a Dorothy environment, this will allow the Dorothy commands to run inside the latest version of bash, rather than a legacy system version.

## strict mode

Then if it is a Dorothy command, it should soon include this line:

```bash
source "$DOROTHY/sources/bash.bash"
```

Or if it is an non-Dorothy ecosystem command, it can do it like so:

```bash
if [[ -n ${DOROTHY-} ]]; then
	source "$DOROTHY/sources/bash.bash"
else
	eval "$(curl -fsSL 'https://raw.githubusercontent.com/bevry/dorothy/HEAD/sources/bash.bash')"
	eval "$(curl -fsSL 'https://raw.githubusercontent.com/bevry/dorothy/HEAD/sources/styles.bash')"
fi
```

These lines source Dorothy's [`bash.bash`](https://github.com/bevry/dorothy/blob/master/sources/bash.bash) file, which adjusts the bash option flags, and manages differences between bash versions, and includes a library of utility helpers, that transforms bash from a great shell prompt language to a great shell scripting language. See [`errors.md`](https://github.com/bevry/dorothy/blob/master/docs/bash/errors.bash) for a showcase of the demons that Dorothy's `bash.bash` slays and the treasures it stows.
