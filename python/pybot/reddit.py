#!/usr/bin/env python

from lxml import etree
from urllib2 import urlopen
import sys


def getstuffs(cat):

    f = urlopen('http://reddit.com/r/' + cat + '/new?sort=new').read()
    tree = etree.HTML(f)
    message = []
    try:
        tree.xpath('//div[@class="search-summary"]')[0].attrib
        message.append('Invalid Catagory!')
        return message
    except:
        div = tree.xpath('//div[@onclick="click_thing(this)"]')
        for i in range(3):
            title = tree.xpath('//p[@class="title"]/a')[i].text
            votes = tree.xpath('//div[@class="score unvoted"]')[i].text.encode('ascii','ignore')
            if votes == "":
                votes = "0"
            sub   = tree.xpath('//p[@class="tagline"]/time')[i].text
            text = "(" + votes + ") [" + sub + "] => " + title
            text = text.encode('ascii','ignore') 
            message.append(text)
        return message

if __name__ == "__main__":
    print getstuffs(sys.argv[1])
