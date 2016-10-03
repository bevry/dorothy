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
export USERDOTFILE='# Source our custom dotfile configuration\nsource "$HOME/.user.sh"'
printf 'export LOADEDDOTFILES="$LOADEDDOTFILES .userenv.sh"\n\n# Theme\nexport THEME="baltheme"' >> ~/.userenv.sh

# OSX
printf "\n\n$USERDOTFILE" >> ~/.bash_profile

# Linux
printf "\n\n$USERDOTFILE" >> ~/.bashrc

# ZSH
printf "\n\n$USERDOTFILE" >> ~/.zshrc
```

Put your private environment configuration into `.userenv.sh`


## License

Public domain
