#!/usr/bin/env sh

# we are in posix, so can't use bash's &> shortcut

# silent is done to prevent rsync ssh failures
# https://fixyacloud.wordpress.com/2020/01/26/protocol-version-mismatch-is-your-shell-clean/

# fix gpg errors, caused by lack of authentication of gpg key, caused by pinentry not being aware of tty
#   error: gpg failed to sign the data
#   fatal: failed to write commit object
# you can test it is working via:
#   setup-git
#   printf '%s\n' 'test' | gpg --clearsign
# if you are still getting those errors, check via `gpg-helper list` that your key has not expired
# if it has, then run `gpg-helper extend`
if command-exists -- gpg; then
	export GPG_TTY
	GPG_TTY="$(tty)"
fi

# only work on environments that have an ssh-agent
if command-exists -- ssh-agent; then
	# ensure ask pass is discoverable by the agent
	if [ -z "${SSH_ASKPASS-}" ] && command-exists -- ssh-askpass; then
		export SSH_ASKPASS
		SSH_ASKPASS="$(command -v ssh-askpass)" # as this is sh instead bash, use [command -v ...] not [type -P ...]
	fi
	# setting [SSH_ASKPASS_REQUIRE] to [prefer] voids TTY responses

	# check if the agent is still running
	if [ -n "${SSH_AGENT_PID-}" ] && ! kill -0 "$SSH_AGENT_PID" >/dev/null 2>&1; then
		SSH_AGENT_PID=''
	fi

	# (re)start the ssh agent if the inherited one crashed
	if [ -z "${SSH_AUTH_SOCK-}" ] || [ -z "${SSH_AGENT_PID-}" ]; then
		eval "$(ssh-agent -s)" >/dev/null 2>&1
	fi

	# shutdown the ssh-agent when our shell exits
	on_ssh_finish() {
		# killall ssh-agent
		eval "$(ssh-agent -k)" >/dev/null 2>&1
	}
	trap on_ssh_finish EXIT
fi
