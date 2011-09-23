#!/bin/bash
#
# This Bash file simply takes a txt file with a lot of links,
# and filter out multiply redundent links. Definitely not the
# most pretty thing in the world, but it works. Going to be
# re-written eventually in python. 
#
# Ex.) 
#	http://www.blah.com/stuff.php?id=1
#	http://www.blah.com/otherstuffs.php?id=1
#	http://www.blah.com/stuff.php?id=2
#	http://www.blah.com/otherstuffs.php?id=2
#	http://www.blah.com/stuff.php?id=3
#	http://www.blah.com/otherstuffs.php?id=3
#	http://www.blah.com/stuff.php?id=4
#	http://www.blah.com/otherstuffs.php?id=4
#
# Output.) 
#	http://www.blah.com/stuff.php?id=1
#	http://www.blah.com/otherstuffs.php?id=1
#	


for x in `for i in \`cat $1 | grep \= | cut -d '=' -f1 | sort -u\`; do echo $i; done`; do cat $1 | grep $x | head -n1 | sed 's/\.\.\///g'; done
