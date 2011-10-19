#!/usr/bin/env python

import time

def wakeup():
    newtime = time.time() + 840
    times = ""
    for i in range(6):
        newtime = newtime + 5400
        a = time.localtime(newtime)
        if i < 5:
            times += time.strftime('%-I:%M %p',a) + ', or '
        else:
            times += time.strftime('%-I:%M %p',a)
    return [times]


if __name__ == "__main__":
    print wakeup()
