# Builtins in Bash

Bash provides [many builtins](https://www.gnu.org/software/bash/manual/bash.html#Bash-Builtins) that we can leverage, such as `test` and `source`.

You can learn more about a particular builtin by invoking the `help` builtin against it, like so:

```bash
# learn about the test builtin
help test
```

If you want to learn about all the builtins, just run `help` standalone:

```bash
# learn about all the builtins
help
```

If you are in another interactive shell besides bash, you can do:

```bash
bash -c help test
# and
bash -c help
```
