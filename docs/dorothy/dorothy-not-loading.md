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



## Windows - Visual Studio Code, Remote Connection to WSL2

To ensure Dorothy loads correctly in Visual Studio Code when using a Remote Connection to WSL2, it's necessary to configure your terminal settings to open as a login shell(especially for nushell). Here's how to set this up:

1. Open Visual Studio Code settings. You can do this by pressing `Ctrl + ,` or selecting `Settings` from the Command Palette (`Ctrl + Shift + P`).

2. Navigate to the terminal settings by searching for "terminal integrated profiles Linux."

3. Under "Profiles: Linux," find your preferred shell (e.g., bash, zsh, or another). If it's not listed, you might need to add a new profile.

4. For your selected shell profile, set the `args` property to include `-l` and `-i`. The `-l` argument ensures the shell operates as a login shell, while `-i` makes it interactive, which is necessary for Dorothy to load correctly.

Here's a JSON snippet as an example for bash:

```json
"terminal.integrated.profiles.linux": {
    "bash": {
        "path": "bash",
        "args": ["-l", "-i"],
        "icon": "terminal-bash"
    },
    NuShell": {
        "path": "/home/linuxbrew/.linuxbrew/bin/nu",
        "args": ["-l", "-i"],
        "icon": "fold"
    }
    // Include other shells if necessary
},
```

5. Save the settings and restart Visual Studio Code.

6. Open a new terminal session. It should now start as a login shell, loading Dorothy as expected. Validate this by running a Dorothy command, like `dorothy theme`, to ensure everything is functioning as intended.

This configuration ensures a smooth integration of Dorothy with your development environment in Visual Studio Code when connected to WSL2, providing a seamless experience.

