#!/usr/bin/env python3
import sys
import urllib.parse

if sys.argv[1] == "decode":
    print(urllib.parse.unquote(sys.argv[2]))
else:
    print(urllib.parse.quote(sys.argv[2]).replace("%3A", ":"))
