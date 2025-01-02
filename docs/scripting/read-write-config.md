# Reading and Writing Configuration Files

If your command will make use of user configuration, you can use the following to load it:

```bash
# =====================================
# Configuration

source "$DOROTHY/sources/config.sh"

# environment may provide:
# EDITOR

# git.bash provides:
local GPG_SIGNING_KEY='' # use 'krypton' for Krypt.co
local GIT_DEFAULT_BRANCH='main'
local GIT_PROTOCOL='' # 'https', or 'ssh'
local GIT_NAME=''
local GIT_EMAIL=''
local MERGE_TOOL=''
local GITHUB_USERNAME=''
local GITLAB_USERNAME=''
# deprecations
local HUB_PROTOCOL='' # deprecated, replaced by GIT_PROTOCOL
local KRYPTON_GPG=''  # deprecated, use GPG_SIGNING_KEY=krypton
load_dorothy_config 'git.bash'
# handle deprecations
if [[ "$KRYPTON_GPG" = 'yes' ]]; then
	GPG_SIGNING_KEY='krypton'
fi
if [[ -z "$GIT_PROTOCOL" && -n "$HUB_PROTOCOL" ]]; then
	GIT_PROTOCOL="$HUB_PROTOCOL"
fi

```

And the following to write it:

```bash
dorothy-config 'git.bash' --prefer=local -- \
	--field='GIT_DEFAULT_BRANCH' --value="$GIT_DEFAULT_BRANCH" \
	--field='GIT_EMAIL' --value="$GIT_EMAIL" \
	--field='GIT_NAME' --value="$GIT_NAME" \
	--field='GIT_PROTOCOL' --value="$GIT_PROTOCOL" \
	--field='GITHUB_USERNAME' --value="$GITHUB_USERNAME" \
	--field='GITLAB_USERNAME' --value="$GITLAB_USERNAME" \
	--field='GPG_SIGNING_KEY' --value="$GPG_SIGNING_KEY" \
	--field='MERGE_TOOL' --value="$MERGE_TOOL"
```
