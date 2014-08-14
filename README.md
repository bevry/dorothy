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
printf "\n\n# Source our custom profile configuration\nsource ~/.userprofile.sh" >> ~/.profile
printf "\n\n# Source our custom profile configuration\nsource ~/.userprofile.sh" >> ~/.bash_profile
printf "\n\n# Source our custom rc configuration\nsource ~/.userrc.sh" >> ~/.bashrc
```


## License

Public domain
