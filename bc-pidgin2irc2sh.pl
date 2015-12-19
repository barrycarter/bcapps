#!/bin/perl

# creates a psuedo IRC server (called from xinetd.conf) to run shell
# commands (including things like 'telnet') from Pidgin/GAIM

require "/usr/local/lib/bclib.pl";

# no buffering for instant response
$|=1;

# start with something I know works (from testing)

<>;<>;

print << "MARK";
:ircd.ratbox 376 barrycarter :End of /MOTD command.
MARK
;

# print ":server 001 foo: bar";

while (<>) {
  print "GOT $_";
}


