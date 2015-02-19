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
# Optional Cleaning
rm ~/.profile
rm ~/.bash_profile
rm ~/.bashrc
rm ~/.zshrc

# Prepare
export USERPROFILE='# Source our custom profile configuration\nsource "$HOME/.userprofile.sh"'
export USERRC='# Source our custom rc configuration\nsource "$HOME/.userrc.sh"'

# Linux
printf "\n\n$USERPROFILE" >> ~/.profile
printf "\n\n$USERRC" >> ~/.bashrc

# OSX: https://github.com/balupton/dotfiles/blob/master/.userprofile.sh
printf "\n\n$USERPROFILE\n\n$USERRC" >> ~/.bash_profile

# ZSH
printf "\n\n$USERPROFILE\n\n$USERRC" >> ~/.zshrc
```


## License

Public domain
