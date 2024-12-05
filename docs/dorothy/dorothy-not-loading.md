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

5. Use the menu bar `Termina: New Terminal` or the Command Palette `Terminal: Create New Terminal` to open a new terminal. It should now start as a login shell, loading Dorothy as expected. Validate this by running a Dorothy command, like `dorothy theme`, to ensure everything is functioning as intended.

## Debian Gnome

1. Select Edit ▸ Preferences.

2. In the sidebar, click on the + button next to the Profiles label.

3. Enter a name for the new profile. You can change this name later.

4. Click Create to create the new profile.

5. Navigate to command and select 'Run a custom command instead of my shell.'

6. Type in 'bash -l' to use bash as your command (or another shell of your choosing with the login shell mode enabled).

7. Click on the arrow next to the profile name (in the left hand sidebar).

9. Select 'Set as default.'

10. Save the profile and restart your terminal.

Source: https://help.gnome.org/users/gnome-terminal/stable/pref-profiles.html.en

## Debian Konsole (KDE)

Note: 'Konsole doesn’t provide convenience for running login shell, because developers don’t like
the idea of running login shell in a terminal emulator.
Of course, users still can run login shell in Konsole if they really need to. Edit the profile in use and modify its command to the form of starting a login shell explicitly, such as "bash -l" and
"zsh -l" Source: https://docs.kde.org/stable5/en/konsole/konsole/konsole.pdf

If the benefits of configuring Konsole in this manner outweighs the cons, proceed with the following steps:

1. Navigate to Settings -> Console.

2. Click Profiles.

3. Set a name for your profile.

4. Click 'Default profile'

5. Type /bin/bash -l in the command textbox (or another shell of your choosing with the login shell mode enabled).

## Manual Execution of Dorothy in Debian/Ubuntu

If you prefer to open a bash shell directly, you can do so via the command 'bash -l' without having to configure a Terminal profile.

However, this means that upon restarting your terminal you will also have to open a bash shell again.
