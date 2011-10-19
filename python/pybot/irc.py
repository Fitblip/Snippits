#!/usr/bin/env python

import irclib, urllib, time, status, java, netsec, signal, sys, drunk, metasploit, reddit, tvdb, sleepy, buyvm, txtfiles, thread, md5


network = '66.225.195.39'
port = 9999
channel1 = '#main'
channel2 = '#whyte'
nick = 'Zer0-Bot'
name = 'Zer0 Bot'

#a = txtfiles.doit()
#for line in a:
#    print line
#exit(0)

class ClientClass ( irclib.SimpleIRCClient ):

#       def on_join   (self, connection, event):
#               channel = event.target()
#               time.sleep(2)
#               connection.privmsg(channel,"OOOH snap. It's the Zer0-Bot in the house! (try !status, !help, or !javabugs)")

    def on_pubmsg (self, connection, event):
        channel = event.target()
        dude    = event.source().split('!')[0]
        msg     = event.arguments()[0]

#        if msg == '!ascii':
#            for line in txtfiles.doit():
#                print line
#                connection.privmsg("Zer01-Roaming",line.strip('\n'))
#            a = txtfiles.doit()
#            print a
#            connection.privmsg(channel,a)
#           for line in a:
#                connection.privmsg(channel,line)
#            connection.privmsg(channel,txtfile)
        if msg == '!buyvm':
            messages = buyvm.getinfo()
            for line in messages:
                connection.privmsg(channel,line)
        if msg == '!sleepytime':
            messages = sleepy.wakeup()
            text = "Hey " + dude + ", you should wake up at " +  messages[0] + " if you go to sleep right now"
            connection.privmsg(channel,text)

        if msg == '!status':
            messages = status.getstatus(3)
            for line in messages:
                connection.privmsg(channel,line)

        if '!status-ticket' in msg:
            messages = status.getticket(msg.split(' ')[1])
            for line in messages:
                if line != None:
                    connection.privmsg(channel,line)

        if '!tv' in msg:
            show = "".join(str(i + " ") for i in msg.split(' ')[1:])
            message = tvdb.getinfo(show)
            if message[0] == "ERROR":
                text = "Doh! There was an error, maybe thetvdb is down?"
                connection.privmsg(channel,text)
            elif message == "NOTFOUND":
                text = "Sorry " +dude + ", TV show not found!"
                connection.privmsg(channel,text)
            elif message[0] == "NONEWEP":
                text = "Sorry " + dude + ", no new episodes :(."
                connection.privmsg(channel,text)
            else:
                for line in message:
                    connection.privmsg(channel,line)

        if '!reddit' in msg:
            try:
                cat = msg.split(' ')[1]
                message = reddit.getstuffs(cat)
                for line in message:
                    connection.privmsg(channel,line)
            except:
                message = dude + ', gimme a catagory!'
                connection.privmsg(channel,message)

        if '!metasploit' in msg:
            try:
                day = int(msg.split(' ')[1]) + 1
            except:
                day = 1
            message = metasploit.getstuffs(day)
            for line in message:
                connection.privmsg(channel,line)

        if msg == '!javabugs':
            messages = java.getbugs(3)
            for line in messages:
                connection.privmsg(channel,line)

        if msg == '!drunk':
            stat = drunk.isdrunk()
            if stat == True:
                connection.privmsg(channel,"Why yes, Ryan IS drunk!")
            if stat == False:
                connection.privmsg(channel,"Nope :(, Ryan isn't drunk...yet")

        if msg == '!netsec':
            messages = netsec.gettitles(3)
            for line in messages:
                connection.privmsg(channel,line)

        if msg == '!help':
            text = "Heyo " + dude + "! Try !drunk, !status, !status-ticket <ticket>, !javabugs, !netsec, !reddit <cat>, !metasploit <days>, !tv <show>, !buyvm, !ascii, or !sleepytime :-D"
            connection.privmsg(channel,text)
#       def on_privmsg ( self, connection, event ):
#               connection.


# TODO Fix this shit to just be a caller/callee relationship
# Also, holy hackjob batman!
def buyvmstuffs(oldmd5,delay):
    newtime = time.time() + delay
    print newtime
    while(1):
        irc.start()
        if time.time() >= newtime:
            h = urllib.urlopen('http://doesbuyvmhavestock.com/automation.xml').read()
            newmd5 = md5.new(h).hexdigest()

            if oldmd5 == "":
                print "New run!"
#                irc.connection.privmsg('#testing','First run!')
#                irc.connection.privmsg('#testing','MD5 : ' + newmd5)
                print "MD5 : " + newmd5
                oldmd5 = newmd5
            if oldmd5 != newmd5:
                #irc.connection.privmsg('#testing','MD5 changed! Old MD5 : ' + oldmd5 + '. New MD5 : ' + newmd5)
                irc.connection.privmsg('#main','New BuyVM stuffs! ZOMG!!!')
                for msg in buyvm.getinfo():
                    irc.connection.privmsg('#main',msg)
                #irc.ion.privmsg('#whyte','New BuyVM! Run !buyvm!!!')
                oldmd5 = newmd5
            else:
                print "No MD5 change!"
#                irc.connection.privmsg('#testing','No MD5 change. Old MD5 : ' + oldmd5 + '. New MD5 : ' + newmd5)

            newtime = time.time() + delay

#        irc.ircobj.execute_delayed(10,buyvmstuffs(oldmd5))

if __name__=="__main__":
    oldmd5 = ""
    delay = 900
    irc = ClientClass()
    irc.connect(network, port, nick, ircname = name, ssl = True)
    irc.connection.join(channel1)
    irc.connection.join(channel2)
    irc.ircobj.execute_delayed(0,buyvmstuffs(oldmd5,delay))
