# zypper

## container

```
docker run --rm -it opensuse/leap:latest
docker run --rm -it opensuse/tumbleweed:latest
```

## resources

- <https://www.mankier.com/8/zypper>
- <https://www.mankier.com/8/zypper#Commands-Package_Management_Commands>
- <https://en.opensuse.org/Portal:Zypper>
- <https://documentation.suse.com/smart/linux/single-html/reference-zypper-install/index.html>

## notes

- installs RPM files and remote YaST2 and RPM packages
- zypper needs sudo

```
--recommends
Install also recommended packages in addition to the required ones. The default behavior is determined by [zypp.conf:solver.onlyRequires].

--no-recommends
Do not install recommended packages, but only required ones. The default behavior is determined by [zypp.conf:solver.onlyRequires].

-y, --no-confirm
Don’t require user interaction. It’s recommended to use the --non-interactive global option instead. Global options are passed before the command (zypper --non-interactive COMMAND ...). Unlike the no-confirm command option, the global option can be used together with any zypper command.

-n, --non-interactive
Switches to non-interactive mode. In this mode zypper doesn’t ask user to type answers to various prompts, but uses default answers automatically. Those default answers also depend on other options like --no-gpg-checks or --ignore-unknown.
```