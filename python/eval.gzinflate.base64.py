#!/usr/bin/env python
import zlib, base64, sys

#
# This script does the equivilant of gzinflate(base64_decode(sys.argv[1])) for php
# ::shudders:: ugh. PHP
#
# Useful for decoding obfuscated PHP script, as most obfuscators are dumb and think that
# doing something like this is enough...
#

try:
    s = sys.argv[1]
except:
    print "Derp, give me some info!"
    sys.exit(1)

left = s.count('(')
right = s.count(')')

if left != right:
    print "Truncated input?"
    sys.exit(1)
elif left > 0:
    print "1"
    print zlib.decompressobj().decompress('x\x9c' + base64.b64decode(s.split('(')[-1].split("'")[1]))
elif left == 0:
    print "0"
    print zlib.decompressobj().decompress('x\x9c' + base64.b64decode(s))
else:
    print "Dunno what to do dude"




