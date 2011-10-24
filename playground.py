#!/usr/local/bin/python

# cloud testing (you must have a picloud.com account AND set
# cloudconf.py correctly for any of this to work)

import cloud
jid = cloud.call(lambda: 3*3)
print cloud.result(jid)
