#!/bin/bash

set -e
echo "selecting [$1] as your login shell"
echo "$(which $1)" | sudo tee -a /etc/shells && chsh -s "$(which $1)"
