# Terminals and TTY

## Glossary

- `read -t 0` is detecting if data is currently available on STDIN
- `[[ -t 0 ]]` is detecting if STDIN is attached to a TTY
- `read -rei` is using readline to interact with the TTY to display a default value

Refer to `debug-terminal-stdin` and `debug-terminal-tty` for additional implementation details

## STDIN

### Detection

| technique             | context                              | result                                                                                                                                     |
| --------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `file /dev/stdin`     | direct                               | `/dev/stdin: character special (16/4)`                                                                                                     |
| `file /dev/stdin`     | immediate pipe/redirection           | `/dev/stdin: fifo (named pipe)`                                                                                                            |
| `file /dev/stdin`     | delayed pipe/redirection             | `/dev/stdin: fifo (named pipe)`                                                                                                            |
| `file /dev/stdin`     | background task: all                 | `/dev/stdin: character special (3/2)`                                                                                                      |
| `file /dev/stdin`     | ssh -T: direct                       | `/dev/stdin: fifo (named pipe)`                                                                                                            |
| `file /dev/stdin`     | GitHub Actions: direct               | `/dev/stdin: symbolic link to /proc/self/fd/0` `/proc/self/fd/0: symbolic link to pipe:[16750]` `/dev/fd/0: symbolic link to pipe:[16750]` |
| `file /dev/stdin`     | GitHub Actions: background task: all | `/dev/stdin: symbolic link to /proc/self/fd/0` `/proc/self/fd/0: symbolic link to /dev/null` `/dev/fd/0: symbolic link to /dev/null`       |
| --------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `read -t 0`           | direct                               | exit status `1`                                                                                                                            |
| `read -t 0`           | immediate pipe/redirection           | exit status `0`                                                                                                                            |
| `read -t 0`           | delayed pipe/redirection             | exit status `1`                                                                                                                            |
| `read -t 0`           | background task: all                 | exit status `0`                                                                                                                            |
| `read -t 0`           | ssh -T: direct                       | exit status `1`                                                                                                                            |
| `read -t 0`           | GitHub Actions: direct               | exit status `0`                                                                                                                            |
| `read -t 0`           | GitHub Actions: background task: all | exit status `0`                                                                                                                            |
| --------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `[[ -t 0 ]]`          | direct                               | exit status `0`                                                                                                                            |
| `[[ -t 0 ]]`          | immediate pipe/redirection           | exit status `1`                                                                                                                            |
| `[[ -t 0 ]]`          | delayed pipe/redirection             | exit status `1`                                                                                                                            |
| `[[ -t 0 ]]`          | background task: all                 | exit status `1`                                                                                                                            |
| `[[ -t 0 ]]`          | ssh -T: direct                       | exit status `1`                                                                                                                            |
| `[[ -t 0 ]]`          | GitHub Actions: direct               | exit status `1`                                                                                                                            |
| `[[ -t 0 ]]`          | GitHub Actions: background task: all | exit status `1`                                                                                                                            |
| --------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `[[ -p /dev/stdin ]]` | direct                               | exit status `1`                                                                                                                            |
| `[[ -p /dev/stdin ]]` | immediate pipe/redirection           | exit status `0`                                                                                                                            |
| `[[ -p /dev/stdin ]]` | delayed pipe/redirection             | exit status `0`                                                                                                                            |
| `[[ -p /dev/stdin ]]` | background task: all                 | exit status `1`                                                                                                                            |
| `[[ -p /dev/stdin ]]` | ssh -T: direct                       | exit status `0`                                                                                                                            |
| `[[ -p /dev/stdin ]]` | GitHub Actions: direct               | exit status `0`                                                                                                                            |
| `[[ -p /dev/stdin ]]` | GitHub Actions: background task: all | exit status `1`                                                                                                                            |
| --------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `[[ -c /dev/stdin ]]` | direct                               | exit status `0`                                                                                                                            |
| `[[ -c /dev/stdin ]]` | immediate pipe/redirection           | exit status `1`                                                                                                                            |
| `[[ -c /dev/stdin ]]` | delayed pipe/redirection             | exit status `1`                                                                                                                            |
| `[[ -c /dev/stdin ]]` | background task: all                 | exit status `0`                                                                                                                            |
| `[[ -c /dev/stdin ]]` | ssh -T: direct                       | exit status `1`                                                                                                                            |
| `[[ -c /dev/stdin ]]` | GitHub Actions: direct               | exit status `1`                                                                                                                            |
| `[[ -c /dev/stdin ]]` | GitHub Actions: background task: all | exit status `0`                                                                                                                            |
| --------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `[[ -r /dev/stdin ]]` | direct                               | exit status `0`                                                                                                                            |
| `[[ -r /dev/stdin ]]` | immediate pipe/redirection           | exit status `0`                                                                                                                            |
| `[[ -r /dev/stdin ]]` | delayed pipe/redirection             | exit status `0`                                                                                                                            |
| `[[ -r /dev/stdin ]]` | background task: all                 | exit status `0`                                                                                                                            |
| `[[ -r /dev/stdin ]]` | ssh -T: direct                       | exit status `0`                                                                                                                            |
| `[[ -r /dev/stdin ]]` | GitHub Actions: direct               | exit status `0`                                                                                                                            |
| `[[ -r /dev/stdin ]]` | GitHub Actions: background task: all | exit status `0`                                                                                                                            |
| --------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `[[ -w /dev/stdin ]]` | direct                               | exit status `0`                                                                                                                            |
| `[[ -w /dev/stdin ]]` | immediate pipe/redirection           | exit status `0`                                                                                                                            |
| `[[ -w /dev/stdin ]]` | delayed pipe/redirection             | exit status `0`                                                                                                                            |
| `[[ -w /dev/stdin ]]` | background task: all                 | exit status `0`                                                                                                                            |
| `[[ -w /dev/stdin ]]` | ssh -T: direct                       | exit status `0`                                                                                                                            |
| `[[ -w /dev/stdin ]]` | GitHub Actions: direct               | exit status `0`                                                                                                                            |
| `[[ -w /dev/stdin ]]` | GitHub Actions: background task: all | exit status `0`                                                                                                                            |
| --------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `read -rei`           | direct                               | default shown and exit status `0` if enter pressed or `1` if nothing sent                                                                  |
| `read -rei`           | immediate pipe/redirection           | default ignored and exit status `0` if input sent or `1` if nothing sent                                                                   |
| `read -rei`           | delayed pipe/redirection             | default ignored and exit status `0` if input sent or `1` if nothing sent                                                                   |
| `read -rei`           | background task: all                 | input and default ignored and exit status `1`, regardless of piping and redirections                                                       |
| `read -rei`           | ssh -T: direct                       | default ignored and exit status `0` if enter pressed or `142` if timed out                                                                 |
| `read -rei`           | GitHub Actions: direct               | default ignored and exit status `0` if input sent, or `1` if nothing sent                                                                  |
| `read -rei`           | GitHub Actions: background task: all | input and default ignored and exit status `1`, regardless of piping and redirections                                                       |

### Observations

- direct execution is interactive within the direct context and within the `ssh -T ...` context
- direct execution is interactive and reactive within the direct context
- dirext execution is interactive but not reactive within `ssh -T ...` context, as line buffering is used, which prevents reading non-enter keys as they happen, furthermore, detection is not possible of terminal size and cursor position
- `[[ -t 0 ]]` is only true on direct execution within a direct context, as such it is detecting reactivity, rather than just interactivity
- there is no way to detect direct execution within a `ssh -T ...` context, as it is indistinguishable from pipe/redirections, as such there is no way to detect interactivity
