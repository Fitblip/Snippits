#!/usr/bin/env python
from urllib2 import urlopen
from urllib import quote_plus
from lxml import etree
from datetime import datetime

import exceptions

api = "15AD015D11EF5523"

today = datetime.now().strftime('%Y-%m-%d')

def getinfo(show):
    name = quote_plus(show)
    html = urlopen('http://thetvdb.com/api/GetSeries.php?seriesname=' + name + '&lang=en').read()
    tree = etree.HTML(html)
    try: 
        if "400" in tree.xpath('//title')[0].text:
            return "ERROR"        
    except:
        try:
            showid = tree.xpath('//seriesid')[0].text
            html = ""
            return [epinfo(showid)]
        except:
            return "NOTFOUND"

def epinfo(showid):
    datenum = datetime.now().strftime('%Y%m%d')
    html = urlopen('http://thetvdb.com/api/' + api + '/series/' + showid + '/all/en.xml').read()
    tree = etree.HTML(html)
    #print tree.xpath('//firstaired')[-1].text.replace('-','')
    #print datetime.now().strftime('%Y%m%d')
    if tree.xpath('//firstaired')[-1].text.replace('-','') < datetime.now().strftime('%Y%m%d'):
        return "NONEWEP"
    for i in range(len(tree.xpath('//firstaired'))):
        date = tree.xpath('//firstaired')[i].text.replace('-','')
        if date > datetime.now().strftime('%Y%m%d'):
            x = i - 1
            season = tree.xpath('//seasonnumber')[x].text
            episode = tree.xpath('//episodenumber')[x].text
            title  = tree.xpath('//episodename')[x].text
            airdate = tree.xpath('//firstaired')[(x+1)].text
            time    = tree.xpath('//airs_time')[0].text
            #print time
            #print episode
            return "S%02dE%02d - %s [%s @ %s]" % (int(season), int(episode), title, airdate, time)

if __name__ == "__main__":
    import sys
    print getinfo(sys.argv[1])
