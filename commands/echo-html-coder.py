#!/usr/bin/env python3
import html
import sys

if sys.argv[1] == "decode":
    print(html.unescape(sys.argv[2]))
else:
    print(html.escape(sys.argv[2]))
