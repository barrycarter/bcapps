#!/usr/local/bin/python

# more cloud testing, above/beyond playground.py

import cloud;
import os;
import time;

def sysop(cmd): return os.popen(cmd).read()

# jid = cloud.call(sysop, "curl http://weather.aero/dataserver_current/cache/metars.cache.csv.gz | gunzip | tail -n +6 > /dev/null", _profile=True, _label="curly")
# jid = cloud.call(sysop, "curl http://test17.test.barrycarter.info > /dev/null & curl http://test18.test.barrycarter.info > /dev/null & curl http://test19.test.barrycarter.info > /dev/null & sleep 5", _label="curl3")
# jid = cloud.call(sysop, "sleep 10", _label="sleepy", _profile=True)

# jid = cloud.call(time.sleep, 10, _label="pysleep", _profile=True)

jid = cloud.call(sysop, "bc-voronoi-temperature.pl --nodaemon &", _env="barryenv1", _profile=True)
print cloud.result(jid)

