#!/usr/bin/env python

from lxml import etree
from urllib2 import urlopen

def gettitles(count):
    h = urlopen('http://www.reddit.com/r/netsec/new/?sort=new').read()
    titles = []
    tree = etree.HTML(h)
    p = tree.xpath('//div[@onclick="click_thing(this)"]/div[@class="entry unvoted"]/p[@class="title"]')   
    votes = tree.xpath('//div[@onclick="click_thing(this)"]/div[@class="midcol unvoted"]/div[@class="score unvoted"]')
    
    for i in range(count):
        title = p[i].find('a').text
        vote = votes[i].text.encode('ascii','ignore')
        if len(vote) == 0:
            vote = "0"
        text = "(" + vote + ") => " + title
        titles.append(text)
    return titles
    	
if __name__ == "__main__":
    print gettitles(3)

