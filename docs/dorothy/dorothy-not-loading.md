# What to do if Dorothy is not loading

Installed Dorothy, opened a new terminal, but none of the Dorothy commands are available?

It could be that your terminal application is refusing to operate your shell as a login shell, which is how Dorothy (and many other applications) identify whether they should complete loading themselves. If Dorothy were to load itself on non-login shells then every shell command would also have to load Dorothy which would be be an unnecessary slow down to every shell command! By having Dorothy only load inside login shells, we allow everything to work perfectly.

So what to do when your terminal isn't opening a login shell?

## Ubuntu

In the top menu bar, tap the terminal application title, and open preferences:

![Screenshot of the Ubuntu Terminal Menubar](https://github.com/bevry/dorothy/blob/master/docs/assets/login-shell-ubuntu-menubar.png?raw=true)

Navigate to the active profile, select command, and ensure that login shell is enabled:

![Screenshot of the Ubuntu Terminal Preferences](https://github.com/bevry/dorothy/blob/master/docs/assets/login-shell-ubuntu-preferences.png?raw=true)

Close the preferences and open a new terminal tab, now Dorothy should be loaded which you can verify by running `dorothy theme` to select a theme.
