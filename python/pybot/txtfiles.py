#!/usr/bin/env python
from lxml import etree
from urllib2 import urlopen
import random

def doit():

    a = urlopen("http://www.textfiles.com/art/ASCIIPR0N/").readlines()

    files = []

    for line in a:
        if '<TR VALIGN' in line and 'hunky' not in line:
            file = line.split('>')[3].split('<')[0]
            size = line.split('>')[6].split('<')[0]
            if int(size) < 4000:
#                print "File => " + file + " Size => " + str(size)
                files.append(file)
    textfile = files[random.randrange(0,len(files))]

    lul = urlopen('http://www.textfiles.com/art/ASCIIPR0N/' + textfile).read().strip()
    return [lul]

if __name__ == "__main__":
    img = doit()
    for line in img:
        print line

