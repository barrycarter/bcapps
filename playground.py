#!/usr/local/bin/python

# cloud testing (you must have a picloud.com account AND set
# cloudconf.py correctly for any of this to work)

import cloud
import os

#os.system("date")
# exit("TESTING")

def sys(x): os.system(x)
jid = cloud.call(sys, "curl http://barrycarter.info/")
print cloud.result(jid)

# os.system("perl -v")

# die
# jid = cloud.call(lambda: 3*3)
# jid = cloud.call(sys("perl -v"))

