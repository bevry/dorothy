# Encrypted Configuration

## Using Strongbox

Dorothy has first-class support for encrypting your user configuration with [Strongbox](https://github.com/uw-labs/strongbox).

To setup an already encrypted repository with Strongbox:

> When installing Dorothy, if the installer detects the user configuration repository uses Strongbox, Dorothy will automatically install Strongbox and prompt you to configure your Strongbox Key.

To setup your existing repository with Strongbox;

1. `cd "$DOROTHY/user"` to enter into the Dorothy user configuration
2. `setup-util-strongbox` to install Strongbox
3. [Follow the Strongbox usage instructions](https://github.com/uw-labs/strongbox#usage)
