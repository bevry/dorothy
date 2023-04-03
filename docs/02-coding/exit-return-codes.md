# Exit and Return Codes

Your command should always use an exit code that is meaningful.

You can find the standardised exit codes [here](https://gist.github.com/shinokada/5432e491f9992da994fbed05948bfba1) or by running the `errno -l` utility from [moreutils](https://rentes.github.io/unix/utilities/2015/07/27/moreutils-package/) like so:

```bash
# install it
get-installer --invoke errno
# invoke it
errno -l
```

## returning

Your return statement should look like so:

```bash
return 22 # EINVAL Invalid argument
```

For a successful exit code, your return statement should be `return` instead of `return 0`, and ideally should be omitted.

## capturing

To get the specific exit code of a command, you can use `$?` like so:

```bash
local ec
ec=0 && the-command and its args || ec="$?"
```

## ignoring

If you don't care if a command passes or fails, but would still like to continue with execution, you can do:

```bash
the-command and its args || :
```

Which is a shorthand for `|| true`, both of which return `0` as the exit code.
