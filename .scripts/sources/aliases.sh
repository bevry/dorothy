#!/usr/bin/env sh

# Highlight clipboard code as RTF for keynote
# styles: https://help.farbox.com/pygments.html
alias highlight="pbpaste | pygmentize -g -f rtf -O 'fontface=Monaco,style=tango' | pbcopy"

# Tar
alias mktar='tar -cvzf'
alias untar='tar -xvzf'

# Database
alias startredis='redis-server /usr/local/etc/redis.conf'
alias startmongo='mongod --config /usr/local/etc/mongod.conf'

# Servers
alias serve='python -m SimpleHTTPServer 8000'

# Node
alias nic='rm -Rf node_modules yarn.lock'
alias ni='npm install --save'  # yarn add
alias nid='npm install --save-dev'  # yarn add --dev
alias nig='nvm use system; npm install -g'  # yarn is too unreliable on globals: yarn global add
alias nigr='nvm use system; npm uninstall -g'  # yarn is too unreliable on globals: yarn global remove
alias nir='npm run-script'  # yarn run
alias npmus='npm set registry http://registry.npmjs.org/'
alias npmau='npm set registry http://registry.npmjs.org.au/'
alias npmeu='npm set registry http://registry.npmjs.eu/'
# alias npmio='npm install --cache-min 999999999'

# Wget
alias wgett='echo -e "\nHave you remembered to correct the following:\n user agent, trial attempts, timeout, retry and wait times?\n\nIf you are about to leech use:\n [wgetbot] to brute-leech as googlebot\n [wgetff]  to slow-leech  as firefox (120 seconds)\nRemember to use -w to customize wait time.\n\nPress any key to continue...\n" ; read -n 1 ; wget --no-check-certificate'
alias wgetbot='wget -t 2 -T 15 --waitretry 10 -nc --user-agent="Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"'
alias wgetff='wget -t 2 -T 15 --waitretry 10 -nc -w 120 --user-agent="-user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6""'

# Administration
alias sha1check='openssl sha1 '
alias takeownership='sudo chown -R $USER .'
alias svnshowexternals='svn propget -R svn:externals .'
alias search='find . -name'
alias allow='chmod +x'
alias sha256='shasum -a 256'
alias filecount='find . | wc -l'

# Git
alias ga='git add'
alias gu='git add -u'
alias gp='git push'
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'
alias gpo='gp origin; gp origin --tags'
alias gup='git pull origin'
alias gap='git remote | xargs -L1 git push'
alias gitclean='rm -rf .git/refs/original/; git reflog expire --expire=now --all; git gc --prune=now; git gc --aggressive --prune=now'
alias gitsvnupdate='git svn rebase'
alias gitrm='git ls-files --deleted | xargs git rm'
alias githooks='edit .git/hooks/pre-commit'
