#!/usr/bin/env bash

# nofap yes/no/maybe 'hosts file' 'value'
function nofap() {
	# assume config.sh has already been loaded
	load_dorothy_config 'nofap.bash'
	if test -n "${NOFAP_DISCORD_WEBHOOK-}"; then
		# prepare
		local user nofap their thing new socials terminal
		user="${NOFAP_DISCORD_USERNAME:-"<@$(whoami)>"}"
		nofap="$1"
		their="$(get-profile possessive-pronoun)"
		thing="$2"
		new="$3"

		# prepare message for socials and terminal
		if test "$nofap" = "yes"; then
			socials="$user changed $their $thing to $new which is NoFap compliant ✅"
			terminal="$(echo-style --green="$socials")"
		elif test "$nofap" = "no"; then
			socials="$user changed $their $thing to $new which VIOLATES NoFap ❌"
			terminal="$(echo-style --red="$socials")"
		else
			socials="$user changed $their $thing to $new which NoFap compliance is UNKNOWN"
			terminal="$(echo-style --yellow="$socials")"
		fi

		# let discord know
		env QUIET=yes setup-util-httpie
		http -q --check-status \
			"$NOFAP_DISCORD_WEBHOOK" \
			Authorization:"${NOFAP_DISCORD_WEBHOOK_AUTH-}" \
			content="$socials"

		# let the terminal know
		echo-style \
			--bold="NoFap update sent to your socials:" $'\n' \
			"$terminal"
	fi
}
