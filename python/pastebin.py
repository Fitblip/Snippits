#!/usr/bin/env python

#
# This script takes from stdin and posts to pastebin.
#
# Usage: 
# cat a.sh | ./pastebin bash
#
#
 
import sys
import urllib
import httplib
 
a=""
fmt = sys.argv[1]
 
# Read in stdin line by line
for line in sys.stdin.readlines():
        a += line
 
# URLEncode errrrythang
script = urllib.quote(a)
 
# Put up some content headers
headers = {"Content-type": "application/x-www-form-urlencoded","Accept": "text/plain"}
 
# put together our POST data
data = "paste_code=" + script + "&paste_format=" + fmt + "&paste_expire_date=N&paste_private=1&paste_subdomain=&paste_name=&paste_email=&submit=submit"
 
# Initilize out connection, and post our requets
conn = httplib.HTTPConnection("pastebin.com:80")
conn.request("POST", "/api_public.php", data, headers)
 
# Read and print response
response = conn.getresponse()
print response.read()
