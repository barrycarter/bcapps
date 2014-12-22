#!/bin/sh

zip -v -tt 11212014 -r oldstuff /usr/local/etc/weekly-backups/files

exit;

# tar old files permanently (just testing +N command for now; -N =
# newer, so +N = older, some suggest)

tar --hard-dereference --bzip +N '2001-01-01' /usr/local/etc/weekly-backups/files -cvhf test0.tbz

exit;

# times find using files newer than timestamp

# below was test for syntax
# ( date ; ls; date ) > /home/barrycarter/20141221/timetest.txt
( date ; sudo find / -xdev -newer /tmp/buf.timestamp -ls; date ) > /home/barrycarter/20141221/timetest.txt

exit;
