#!/usr/bin/env python

import sys, re

if len(sys.argv) != 2:
	print "Only supply one file!" 
	exit(1)

reg = re.compile('^(http|https)://[0-9a-zA-Z\-\.]+\.[a-zA-Z]{2,3}/')

mess       = []
urls       = []
fin        = []

f = open(sys.argv[1], "r")

# Set up initial mess array with [['url','parameters'],['url','parameters']]
for line in f.readlines():
	line = line.strip()
	if reg.match(line):
		line = line.split('?')
		mess.append(line)

#print mess
# modify mess array with [[['url'],['param1','parameters']],[[],[]]] and unique urls array
for params in range(len(mess)):
	try:
		mess[params][1] = mess[params][1].split('&')
		for key in range(len(mess[params][1])):
			mess[params][1][key] = mess[params][1][key].split('=')[0]
	except:
		try:
			mess.pop(params)
		except:
			pass

# Set up a unique URL base list
for item in mess[:]:
	urls.append(item[0])
urls = list(set(urls))

#print urls

for i in range(len(urls)):
	a=[]
	for x in range(len(mess)):
		if urls[i] == mess[x][0]:
			try:
				a.append(mess[x][1])
			except:
				pass
	#a = [list(x) for x in set(tuple(x) for x in a)]
	for item in range(len(a)):
		print a
		
#print urls

#for url in range(len(urls)):
#	for i in range(len(mess)):
#		if urls[url] == mess[i][0]:
#			print urls[url]
#	if url in mess[0]:
#	print "URLs : " + str(mess[url][0])
#	urls.append(mess[url])
#	for key in range(len(mess[url][1])):
#		print "Param: " + str(mess[url][1][key][0])

# For each url in our unique url array
#for url in range(len(urls[:])):
#	print url
print "==="	
print fin
print "==="	
print "\n"
#print mess
#print urls
print "\nNumber of URLs: " + str(len(mess))
