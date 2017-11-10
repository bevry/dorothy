# [Benjamin Lupton's](http://balupton.com) Dotfiles

Goes well with my [New Machine Starter Kit](https://gist.github.com/balupton/5259595).


## Install

``` bash
bash -il
eval "$(curl -fsSL https://raw.githubusercontent.com/balupton/dotfiles/master/.scripts/commands/install-dotfiles)"
```

Put your private environment configuration into `.scripts/env.sh`

If you would like to do the setup process manually, refer to:

- https://github.com/balupton/dotfiles/blob/master/.scripts/commands/install-dotfiles
- https://github.com/balupton/dotfiles/blob/master/.scripts/commands/setup-dotfiles


## Explanation

The dotfiles reside inside [`$HOME/.scripts`](https://github.com/balupton/dotfiles/tree/master/.scripts) which contains:

- [`commands` directory](https://github.com/balupton/dotfiles/tree/master/.scripts/commands) contains executable commands
- [`sources` directory](https://github.com/balupton/dotfiles/tree/master/.scripts/sources) contains scripts that are loaded into the shell environment
- [`themes` directory](https://github.com/balupton/dotfiles/tree/master/.scripts/themes) contains themes that you can select via the `THEME` environment variable
- [`init.fish`](https://github.com/balupton/dotfiles/blob/master/.scripts/init.fish) the initialisation script for the fish shell
- [`init.sh`](https://github.com/balupton/dotfiles/blob/master/.scripts/init.sh) the initialisation script for other shells

The initialisation scripts are loaded via the changes made to your dotfiles via the [`setup-dotfiles`](https://github.com/balupton/dotfiles/blob/master/.scripts//commands/setup-dotfiles) command.

To setup your machine with the exact same apps and preferences as Benjamin Lupton, then install the dotfiles, then run `install`, and every now and run `update` to keep thing updated.

## License

Public domain
