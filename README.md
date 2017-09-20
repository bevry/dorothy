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

# Enforce correct permissions
chmod +x ./.scripts/commands/*

# If you want to use my theme
printf '\n\n# Theme\nexport THEME="baltheme"' >> ~/.scripts/env.sh

# Load the dotfiles for BASH in OSX
printf '\n\n# Source our custom dotfile configuration\nsource "$HOME/.scripts/init.sh"' >> ~/.bash_profile

# Load the dotfiles for BASH in Linux
printf '\n\n# Source our custom dotfile configuration\nsource "$HOME/.scripts/init.sh"' >> ~/.bashrc

# Load the dotfiles for ZSH
printf '\n\n# Source our custom dotfile configuration\nsource "$HOME/.scripts/init.sh"' >> ~/.zshrc

# Load the dotfiles for FISH
printf '\n\n# Source our custom dotfile configuration\nsource "$HOME/.scripts/init.fish"' >> ~/.scripts/init.fish
```

Put your private environment configuration into `.scripts/env.sh`


## License

Public domain
