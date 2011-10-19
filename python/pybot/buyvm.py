#!/usr/bin/env python

from urllib2 import urlopen
from lxml import etree
import md5

def getinfo():
    h = urlopen('http://doesbuyvmhavestock.com/automation.xml').read()
    tree = etree.HTML(h)
    msg = []
    for i in range(len(tree.xpath('//qty'))):
        if tree.xpath('//qty')[i].text != "0":
            name = tree.xpath('//name')[i].text
            pid = tree.xpath('//pid')[i].text
            qty = tree.xpath('//qty')[i].text
            msg.append('[' + qty + '] ' +  name + ' => https://my.frantech.ca/cart.php?a=add&pid=' + pid)
    return msg

if __name__ == "__main__":
    print getinfo()
    
