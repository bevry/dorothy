#!/bin/bash

# Cleaners
function rmdir {
	rm -Rfd "$1"
}
alias rmsvn='find . -name ".svn" -exec rmdir {} \;'
alias rmtmp='find ./* -name ".tmp*" -exec rmdir {} \;'
alias rmsync='find . -name ".sync" -exec rmdir {} \;'
alias rmmodules='find ./* -name "node_modules" -exec rmdir {} \;'
