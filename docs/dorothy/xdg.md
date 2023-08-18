# XDG

Prior to [XDG](https://wiki.archlinux.org/title/XDG_Base_Directory), most apps would dump their data directly into `$HOME`, and in Dorothy's case into `$HOME/.dorothy`. XDG however will place such application data into several specialized directories.

In XDG mode, Dorothy will:

-   Move `$HOME/.dorothy` to `${XDG_DATA_HOME:-"$HOME/.local/share"}/dorothy`
-   Symlink `$DOROTHY/user` to `${XDG_CONFIG_HOME:-"$HOME/.config"}/dorothy`

Dorothy will automatically detect if you and your system prefers XDG and use that determination during installation.

However, if you with to install or update Dorothy with a particular preference, you can use:

```bash
dorothy install --xdg
```

Whether one uses XDG or not is a matter of personal preference, it is up to you.
