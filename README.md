# [Benjamin Lupton's](http://balupton.com) Dotfiles

## Install

### Pull the repo into your home directory

``` bash
cd ~
git init
git remote add origin https://github.com/balupton/dotfiles.git
git pull origin master  --force
```

### Tell your system to load the custom configurations

```
printf "\n\n# Source our custom profile configuration\nsource ~/.userprofile" >> ~/.profile
printf "\n\n# Source our custom rc configuration\nsource ~/.userrc" >> ~/.bashrc
```


## License

Public domain
