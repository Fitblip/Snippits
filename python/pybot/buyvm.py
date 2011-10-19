#!/usr/bin/env python

from urllib2 import urlopen
from lxml import etree

def getinfo(which='all'):
    # which needs to be a list of names to match and report.

    if which == 'all':

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
    else:

        h = urlopen('http://doesbuyvmhavestock.com/automation.xml').read()
        tree = etree.HTML(h)
        msg = []
        for name in which:
            for i in range(len(tree.xpath('//qty'))):
                if tree.xpath('//qty')[i].text != "0" and tree.xpath('//name')[i].text == name:
                    name = tree.xpath('//name')[i].text
                    pid = tree.xpath('//pid')[i].text
                    qty = tree.xpath('//qty')[i].text
                    msg.append('[' + qty + '] ' +  name + ' => https://my.frantech.ca/cart.php?a=add&pid=' + pid)
        return msg


def getbaseline():
    print "Getting Baseline"
    d = {}
    h = urlopen('http://doesbuyvmhavestock.com/automation.xml').read()
    tree = etree.HTML(h)
    for i in range(len(tree.xpath('//qty'))):
        d[tree.xpath('//name')[i].text] = tree.xpath('//qty')[i].text
    return d


def checkupdate(d):
    print "Getting Updates"
    new = {}
    ret = []
    h = urlopen('http://doesbuyvmhavestock.com/automation.xml').read()
    tree = etree.HTML(h)
    for i in range(len(tree.xpath('//qty'))):
        new[tree.xpath('//name')[i].text] = tree.xpath('//qty')[i].text
    for key in d:
        if d[key] < new[key]:
            ret.append(key)

    return ret,new
        


if __name__ == "__main__":
#    a = ['OpenVZ-512MB','OpenVZ-256MB']
#    print getinfo(a)
    d = {}
    print checkupdate(getbaseline())
