#!/usr/bin/env python


def isdrunk():
	with open('d.txt','r') as h:
		for line in h:
			if "Yes" in line:
				return True
			else:
				return False
if __name__ == "__main__":
	print isdrunk()
