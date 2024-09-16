#!/usr/bin/env php
<?php
# space is turned to +, not %20
if ( $argv[1] == "decode" ) {
	printf("%s\n", urldecode($argv[2]));
} else {
	printf("%s\n", urlencode($argv[2]));
}
