# Strict Mode

All bash commands within Dorothy should start with these two lines:

```bash
#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"
```

## bash version

The first line `#!/usr/bin/env bash` tells the loader of the script to invoke it through the `bash` executable that is preferred by our `PATH` order, aka the `bash` version which is found at `which bash`. This allows the scripts to be invoked across many different environments, and with the preferred bash version the environment has. In a Dorothy environment, this will allow the Dorothy commands to run inside the latest version of bash, rather than a legacy system version.

## strict mode

The second like `source "$DOROTHY/sources/bash.bash"` sources Dorothy's [bash.bash](https://github.com/bevry/dorothy/blob/master/sources/bash.bash) file, which customises the environment of the script to enable certain bash option flags that transform it from a great shell prompt language, to a great shell scripting language. Such as bubbling uncaught exceptions up. Primitively, this allows us to just do `cd "$path"` instead of having to do `cd "$path" || exit 1` all the time to catch the failure.
