#!/usr/bin/env python

from urllib2 import urlopen
from lxml import etree
import sys



def getstuffs(count):
    a = urlopen('http://dev.metasploit.com/redmine/projects/framework/repository/revisions').read()
    tree = etree.HTML(a)
    todaydate = tree.xpath('//tbody/tr')[0].getchildren()[3].text.split()[0]
    day = int(todaydate[3:5])
    tr = tree.xpath('//tbody/tr')
    message = []
    for i in range(len(tr)):
        revision = tr[i].getchildren()[0].find('a').text
        time     = tr[i].getchildren()[3].text[11:]
        date     = tr[i].getchildren()[3].text[:10]
        author   = tr[i].getchildren()[4].text
        comment  = tr[i].getchildren()[5].getchildren()[0].text

        for c in range(count):
            if int(date[3:5]) == day - c:
		message.append("[#" + revision + "] [" + date +" @ " + time + "] {" + author + "} => " + comment)
#                print "[#" + revision + "] [" + date +" @ " + time + "] {" + author + "} => " + comment

    return message
if __name__ == "__main__":
    if  len(sys.argv) < 2:
        for line in getstuffs(1):
            print line
    else:
        for line in getstuffs(int(sys.argv[1]) + 1):
            print line
