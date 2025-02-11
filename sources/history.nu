#!/usr/bin/env nu

def secure_history [] {
	history -c
	printf '%s\n' 'Erased everything.'
}
