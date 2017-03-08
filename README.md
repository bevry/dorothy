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
export DOTFILE='# Source our custom dotfile configuration\nsource "$HOME/.scripts/init.sh"'
printf 'export # Theme\nexport THEME="baltheme"' >> ~/.scripts/env.sh

# OSX
printf "\n\n$DOTFILE" >> ~/.bash_profile

# Linux
printf "\n\n$DOTFILE" >> ~/.bashrc

# ZSH
printf "\n\n$DOTFILE" >> ~/.zshrc
```

Put your private environment configuration into `.scripts/env.sh`


## License

Public domain
