# Terminals and TTY

## Glossary

- `read -t 0` is detecting if data is currently available on STDIN
- `[[ -t 0 ]]` is detecting if STDIN is attached to a TTY
- `read -rei` is using readline to interact with the TTY to display a default value

Refer to `debug-terminal-stdin` and `debug-terminal-tty` for additional implementation details

## Results

Refer to `debug-terminal --test` for generating results.

## Conclusions

- direct execution is interactive within the direct context and within the `ssh -T ...` context
- direct execution is interactive and reactive within the direct context
- dirext execution is interactive but not reactive within `ssh -T ...` context, as line buffering is used, which prevents reading non-enter keys as they happen, furthermore, detection is not possible of terminal size and cursor position
- `[[ -t 0 ]]` is only true on direct execution within a direct context, as such it is detecting reactivity, rather than just interactivity
- there is no way to detect direct execution within a `ssh -T ...` context, as it is indistinguishable from pipe/redirections, as such there is no way to detect interactivity
