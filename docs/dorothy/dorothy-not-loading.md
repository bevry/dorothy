# What to do if Dorothy is not loading

You've installed Dorothy, opened a new terminal, but none of the Dorothy commands are available?

It could be that your terminal application is refusing to operate your shell as a login shell, which is how Dorothy (and many other applications) identify whether they should complete loading themselves. If Dorothy were to load itself on non-login shells then every shell command would also have to load Dorothy which would be be an unnecessary slow down to every shell command! By having Dorothy only load inside login shells, we allow everything to work perfectly.

So what to do when your terminal isn't opening a login shell?

## Manual Invocation

You can manually invoke a login shell by executing any of these commands:

- Bash: `bash -l`
- ZSH: `zsh -l`
- Fish: `fish -l`
- Nu: `nu -l`
- Xonsh: `xonsh -l`
- Elvish: elvish doesn't have the concept of login shells, so this does not apply.
- Dash: `dash -l`
- KSH: `ksh -l`

## Gnome Terminal (Ubuntu, Debian, etc.)

Open the `Terminal` application. In the top menu bar, tap the `Terminal` application title, then open `Preferences`:

![Screenshot of the Ubuntu Terminal Menubar](https://github.com/bevry/dorothy/blob/master/docs/assets/login-shell-ubuntu-menubar.png?raw=true)

Navigate to the active profile, select `Command`, and ensure that the login shell preference enabled/checked:

![Screenshot of the Ubuntu Terminal Preferences](https://github.com/bevry/dorothy/blob/master/docs/assets/login-shell-ubuntu-preferences.png?raw=true)

Close the Preferences and open a new terminal tab.

## Visual Studio Code

1. Open the Visual Studio Code Command Palette (`Ctrl + Shift + P` on Windows, `Command + Shift + P` on macOS).

1. Open `Preferences: User Settings (JSON)` via typing and enter.

1. Merge the following JSON with your own JSON:

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

1. Save the settings.

1. Use the menu bar `Terminal: New Terminal` or the Command Palette `Terminal: Create New Terminal` to open a new terminal.

## Konsole (KDE)

1. Navigate to` Settings` ▸ `Console`.

1. Click `Profiles`.

1. Set a name for your profile.

1. Click `Default profile`

1. Type one of the [Manual Invocation](#manual-invocation) commands in the command textbox, e.g. for Bash type `bash -l`.

1. Close the Preferences and open a new terminal tab.

## Emacs (vterm.el)

Set the variable `vterm-shell` to be one of the [Manual Invocation](#manual-invocation) commands, e.g. for Zsh you can use:

```lisp
(setq vterm-shell "/bin/zsh -l")
```
