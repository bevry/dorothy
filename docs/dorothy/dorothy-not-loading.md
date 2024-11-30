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

## Visual Studio Code

1. Open the Visual Studio Code Command Palette (`Ctrl + Shift + P` on Windows, `Command + Shift + P` on macOS).

2. Open `Preferences: User Settings (JSON)` via typing and enter.

3. Merge the following JSON with your own JSON:

    ```javascript
    {
      // dorothy auto-enables the vscode integration, no need for messy auto-detection
      "terminal.integrated.shellIntegration.enabled": false,
      // specify your default shell preference from below, ie. if you prefer nu, then use "nu (login)"
      "terminal.integrated.defaultProfile.osx": "bash (login)",
      "terminal.integrated.defaultProfile.linux": "bash (login)",
      // specify our login shell configurations
      "terminal.integrated.profiles.osx": {
        "bash (login)": {
          "path": "bash",
          "args": ["-l"]
        },
        "zsh (login)": {
          "path": "zsh",
          "args": ["-l"]
        },
        "fish (login)": {
          "path": "fish",
          "args": ["-l"]
        },
        "nu (login)": {
          "args": ["-l"],
          "path": "nu"
        },
      },
      "terminal.integrated.profiles.linux": {
        "bash (login)": {
          "path": "bash",
          "args": ["-l"]
        },
        "zsh (login)": {
          "path": "zsh",
          "args": ["-l"]
        },
        "fish (login)": {
          "path": "fish",
          "args": ["-l"]
        },
        "nu (login)": {
          "args": ["-l"],
          "path": "nu"
        },
      },
    }
    ```

4. Save the settings.

5. Use the menu bar `Terminal: New Terminal` or the Command Palette `Terminal: Create New Terminal` to open a new terminal. It should now start as a login shell, loading Dorothy as expected. Validate this by running a Dorothy command, like `dorothy theme`, to ensure everything is functioning as intended.
