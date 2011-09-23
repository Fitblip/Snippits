#!/usr/bin/env python
# Google searcher. Fucking google and it's case-insensativity :(

#
# This script uses an AJAX call to the google api in order to 
# search for keywords (up to 64 results only :() and display
# links to you. It's useful because you can incorperate this
# in other ways to do things like grab the first 64 .doc files
# google sees, or to search for things with the site: operator!
#

 
import urllib2
import urllib
import json
import sys
from time import sleep
 
res=[]
 
def google_request (page, req):
        url = 'http://ajax.googleapis.com/ajax/services/search/web?'
        params = { 'q': req }
        data = urllib.urlencode(params)
        num = '&start=' + page
        url = url + data + '&rsz=large&v=1.0' + num
        request = urllib2.Request( url,None, {'Referer': 'http://www.packetfault.lab/google' })
        response = urllib2.urlopen(request)
 
        results = json.load(response)
        if len(results['responseData']['results']) != 0:
                for reply in results['responseData']['results']:
                        print reply['unescapedUrl']
                return(results['responseData']['results'])
        else:
                print "No results found"
                exit(1)
try:   
        dork = sys.argv[1]
except:
        sys.exit('Use: python main.py targeturl')
 
for pagenum in range(0, 64, 8):
        page = str(pagenum)
        res = res + google_request(page, dork)
        try:
                if res[0] == res[1]:
                        exit(0)
        except:
                exit(0)
        sleep(1)
