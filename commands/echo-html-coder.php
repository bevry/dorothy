#!/usr/bin/env php
<?php
if ( $argv[1] == "decode" ) {
	printf("%s\n", html_entity_decode($argv[2]));
} else {
	printf("%s\n", htmlentities($argv[2]));
}
