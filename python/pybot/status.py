#!/usr/bin/env python

from lxml import etree
from urllib import urlopen

def getstatus(count): 
    f = urlopen("https://status.it.mtu.edu/").read()
    tree = etree.HTML(f)
    
    messages = []
    
    for i in range(3):
        # Get each of the top (or however many) alerts.
        stuffs = tree.xpath("//div[@class='notice']")[i].getchildren()[0]

        # Parse out color in HTML hex, and translate to something readable
        colorhex = stuffs.getchildren()[0].attrib.values()[0].split('#')[1]
        if colorhex == "78e366;":
            color = "GREEN "
        elif colorhex == "fff392;":
            color = "YELLOW"
        elif colorhex == "f8b258;":
            color = "ORANGE"
        elif colorhex == "e84e4e;":
            color = "*RED* "

        # Parse out our title
        title = stuffs.getchildren()[0].getchildren()[0].text.encode('ascii','ignore').strip()
		
        # Gimme mah ticket
        ticket = tree.xpath("//div[@class='notice']/div[@class='shadow']/h2/a")[i].get('href').split('=')[1]

        # Parse out our status
        status = stuffs.getchildren()[4].getchildren()[1].text
		
        # Print stuffs
        messages.append(color + " [" + ticket + "] => " + title + " => (Status: " + status + ")")
    return messages

def getticket(ticket):
    message = []
    f = urlopen("https://status.it.mtu.edu/").read()
    tree = etree.HTML(f)
    a = []
    for i in range(10):
        a.append(tree.xpath("//div[@class='notice']/div[@class='shadow']/h2/a")[i].get('href').split('=')[1])
    a.sort()
    if ticket > a[-1]:
        message.append('Ticket not found!')
        return message
        exit(0)

    a = tree.xpath("//div[@class='notice']/div[@class='shadow']/h2/a")
	
    for i in range(len(a)):
        if a[i].get('href').split('=')[1] == ticket:
            message.append(tree.xpath("//div[@class='notice']/div[@class='shadow']/p[@class='maintext']")[i].text)
            for x in range(len(tree.xpath("//div[@class='notice'][" + str(i+1) + "]/div[@class='shadow']")[0].getchildren())):
                try:
                    message.append(tree.xpath("//div[@class='notice'][" + str(i+1) + "]/div[@class='shadow']")[0].getchildren()[x+5].text)
                except:
                    pass
    if None in message:
        message.remove(None)
    return message[1:]

if __name__ == "__main__":
#	print getstatus(3)
    print getticket("1500")
