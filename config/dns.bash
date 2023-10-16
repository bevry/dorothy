#!/usr/bin/env bash
# do not use `export` keyword in this file:
# shellcheck disable=SC2034

# Used by `select-dns` and `setup-dns`
# Which can configure these with the `--configure` flag.

# Which DNS service to use to communicate with your DNS provider?
# 'system'       # system's internal dns service
# 'aghome'       # adguard-home
# 'cloudflared'  # cloudflared proxy-dns
# 'dnscrypt'     # dnscrypt-proxy
#
# DNS_SERVICE=''

# Your primary DNS provider, can be any of these:
# 'env'
# 'quad9'
# 'adguard'
# 'adguard-family'
# 'cloudflare'
# 'cloudflare-malware'
# 'cloudflare-family'
# 'cloudflare-teams'
# 'google'
# 'opendns'
#
# DNS_PROVIDER=''

# Your backup DNS provider, can be any of these:
# 'quad9'
# 'adguard'
# 'adguard-family'
# 'cloudflare'
# 'cloudflare-malware'
# 'cloudflare-family'
# 'cloudflare-teams'
# 'google'
# 'opendns'
#
# DNS_BACKUP_PROVIDER=''

# If using DNS_PROVIDER=env, set these to your desired servers
# DNS_IPV4_SERVERS=()
# DNS_IPV6_SERVERS=()
# DNS_DOH_SERVERS=()
# DNS_DOT_SERVERS=()
# DNS_QUIC_SERVERS=()
# DNS_SDNS_SERVERS=()
# DNS_DNSCRYPT_NAMES=()

# If you wish to use Cloudflared tunnels, set this accordingly:
# CLOUDFLARED_TUNNELS=(
# 	--tunnel="$name" --hostname="$name.example.com" --url='ssh://localhost:22'
# )
