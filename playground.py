#!/usr/local/bin/python

# cloud testing (you must have a picloud.com account AND set
# cloudconf.py correctly for any of this to work)

# from __future__ import print_function
import cloud
import os;

def mirror(x): return x
def readfile(f): return open(f, 'r').read()
def sysop(cmd): return os.popen(cmd).read()


# below is one off
# def update_voronoi(): sysop("bc-voronoi-temperature.pl --nodaemon 1> /tmp/out.txt 2> /tmp/err.txt; cat /tmp/out.txt /tmp/err.txt")
# cloud.cron.register(update_voronoi, "update_voronoi", "*/5 * * * *", _env="barryenv1")

# cloud.call(sysop, "ls -l /var/tmp > /tmp/out.txt; cat /tmp/out.txt", _env="barryenv1")
jid = cloud.call(sysop, "ls -ld /home/picloud")
print cloud.result(jid)

exit();

# jid = cloud.call(sysop, "date | Mail -s Hi playground@barrycarter.info 1> /tmp/out.txt 2> /tmp/err.txt; cat /tmp/out.txt /tmp/err.txt")

# jid = cloud.call(sysop, "bc-voronoi-temperature.pl --nodaemon 1> /tmp/out.txt 2> /tmp/err.txt; cat /tmp/out.txt /tmp/err.txt", _env="barryenv1")



exit();

# jid = sysop("ls")
# print jid

# os.system("ls")

# jid = cloud.call(mirror, "hello")
# jid = cloud.call(mirror, "`date`")
# jid = cloud.call(os.system, "date"); # doesnt work
# jid = cloud.call(readfile, "/etc/passwd")
# jid = cloud.call(os.system, "cat /etc/passwd")
# jid = cloud.call(os.popen, "ls")
# jid = cloud.call(sysop, "date")
# jid = cloud.call(sysop, "bc-temperature-voronoi --nodaemon", _env="barryenv1")
# jid = cloud.call(sysop, "rsync -Pavz /etc/passwd root@data.barrycarter.info:/sites/TEST/ |& tee")

# below WORKS!
# jid = cloud.call(sysop, "ls -l /tmp/; date", _env="barryenv1")

# jid = cloud.call(sysop, "date; ls -l /tmp/ > /tmp/ls.txt; date; cat /tmp/ls.txt", _env="barryenv1")

# jid = cloud.call(sysop, "ls -l /asfadsa 2> /tmp/ls.txt; date; cat /tmp/ls.txt", _env="barryenv1")

# jid = cloud.call(sysop, "bc-voronoi-temperature.pl --nodaemon 1> /tmp/stdout.txt 2> /tmp/stderr.txt; echo OUT; cat /tmp/stdout.txt; echo ERR; cat /tmp/stderr.txt", _env="barryenv1")

# jid = cloud.call(sysop, "whoami")

# jid = cloud.call(sysop, "sudo ls -laR /home/picloud/* 1> /tmp/sudo.txt 2> /tmp/sudo.err; cat /tmp/sudo.???")

# jid = cloud.call(sysop, "whoami; pwd 1> /tmp/out.txt 2> /tmp/err.txt; cat /tmp/out.txt; cat /tmp/err.txt")

# jid = cloud.call(sysop, "ls -laR /")

# jid = cloud.call(os.system, "ls", _env="barryenv1", _profile=True)
# jid = cloud.call(os.system, "rsync /usr/local/bin/bc-temperature-voronoi.pl root\@data.barrycarter.info:/sites/TEST/", _env="barryenv1", _profile=True)
# jid = cloud.call(os.system, "bc-voronoi-temperature.pl --nodaemon", _env="barryenv1")

# cloud.files.put("sample-data/testfile.txt")

print cloud.files.getf("testfile.txt").read()

# print cloud.files.put("playground.svg")
# print cloud.files.getf("playground.svg").read()

# print cloud.files.list()

# jid = cloud.call(readfile, "/usr/share/")
# print cloud.result(jid)

# print cloud.rest.publish(readfile, "readfile", out_encoding='raw')
# print cloud.rest.publish(os.system, "mysys", out_encoding='raw')
# print cloud.rest.publish(mirror, "mirror", out_encoding='raw')

# https://api.picloud.com/r/2957/mysys
# https://api.picloud.com/r/2957/readfile

# def mirror(x): return x

# jid = cloud.call(mirror, "`date`")
# print cloud.result(jid)

# for x in range(1,100):
#    cloud.call(os.system,"curl picloudips.barrycarter.info")

# jid = cloud.call(os.system, "curl `perl -le 'print time()'`.barrycarter.info")
# jid = cloud.call(os.system, "curl `whoami`.barrycarter.info")
# jid = cloud.call(os.system, "curl '`sudo whoami`.barrycarter.info'")
# jid = cloud.call(os.system, "curl \"`date`.barrycarter.info\"")
# print cloud.result(jid)

# in my logs:

# 184.73.142.136 pi.barrycarter.info - [25/Oct/2011:11:44:35 -0600] "GET / HTTP/1.1" 200 94 "-" "curl/7.21.0 (x86_64-pc-linux-gnu) libcurl/7.21.0 OpenSSL/0.9.8o zlib/1.2.3.4 libidn/1.18"
