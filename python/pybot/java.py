#!/usr/bin/env python

from lxml import etree
from urllib2 import urlopen

def getbugs(count):

	h = urlopen('https://bugzilla.redhat.com/buglist.cgi?bug_status=NEW&bug_status=ASSIGNED&field0-0-0=assigned_to&query_format=advanced&short_desc=jdk&short_desc_type=anywordssubstr&type0-0-0=substring&value0-0-0=Security&order=bug_id%20DESC&query_based_on=').read()
	
	bugs = []
	for i in range(count):
		a = etree.HTML(h)
		tr = a.xpath('//div[@id="bugzilla-body"]/table[@class="bz_buglist"]/tr')[i]
		
		bugid  = tr.getchildren()[0].find('a').text
		sev    = tr.getchildren()[2].text.strip()
		status = tr.getchildren()[5].text.strip()
		issue  = tr.getchildren()[7].text.strip()
		
		text = "(" + bugid + ") [" + sev + "] {" + status + "} => " + issue 
		bugs.append(text)

	return bugs
		
	

if __name__ == "__main__":
	print getbugs(3)	

