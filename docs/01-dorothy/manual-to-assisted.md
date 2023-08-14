# Manual to Assisted Installations

Prior to Dorothy, when installing a new machine we would have to manually restore a backup, or if doing a clean install, would have to manually reinstall everything - and if it was a different environment, or a new operating system version, that may mean having to remember or discover all the quirks of that environment, such as incompatibilities or different package managers.

Dorothy revolutionizes this approach of manual repetition and failures, to crowd shared efficiency. Just like how `homebrew` automates installations on macOS, Dorothy maintains setup configuration across platforms, including with homebrew.

So rather than running `brew install git bash`, you would add `'git' 'bash'` to your `HOMEBREW_INSTALL=(...)` array inside your `$DOROTHY/user/config/setup.bash` file. With this, next time you run `setup-install` or `setup-update` they'll get installed/updated.

In fact, if instead of placing them inside `HOMEBREW_INSTALL=(...)`, if you placed them inside `SETUP_UTILS=(...)` like so `SETUP_UTILS=('git' 'bash')` then `setup-install` and `setup-update` will trigger the `setup-util-git` and `setup-util-bash` commands ensuring they are setup in a cross-platform way! Making movements between say macOS and various Linux distributions even easier!

For more information:

-   [Dorothy's default `setup.bash` configuration](https://github.com/bevry/dorothy/blob/master/config/setup.bash)
-   [@balupton's custom `setup.bash` configuration](https://github.com/balupton/dotfiles/blob/master/config/setup.bash)

---

If you wish to customize what is installed on what, you can use the following inside your `$DOROTHY/user/config/setup.bash` file:

```bash
#!/usr/bin/env bash

# based on hostname
hostname="$(get-hostname)"
if test "$hostname" = '...'; then
    # ...
else
    # ...
fi

# based on platform
if is-mac; then
    # ...
elif is-ubuntu; then
    # ...
fi

# based on architecture
# https://github.com/bevry/dorothy/blob/master/commands/get-arch
arch="$(get-arch)"
if test "$arch" = 'a64'; then
   # arm 64
else
   # not arm 64
fi
```

If you would like private installation configuration, refer to [our guide on utilizing `config.local`](https://github.com/bevry/dorothy/blob/master/docs/02-starting-with-dorothy/private-configuration.md)
