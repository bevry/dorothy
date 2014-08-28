# [Benjamin Lupton's](http://balupton.com) Dotfiles

Goes well with my [Things I Use](https://gist.github.com/balupton/5259595) listing.


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
export USERPROFILE='# Source our custom profile configuration\nsource "$HOME/.userprofile.sh"'
export USERRC='# Source our custom rc configuration\nsource "$HOME/.userrc.sh"'
printf "\n\n$USERPROFILE" >> ~/.profile
printf "\n\n$USERPROFILE" >> ~/.bash_profile
printf "\n\n$USERRC" >> ~/.bashrc
rm ~/.zshrc >> printf "\n\n$USERPROFILE\n\n$USERRC" >> ~/.zshrc
```


## License

Public domain
