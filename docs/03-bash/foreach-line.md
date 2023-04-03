# Run a Command for Each Line in Bash

Sources:

-   [Stack Exchange: How to apply shell command to each line of a command output?](https://stackoverflow.com/a/68310927/130638)

Advice:

```bash
ls -1 | xargs -I %s -- echo %s
```
