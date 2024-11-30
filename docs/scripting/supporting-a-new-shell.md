# Supporting a new Shell

It is easy to integrate Dorothy into any shell of your choosing.

Checklist:

- What is the extension of the shell?
- How to detect if an environment variable is set?
- How to define a function?
- How to set a variable that is shared between sourced scripts?
- How to set an environment variable?
- How to detect if the shell is a login shell?
- How to source another script?
- How to eval code?
- How to set the prompt and title of the shell?

The following files need addition or modification.

- `setup-util-*` to enable installation of the shell
- `init.*` the first entry of the integration
- `sources/config.*` the ability to load configuration files for the shell
- `sources/env.bash` outputs the environment configuration commands
- `sources/environment.*` the evaluation of the environment configuration commands
- `sources/history.*` the ability to clear sensitive information from the shell (optional)
- `sources/login.*` configuration for the login shell
- `sources/ssh.*` support for the ssh agent
- `sources/theme.*` and `themes/*.*` support for cross-shell theming
- `config/shells.bash` to add `select-shell` support for the shell
