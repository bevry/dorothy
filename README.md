# [Benjamin Lupton's](http://balupton.com) Dotfiles

Goes well with my [New Machine Starter Kit](https://gist.github.com/balupton/5259595).


## Install

``` bash
# Optional Cleaning
rm ~/.profile
rm ~/.bash_profile
rm ~/.bashrc
rm ~/.zshrc

# Clone the repository into your home directory
cd ~
git init
git remote add origin https://github.com/balupton/dotfiles.git
git pull origin master  --force

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
