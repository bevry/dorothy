#!/usr/bin/env nu

def secure_history [] {
	history -c
	echo 'Erased everything.'
}
