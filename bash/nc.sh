#!/bin/bash
 
## TODO shell shoveling 

#
# This script takes the hassle out of setting up netcat relays (for fun and profit!)
#
 
function print_usage {
cat <<EOF | less
###############################
# Netcat relay generator v1.0 #
#         Ryan Sears          #
###############################
 
usage: $0 [options]
 
OPTIONS:
   -h             Print this [-h]elp page
   -s [HOST]      [-s]can a host for open ports
   -l             Client => [-l]istener relay
   -c             [-c]lient => client relay
   -p             Transparent [-p]roxy 
 
** Please note ** 
 Reserved ports require ROOT ACCESS. You can't start a listener on ports 1-1024 without it!
 
Netcat is one of my favorite tools in the entire IT world. It can literally be used to do anything, and 
I regularly use it to shovel files quickly over the network, grab configuration files, and network pivoting.
One of the best things is it utilizes the TCP protocal, so it inherits it's error-checking, so it's stable
enough for imaging if you're in a pinch with no software and nothing but dd and netcat!
 
Encoding Types:
     n => No output whatsoever, can be backgrounded with CTRL+Z (use 'fg' to return and kill)
     u => Output the data in pure ASCII, can be reversed with uudecode
     s => Print out a tuned set of strings (to reduce junk) 
     d => Re-directs output to your sound processing subsystem, so you can hear your traffic!
     f => Outputs to a file in the /tmp/ dir, named \$EPOCH.nc-relay. With some cleverness
          you can also replay these into a packet sniffer like wireshark. 
 
Mode Types:
 
1.) Client <=> Listener relay (-c)
    This command sets up a basic client > listener relay, which is 
    paticularly useful for pivoting around networks. It has many 
    applications though, and is nothing more than a building block.
  
    In this (very simple) example, you can see a client making a connection
    to the listening netcat relay (this machine) and having it's request 
    forwarded to www.google.com. There are many obvious implications to this
    and I've used it for everything from shoveling out an internal website to
    bouncing calls around a network. 
 
                         
     +--------+                     +-------------------------+                           +------------+
     | Client |  ═> TCP Connection  | Listener (This machine) | ═> Fowarded connection ═> | Google.com |═══╗
     +--------+       Port 4444     +-------------------------+       google.com:80       +------------+   ║
          ║  <═           <═          <═    ║ Processed ║          <═           <═          <═             ║
          ╚═════════════════════════════════╝           ╚══════════════════════════════════════════════════╝
            And re-directed to the client!                   Web page is returned through the same pipe
                         
 
2.) Client <=> Client relay (-c) 
    This relay is less useful then the traditional listner => client relay, but 
    under the right circumstances this works miracles. Imagine you had the ability
    to run shell commands on a DMZ, but you don't have root. Now you've also managed
    a listening shell somewhere on the internal network listening on port 4444. How do you
    get there? With a listener => listener relay of course! You essentially force a reverse
    connection, even though all parties think they're making inbound connections :)
 
 
                                                                            
                                          ╔════════════════════════════════════════╗  
                          ║                                        ║  
     +------------+                    +-----+                     +------------+  ║  
     | Listener 1 | <= NC Connection = | DMZ | = NC Connection => | Listener 2 |   ║  
     +------------+                    +-----+                     +------------+  ║  
    IP : 72.37.48.99                      ║                         IP 10.0.0.3    ║  
    Listening *:4444                      ║                       Listening *:4444 ║  
                                          ╚════════════════════════════════════════╝  
                                                        Private Network               
                                                                                        
                                  
 
    This command needs to be run on the DMZ. What it does it literally reach out to each of 
    these listeners, and do the equivilant of a rollover cable to them 
        ( input 1 > output 2 ; input 2 > output 1 )
 
    There's a LOT more you can do with this, but this is just an example I could think of. 
 
3.) Listener <=> Listener <=> Client <=> Client <=> Client relay. No seriously. (-w)
 
    Basically we're going to be making a HUGE transparent proxy straight to our target, using nothing
    but netcat relays. This gets rid of the problem of using all our standardized tools ( psexec, wmic,
    smbclient, you name it ). 
 
    Ready? Good.
 
    For this we need an extra tower (or a virtual machine if you're clever), but our set-up looks 
    something like this:
 
    +----+
    | Us |═╗ ( Samba connection to 
    +----+ ║ <==  Linux box on 445 )
        ___║__             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
       |L*:445|---┐   ←  ← ┃  ←  ←  ←  +---------------+  →  →  →          ( Our shell account fetches the         ┃
    +-----------+ | ╔═══════════════╦══| Shell account |══╦══════════╗ ↑       SMB data for us, and negotiates     ┃
    | Extra box | | ║      ┃        ║  +---------------+  ║          ║    <==   our end of the connection on our   ┃
    |  (Linux)  | | ║      ┃        ╚═════════════════════╝          ║ ↑       behalf )                            ┃
    +-----------+ | ║      ┃        Client to client relay         __║___                                          ┃
      |L*:4444|---┘ ║      ┃       (transparent connection)       |L*:445|                                         ┃
       ‾‾‾║‾‾‾      ║ ↑    ┃                                 +----------------------+                              ┃
          ╚═════════╝      ┃                                 | Exploi...er "usable" |                              ┃
            →    →         ┃                                 |         Box          |                              ┃
     ( Our SMB Request is  ┃                                 +----------------------+                              ┃
       passed over reverse ┃                                                                                       ┃
       connection )        ┃                                                                                       ┃
                           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                                Private Network
 
 
    Hopefully this makes sense, after all it IS 4:45 in the morning :-P. Either way this entire process can be broken down
    into a number of steps:
 
    1.) The first thing we do is set up our listener > listener relay on our linux box
    2.) Then we set up our client > client relay, connecting back to our listener linux box
    3.) Now we make our samba request to our linux box, which gets connected to the incoming client connection
    4.) Our shell account passes our info to the windows box on our behalf, and recieves everything, and throws it back
    5.) Now we can interact with our linux box, and everything we do will be fowarded to our windows box!
 
    When this mode is invoked, it asks you to specify if you're setting up the listener or the client bridge, and will
    have you fill in the details accordingly. 
 
 
EOF
}
 
function scan_target {
    echo -ne "${green}Port Range? (e.g. 1-1024) : ${reset}"
            read Portrange
    echo "Scanning $1:$Portrange"
    echo "To run this scan again just run nc -z -v \"$1\" \"$Portrange\" 2>&1 | grep \"succeeded\" | awk '{print \$5,\$4,"Open!",\$6}'"
    nc -z -v "$1" "$Portrange" 2>&1 | grep succeeded\! | awk '{print $5,$4,"Open!",$6}' >/tmp/scanresults &
    p=$!
 
    setterm -cursor off
        while [ -d /proc/$p ]; do
                        echo -ne "-\b" ; sleep .01
                        echo -ne "/\b" ; sleep .01
                        echo -ne "|\b" ; sleep .01
                        echo -ne "\\"  ; echo -ne "\b"  ; sleep .01
            echo -ne "."
        done
 
echo -e "\n"
cat /tmp/scanresults
rm -rf /tmp/scanresults
setterm -cursor on
    exit 0
}
 
function client_listener_relay {
echo -ne "${green}Local port to listen on? : ${reset}"
    read LocalPort
echo -ne "${green}  Host to connect to?    : ${reset}"
        read RemoteHost
echo -ne "${green}     Remote port?        : ${reset}"
    read RemotePort
echo -ne "${green}Output? (n=none, u=uuencode, s=stings, d=DSP, f=file)? : ${reset}"
    read Encoding
 
if [ ! -p $fifopath ]; then
    echo -ne "${blue}Creating FIFO Pipe...${reset}"
    mkfifo $fifopath
    if [ $? != 0 ]; then
        echo -e "${red}ERROR: Can't create FIFO, do you have permission for this directory?${reset}"
        exit 1
    fi
    echo -e "${green}Done"
fi
 
if [ $Encoding == "n" ]; then
    echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
    echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort >$fifopath;rm /tmp/p${blue}\"${red}"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort >$fifopath 
elif [ $Encoding == "u" ]; then
        echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath | uudecode -m -;rm /tmp/p${blue}\"${red}"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath | uuencode -m -
elif [ $Encoding == "d" ]; then
        echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath >/dev/dsp;rm /tmp/p${blue}\"${red}"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath >/dev/dsp
elif [ $Encoding == "f" ]; then
        echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath >>/tmp\`date+%s\`.nc-relay;rm /tmp/p${blue}\"${red}"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath >>/tmp/`date +%s`.nc-relay
elif [ $Encoding == "s" ]; then
        echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath | strings -n 6;rm /tmp/p${blue}\"${red}"
    echo -e "\n============Start String Dump============\n"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath | strings -n 6
else
    echo "Sry dudez, you gotta put in the right encoding! (only n,u,s,d,f. I'll fix it later)"
    exit 1
fi
 
rm -f $fifopath
killall nc 2> /dev/null
}
 
function client_client_relay {
echo -ne "${green}*NOTE* You need to have listeners bound on both clients before you can make the connection between them. [duh]\n"
echo -ne "\tYou should use ${blue}nc -nvl [PORT]${green} to set up your listening hosts\n\n"
echo -ne "${green}Specify hosts in the ip:port convention (e.g. 10.0.0.1:4444)\n"
echo -ne "${green}Host 1 : ${reset}"
        read Host1
echo -ne "${green}Host 2 : ${reset}"
        read Host2
echo -ne "${green}Output? (n=none, u=uuencode, s=stings, d=DSP, f=file)? : ${reset}"
        read Encoding
 
Host1Port=`echo $Host1 | cut -d ':' -f2`
Host1Host=`echo $Host1 | cut -d ':' -f1`
Host2Port=`echo $Host2 | cut -d ':' -f2`
Host2Host=`echo $Host2 | cut -d ':' -f1`
 
if [ ! -p $fifopath ]; then
        echo -ne "${blue}Creating FIFO Pipe...${reset}"
        mkfifo $fifopath
        if [ $? != 0 ]; then
                echo -e "${red}ERROR: Can't create FIFO, do you have permission for this directory?${reset}"
                exit 1
        fi
        echo -e "${green}Done"
fi
 
if [ $Encoding == "n" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"          
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port 1>$fifopath;rm /tmp/p${blue}\"${red}"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port 1>$fifopath
elif [ $Encoding == "u" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath | uudecode -m -;rm /tmp/p${blue}\"${red}"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath | uuencode -m -
elif [ $Encoding == "d" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath >/dev/dsp;rm /tmp/p${blue}\"${red}"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath >/dev/dsp
elif [ $Encoding == "f" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath >>/tmp\`date+%s\`.nc-relay;rm /tmp/p${blue}\"${red}"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath >>/tmp/`date +%s`.nc-relay
elif [ $Encoding == "s" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath | strings -n 6;rm /tmp/p${blue}\"${red}"
        echo -e "\n============Start String Dump============\n"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath | strings -n 6
else
        echo "Sry dudez, you gotta put in the right encoding! (only n,u,s,d,f. I'll fix it later)"
        exit 1
fi
 
rm -f $fifopath
killall nc 2> /dev/null
}
 
function trans_proxy {
echo -e "${red}
    +----+
    | Us |═╗                       
    +----+ ║                        
        ___║__             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ${green}(A)${red}  |L*:445|---┐   ←  ← ┃  ←  ←  ←  +---------------+  →  →  →                                            ┃
    +-----------+ | ╔═══════════════╦══| Shell account |══╦══════════╗ ↑                                     ┃
    | Extra box | | ║      ┃        ║  +---------------+  ║          ║                                       ┃
${green}(#1)${red}|  (Linux)  | | ║      ┃        ╚═════════════════════╝          ║ ↑                                     ┃
    +-----------+ | ║      ┃        Client to client relay         __║___                                    ┃
  ${green}(B)${red} |L*:4444|---┘ ║      ┃       (transparent connection)       |L*:445| ${green}(A)${red}                               ┃
       ‾‾‾║‾‾‾      ║ ↑    ┃                ${green}(#2)${red}             +----------------------+                        ┃
          ╚═════════╝      ┃                                 | Exploi...er "usable"   |                        ┃
            →    →         ┃                                 |         Box          |                        ┃
                           ┃                                 +----------------------+                        ┃
                           ┃                                           ${green}(#3)${red}                                  ┃
                           ┃                                                                                 ┃
                           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                                                                Private Network
 
See the help doc ([-h]) for more info"
echo -e "${blue}
 1. ) Extra box
 2. ) Shell Account"
echo -ne "${green}So first thing's first - which host is this? : "
read Response
echo $Response | egrep '(1|2)' >/dev/null; 
 
if [ $? != "0" ]; then
    echo -e "${red}Invalid response"
    clean_up
    exit 1  
fi
 
if [ $Response == "1" ]; then
    echo -ne "${green}What is the endpoint port (A)? : "
    read EndPort
 
    if [[ "$EndPort" -lt 1 || "$EndPort" -gt 65535 ]]; then
        echo -e "${red}Invalid port! Try again."
        clean_up
        exit 1
    fi
     
    echo -ne "${green}What port do you want to listen on (B)? : "
    read ListenPort
     
    if [[ "$ListenPort" -lt 1 || "$ListenPort" -gt 65535 ]]; then
            echo -e "${red}Invalid port! Try again."
            clean_up
            exit 1
    fi
 
    echo -ne "${green}Output? (n=none, u=uuencode, s=stings, d=DSP, f=file)? : ${reset}"
            read Encoding
 
 
    if [ ! -p $fifopath ]; then
            echo -ne "${blue}Creating FIFO Pipe...${reset}"
            mkfifo $fifopath
            if [ $? != 0 ]; then
                    echo -e "${red}ERROR: Can't create FIFO, do you have permission for this directory?${reset}"
                    exit 1
            fi
            echo -e "${green}Done"
    fi
     
    if [ $Encoding == "n" ]; then
            echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"          
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  >$fifopath;rm /tmp/p${blue}\"${red}"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  >$fifopath
    elif [ $Encoding == "u" ]; then
            echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath | uudecode -m -;rm /tmp/p${blue}\"${red}"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath | uuencode -m -
    elif [ $Encoding == "d" ]; then
        echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath >/dev/dsp;rm /tmp/p${blue}\"${red}"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath >/dev/dsp
    elif [ $Encoding == "f" ]; then
            echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath >>/tmp\`date+%s\`.nc-relay;rm /tmp/p${blue}\"${red}"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath >>/tmp/`date +%s`.nc-relay
    elif [ $Encoding == "s" ]; then
            echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath | strings -n 6;rm /tmp/p${blue}\"${red}"
            echo -e "\n============Start String Dump============\n"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath | strings -n 6
    else
            echo "Sry dudez, you gotta put in the right encoding! (only n,u,s,d,f. I'll fix it later)"
            exit 1
    fi
 
    rm -f $fifopath
    killall nc 2> /dev/null
    exit 0
 
elif [ $Response == "2" ]; then
    echo -ne "${green}What is your first host/port [B]? (e.g. 34.125.22.83:4444) : ${reset}"
        read Host1
    echo -ne "${green}What is your second host/port [A]? (e.g. 10.0.0.3:445) : ${reset}"
            read Host2
    echo -ne "${green}Output? (n=none, u=uuencode, s=stings, d=DSP, f=file)? : ${reset}"
            read Encoding
 
    Host1Port=`echo $Host1 | cut -d ':' -f2`
    Host1Host=`echo $Host1 | cut -d ':' -f1`
    Host2Port=`echo $Host2 | cut -d ':' -f2`
    Host2Host=`echo $Host2 | cut -d ':' -f1`
 
        if [ ! -p $fifopath ]; then
                echo -ne "${blue}Creating FIFO Pipe...${reset}"
                mkfifo $fifopath
                if [ $? != 0 ]; then
                        echo -e "${red}ERROR: Can't create FIFO, do you have permission for this directory?${reset}"
                        exit 1
                fi
                echo -e "${green}Done"
        fi
 
 
        if [ $Encoding == "n" ]; then
                echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"          
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  >$fifopath;rm /tmp/p${blue}\"${red}"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  >$fifopath
        elif [ $Encoding == "u" ]; then
                echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath | uudecode -m -;rm /tmp/p${blue}\"${red}"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath | uuencode -m -
        elif [ $Encoding == "d" ]; then
        echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath >/dev/dsp;rm /tmp/p${blue}\"${red}"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath >/dev/dsp
        elif [ $Encoding == "f" ]; then
                echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath >>/tmp\`date+%s\`.nc-relay;rm /tmp/p${blue}\"${red}"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath >>/tmp/`date +%s`.nc-relay
        elif [ $Encoding == "s" ]; then
                echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath | strings -n 6;rm /tmp/p${blue}\"${red}"
                echo -e "\n============Start String Dump============\n"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath | strings -n 6
        else  
                echo "Sry dudez, you gotta put in the right encoding! (only n,u,s,d,f. I'll fix it later)"
                exit 1
        fi
 
        rm -f $fifopath
        killall nc 2> /dev/null
        exit 0
 
fi
 
exit 0
}
 
function clean_up {
 
echo -ne "\n\n${red}Exit request detected, cleaning up..."
 
rm -f $fifopath >/dev/null
killall nc 2>/dev/null
echo -ne "${green}Done${reset}\n"
rm -rf /tmp/scanresults 2>&1 >/dev/null
setterm -cursor on
exit 0
 
}
 
fifopath="/tmp/p"
blue="\e[1;34m"
white="\e[1;37m"
red="\e[1;31m"
red_ul="\e[31;4m"
cyan="\e[1;36m"
yellow="\e[1;33m"
green="\e[1;32m"
reset="\e[33;0m"
 
 
trap clean_up SIGINT SIGTERM
 
while getopts “hs:lcp” flag
do
    case $flag in
 
    h)
        print_usage
        exit 0
        ;;
    s)
        scan_target "$OPTARG"
        ;; 
    l)
        client_listener_relay
        ;; 
    c)
        client_client_relay
        ;; 
    p)
        trans_proxy
        ;; 
    ?)
        print_usage
        exit 1
        ;;
    esac
done
 
if [ "$1" == "" ]; then
 
echo "
usage: $0 [options]
 
OPTIONS:
   -h             Print [-h]elp page
   -s [HOST]      [-s]can a host for open ports
   -l             Client => [-l]istener relay
   -c             [-c]lient => client relay
   -p             Transparent [-p]roxy 
"
 
fi#!/bin/bash
 
## TODO shell shoveling 
 
function print_usage {
cat <<EOF | less
###############################
# Netcat relay generator v1.0 #
#         Ryan Sears          #
###############################
 
usage: $0 [options]
 
OPTIONS:
   -h             Print this [-h]elp page
   -s [HOST]      [-s]can a host for open ports
   -l             Client => [-l]istener relay
   -c             [-c]lient => client relay
   -p             Transparent [-p]roxy 
 
** Please note ** 
 Reserved ports require ROOT ACCESS. You can't start a listener on ports 1-1024 without it!
 
Netcat is one of my favorite tools in the entire IT world. It can literally be used to do anything, and 
I regularly use it to shovel files quickly over the network, grab configuration files, and network pivoting.
One of the best things is it utilizes the TCP protocal, so it inherits it's error-checking, so it's stable
enough for imaging if you're in a pinch with no software and nothing but dd and netcat!
 
Encoding Types:
     n => No output whatsoever, can be backgrounded with CTRL+Z (use 'fg' to return and kill)
     u => Output the data in pure ASCII, can be reversed with uudecode
     s => Print out a tuned set of strings (to reduce junk) 
     d => Re-directs output to your sound processing subsystem, so you can hear your traffic!
     f => Outputs to a file in the /tmp/ dir, named \$EPOCH.nc-relay. With some cleverness
          you can also replay these into a packet sniffer like wireshark. 
 
Mode Types:
 
1.) Client <=> Listener relay (-c)
    This command sets up a basic client > listener relay, which is 
    paticularly useful for pivoting around networks. It has many 
    applications though, and is nothing more than a building block.
  
    In this (very simple) example, you can see a client making a connection
    to the listening netcat relay (this machine) and having it's request 
    forwarded to www.google.com. There are many obvious implications to this
    and I've used it for everything from shoveling out an internal website to
    bouncing calls around a network. 
 
                         
     +--------+                     +-------------------------+                           +------------+
     | Client |  ═> TCP Connection  | Listener (This machine) | ═> Fowarded connection ═> | Google.com |═══╗
     +--------+       Port 4444     +-------------------------+       google.com:80       +------------+   ║
          ║  <═           <═          <═    ║ Processed ║          <═           <═          <═             ║
          ╚═════════════════════════════════╝           ╚══════════════════════════════════════════════════╝
            And re-directed to the client!                   Web page is returned through the same pipe
                         
 
2.) Client <=> Client relay (-c) 
    This relay is less useful then the traditional listner => client relay, but 
    under the right circumstances this works miracles. Imagine you had the ability
    to run shell commands on a DMZ, but you don't have root. Now you've also managed
    a listening shell somewhere on the internal network listening on port 4444. How do you
    get there? With a listener => listener relay of course! You essentially force a reverse
    connection, even though all parties think they're making inbound connections :)
 
 
                                                                            
                                          ╔════════════════════════════════════════╗  
                          ║                                        ║  
     +------------+                    +-----+                     +------------+  ║  
     | Listener 1 | <= NC Connection = | DMZ | = NC Connection => | Listener 2 |   ║  
     +------------+                    +-----+                     +------------+  ║  
    IP : 72.37.48.99                      ║                         IP 10.0.0.3    ║  
    Listening *:4444                      ║                       Listening *:4444 ║  
                                          ╚════════════════════════════════════════╝  
                                                        Private Network               
                                                                                        
                                  
 
    This command needs to be run on the DMZ. What it does it literally reach out to each of 
    these listeners, and do the equivilant of a rollover cable to them 
        ( input 1 > output 2 ; input 2 > output 1 )
 
    There's a LOT more you can do with this, but this is just an example I could think of. 
 
3.) Listener <=> Listener <=> Client <=> Client <=> Client relay. No seriously. (-w)
 
    Basically we're going to be making a HUGE transparent proxy straight to our target, using nothing
    but netcat relays. This gets rid of the problem of using all our standardized tools ( psexec, wmic,
    smbclient, you name it ). 
 
    Ready? Good.
 
    For this we need an extra tower (or a virtual machine if you're clever), but our set-up looks 
    something like this:
 
    +----+
    | Us |═╗ ( Samba connection to 
    +----+ ║ <==  Linux box on 445 )
        ___║__             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
       |L*:445|---┐   ←  ← ┃  ←  ←  ←  +---------------+  →  →  →          ( Our shell account fetches the         ┃
    +-----------+ | ╔═══════════════╦══| Shell account |══╦══════════╗ ↑       SMB data for us, and negotiates     ┃
    | Extra box | | ║      ┃        ║  +---------------+  ║          ║    <==   our end of the connection on our   ┃
    |  (Linux)  | | ║      ┃        ╚═════════════════════╝          ║ ↑       behalf )                            ┃
    +-----------+ | ║      ┃        Client to client relay         __║___                                          ┃
      |L*:4444|---┘ ║      ┃       (transparent connection)       |L*:445|                                         ┃
       ‾‾‾║‾‾‾      ║ ↑    ┃                                 +----------------------+                              ┃
          ╚═════════╝      ┃                                 | Exploi...er "usable" |                              ┃
            →    →         ┃                                 |         Box          |                              ┃
     ( Our SMB Request is  ┃                                 +----------------------+                              ┃
       passed over reverse ┃                                                                                       ┃
       connection )        ┃                                                                                       ┃
                           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                                Private Network
 
 
    Hopefully this makes sense, after all it IS 4:45 in the morning :-P. Either way this entire process can be broken down
    into a number of steps:
 
    1.) The first thing we do is set up our listener > listener relay on our linux box
    2.) Then we set up our client > client relay, connecting back to our listener linux box
    3.) Now we make our samba request to our linux box, which gets connected to the incoming client connection
    4.) Our shell account passes our info to the windows box on our behalf, and recieves everything, and throws it back
    5.) Now we can interact with our linux box, and everything we do will be fowarded to our windows box!
 
    When this mode is invoked, it asks you to specify if you're setting up the listener or the client bridge, and will
    have you fill in the details accordingly. 
 
 
EOF
}
 
function scan_target {
    echo -ne "${green}Port Range? (e.g. 1-1024) : ${reset}"
            read Portrange
    echo "Scanning $1:$Portrange"
    echo "To run this scan again just run nc -z -v \"$1\" \"$Portrange\" 2>&1 | grep \"succeeded\" | awk '{print \$5,\$4,"Open!",\$6}'"
    nc -z -v "$1" "$Portrange" 2>&1 | grep succeeded\! | awk '{print $5,$4,"Open!",$6}' >/tmp/scanresults &
    p=$!
 
    setterm -cursor off
        while [ -d /proc/$p ]; do
                        echo -ne "-\b" ; sleep .01
                        echo -ne "/\b" ; sleep .01
                        echo -ne "|\b" ; sleep .01
                        echo -ne "\\"  ; echo -ne "\b"  ; sleep .01
            echo -ne "."
        done
 
echo -e "\n"
cat /tmp/scanresults
rm -rf /tmp/scanresults
setterm -cursor on
    exit 0
}
 
function client_listener_relay {
echo -ne "${green}Local port to listen on? : ${reset}"
    read LocalPort
echo -ne "${green}  Host to connect to?    : ${reset}"
        read RemoteHost
echo -ne "${green}     Remote port?        : ${reset}"
    read RemotePort
echo -ne "${green}Output? (n=none, u=uuencode, s=stings, d=DSP, f=file)? : ${reset}"
    read Encoding
 
if [ ! -p $fifopath ]; then
    echo -ne "${blue}Creating FIFO Pipe...${reset}"
    mkfifo $fifopath
    if [ $? != 0 ]; then
        echo -e "${red}ERROR: Can't create FIFO, do you have permission for this directory?${reset}"
        exit 1
    fi
    echo -e "${green}Done"
fi
 
if [ $Encoding == "n" ]; then
    echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
    echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort >$fifopath;rm /tmp/p${blue}\"${red}"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort >$fifopath 
elif [ $Encoding == "u" ]; then
        echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath | uudecode -m -;rm /tmp/p${blue}\"${red}"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath | uuencode -m -
elif [ $Encoding == "d" ]; then
        echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath >/dev/dsp;rm /tmp/p${blue}\"${red}"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath >/dev/dsp
elif [ $Encoding == "f" ]; then
        echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath >>/tmp\`date+%s\`.nc-relay;rm /tmp/p${blue}\"${red}"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath >>/tmp/`date +%s`.nc-relay
elif [ $Encoding == "s" ]; then
        echo -e "\n${green}Pipe should be running on *:$LocalPort!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath | strings -n 6;rm /tmp/p${blue}\"${red}"
    echo -e "\n============Start String Dump============\n"
    nc -l -k $LocalPort 0<$fifopath | nc $RemoteHost $RemotePort | tee $fifopath | strings -n 6
else
    echo "Sry dudez, you gotta put in the right encoding! (only n,u,s,d,f. I'll fix it later)"
    exit 1
fi
 
rm -f $fifopath
killall nc 2> /dev/null
}
 
function client_client_relay {
echo -ne "${green}*NOTE* You need to have listeners bound on both clients before you can make the connection between them. [duh]\n"
echo -ne "\tYou should use ${blue}nc -nvl [PORT]${green} to set up your listening hosts\n\n"
echo -ne "${green}Specify hosts in the ip:port convention (e.g. 10.0.0.1:4444)\n"
echo -ne "${green}Host 1 : ${reset}"
        read Host1
echo -ne "${green}Host 2 : ${reset}"
        read Host2
echo -ne "${green}Output? (n=none, u=uuencode, s=stings, d=DSP, f=file)? : ${reset}"
        read Encoding
 
Host1Port=`echo $Host1 | cut -d ':' -f2`
Host1Host=`echo $Host1 | cut -d ':' -f1`
Host2Port=`echo $Host2 | cut -d ':' -f2`
Host2Host=`echo $Host2 | cut -d ':' -f1`
 
if [ ! -p $fifopath ]; then
        echo -ne "${blue}Creating FIFO Pipe...${reset}"
        mkfifo $fifopath
        if [ $? != 0 ]; then
                echo -e "${red}ERROR: Can't create FIFO, do you have permission for this directory?${reset}"
                exit 1
        fi
        echo -e "${green}Done"
fi
 
if [ $Encoding == "n" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"          
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port 1>$fifopath;rm /tmp/p${blue}\"${red}"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port 1>$fifopath
elif [ $Encoding == "u" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath | uudecode -m -;rm /tmp/p${blue}\"${red}"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath | uuencode -m -
elif [ $Encoding == "d" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath >/dev/dsp;rm /tmp/p${blue}\"${red}"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath >/dev/dsp
elif [ $Encoding == "f" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath >>/tmp\`date+%s\`.nc-relay;rm /tmp/p${blue}\"${red}"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath >>/tmp/`date +%s`.nc-relay
elif [ $Encoding == "s" ]; then
        echo -e "\n${green}Pipe should now be connecting $Host1 > $Host2 through us!\n"
        echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath | strings -n 6;rm /tmp/p${blue}\"${red}"
        echo -e "\n============Start String Dump============\n"
        nc $Host1Host $Host1Port 0<$fifopath | nc $Host2Host $Host2Port | tee $fifopath | strings -n 6
else
        echo "Sry dudez, you gotta put in the right encoding! (only n,u,s,d,f. I'll fix it later)"
        exit 1
fi
 
rm -f $fifopath
killall nc 2> /dev/null
}
 
function trans_proxy {
echo -e "${red}
    +----+
    | Us |═╗                       
    +----+ ║                        
        ___║__             ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ${green}(A)${red}  |L*:445|---┐   ←  ← ┃  ←  ←  ←  +---------------+  →  →  →                                            ┃
    +-----------+ | ╔═══════════════╦══| Shell account |══╦══════════╗ ↑                                     ┃
    | Extra box | | ║      ┃        ║  +---------------+  ║          ║                                       ┃
${green}(#1)${red}|  (Linux)  | | ║      ┃        ╚═════════════════════╝          ║ ↑                                     ┃
    +-----------+ | ║      ┃        Client to client relay         __║___                                    ┃
  ${green}(B)${red} |L*:4444|---┘ ║      ┃       (transparent connection)       |L*:445| ${green}(A)${red}                               ┃
       ‾‾‾║‾‾‾      ║ ↑    ┃                ${green}(#2)${red}             +----------------------+                        ┃
          ╚═════════╝      ┃                                 | Exploi...er "usable"   |                        ┃
            →    →         ┃                                 |         Box          |                        ┃
                           ┃                                 +----------------------+                        ┃
                           ┃                                           ${green}(#3)${red}                                  ┃
                           ┃                                                                                 ┃
                           ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                                                                Private Network
 
See the help doc ([-h]) for more info"
echo -e "${blue}
 1. ) Extra box
 2. ) Shell Account"
echo -ne "${green}So first thing's first - which host is this? : "
read Response
echo $Response | egrep '(1|2)' >/dev/null; 
 
if [ $? != "0" ]; then
    echo -e "${red}Invalid response"
    clean_up
    exit 1  
fi
 
if [ $Response == "1" ]; then
    echo -ne "${green}What is the endpoint port (A)? : "
    read EndPort
 
    if [[ "$EndPort" -lt 1 || "$EndPort" -gt 65535 ]]; then
        echo -e "${red}Invalid port! Try again."
        clean_up
        exit 1
    fi
     
    echo -ne "${green}What port do you want to listen on (B)? : "
    read ListenPort
     
    if [[ "$ListenPort" -lt 1 || "$ListenPort" -gt 65535 ]]; then
            echo -e "${red}Invalid port! Try again."
            clean_up
            exit 1
    fi
 
    echo -ne "${green}Output? (n=none, u=uuencode, s=stings, d=DSP, f=file)? : ${reset}"
            read Encoding
 
 
    if [ ! -p $fifopath ]; then
            echo -ne "${blue}Creating FIFO Pipe...${reset}"
            mkfifo $fifopath
            if [ $? != 0 ]; then
                    echo -e "${red}ERROR: Can't create FIFO, do you have permission for this directory?${reset}"
                    exit 1
            fi
            echo -e "${green}Done"
    fi
     
    if [ $Encoding == "n" ]; then
            echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"          
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  >$fifopath;rm /tmp/p${blue}\"${red}"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  >$fifopath
    elif [ $Encoding == "u" ]; then
            echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath | uudecode -m -;rm /tmp/p${blue}\"${red}"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath | uuencode -m -
    elif [ $Encoding == "d" ]; then
        echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath >/dev/dsp;rm /tmp/p${blue}\"${red}"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath >/dev/dsp
    elif [ $Encoding == "f" ]; then
            echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath >>/tmp\`date+%s\`.nc-relay;rm /tmp/p${blue}\"${red}"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath >>/tmp/`date +%s`.nc-relay
    elif [ $Encoding == "s" ]; then
            echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
            echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath | strings -n 6;rm /tmp/p${blue}\"${red}"
            echo -e "\n============Start String Dump============\n"
            nc -nvl $ListenPort  0<$fifopath | nc -nvl $EndPort  | tee $fifopath | strings -n 6
    else
            echo "Sry dudez, you gotta put in the right encoding! (only n,u,s,d,f. I'll fix it later)"
            exit 1
    fi
 
    rm -f $fifopath
    killall nc 2> /dev/null
    exit 0
 
elif [ $Response == "2" ]; then
    echo -ne "${green}What is your first host/port [B]? (e.g. 34.125.22.83:4444) : ${reset}"
        read Host1
    echo -ne "${green}What is your second host/port [A]? (e.g. 10.0.0.3:445) : ${reset}"
            read Host2
    echo -ne "${green}Output? (n=none, u=uuencode, s=stings, d=DSP, f=file)? : ${reset}"
            read Encoding
 
    Host1Port=`echo $Host1 | cut -d ':' -f2`
    Host1Host=`echo $Host1 | cut -d ':' -f1`
    Host2Port=`echo $Host2 | cut -d ':' -f2`
    Host2Host=`echo $Host2 | cut -d ':' -f1`
 
        if [ ! -p $fifopath ]; then
                echo -ne "${blue}Creating FIFO Pipe...${reset}"
                mkfifo $fifopath
                if [ $? != 0 ]; then
                        echo -e "${red}ERROR: Can't create FIFO, do you have permission for this directory?${reset}"
                        exit 1
                fi
                echo -e "${green}Done"
        fi
 
 
        if [ $Encoding == "n" ]; then
                echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"          
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  >$fifopath;rm /tmp/p${blue}\"${red}"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  >$fifopath
        elif [ $Encoding == "u" ]; then
                echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath | uudecode -m -;rm /tmp/p${blue}\"${red}"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath | uuencode -m -
        elif [ $Encoding == "d" ]; then
        echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath >/dev/dsp;rm /tmp/p${blue}\"${red}"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath >/dev/dsp
        elif [ $Encoding == "f" ]; then
                echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath >>/tmp\`date+%s\`.nc-relay;rm /tmp/p${blue}\"${red}"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath >>/tmp/`date +%s`.nc-relay
        elif [ $Encoding == "s" ]; then
                echo -e "\n${green}Pipe should now be connecting $ListenPort > $EndPort!\n"
                echo -e "${blue}You can run this in the future by running \n\t\"${green}mkfifo /tmp/p; nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath | strings -n 6;rm /tmp/p${blue}\"${red}"
                echo -e "\n============Start String Dump============\n"
                nc $Host1Host $Host1Port  0<$fifopath | nc $Host2Host $Host2Port  | tee $fifopath | strings -n 6
        else  
                echo "Sry dudez, you gotta put in the right encoding! (only n,u,s,d,f. I'll fix it later)"
                exit 1
        fi
 
        rm -f $fifopath
        killall nc 2> /dev/null
        exit 0
 
fi
 
exit 0
}
 
function clean_up {
 
echo -ne "\n\n${red}Exit request detected, cleaning up..."
 
rm -f $fifopath >/dev/null
killall nc 2>/dev/null
echo -ne "${green}Done${reset}\n"
rm -rf /tmp/scanresults 2>&1 >/dev/null
setterm -cursor on
exit 0
 
}
 
fifopath="/tmp/p"
blue="\e[1;34m"
white="\e[1;37m"
red="\e[1;31m"
red_ul="\e[31;4m"
cyan="\e[1;36m"
yellow="\e[1;33m"
green="\e[1;32m"
reset="\e[33;0m"
 
 
trap clean_up SIGINT SIGTERM
 
while getopts “hs:lcp” flag
do
    case $flag in
 
    h)
        print_usage
        exit 0
        ;;
    s)
        scan_target "$OPTARG"
        ;; 
    l)
        client_listener_relay
        ;; 
    c)
        client_client_relay
        ;; 
    p)
        trans_proxy
        ;; 
    ?)
        print_usage
        exit 1
        ;;
    esac
done
 
if [ "$1" == "" ]; then
 
echo "
usage: $0 [options]
 
OPTIONS:
   -h             Print [-h]elp page
   -s [HOST]      [-s]can a host for open ports
   -l             Client => [-l]istener relay
   -c             [-c]lient => client relay
   -p             Transparent [-p]roxy 
"
 
fi
