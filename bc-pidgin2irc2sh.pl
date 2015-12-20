#!/bin/perl

# creates a psuedo IRC server (called from xinetd.conf) to run shell
# commands (including things like 'telnet') from Pidgin/GAIM

require "/usr/local/lib/bclib.pl";

# no buffering for instant response
$|=1;

# server name
my($sname) = "bic";

# just while testing
my($chan) = "channel";

# TODO: this should be in bclib.pl (remove old copy of debug file)
system("rm /tmp/fakeirc.txt");

# must read two lines from client first, otherwise pidgin whines
my($user) = scalar(<>);
my($nick) = scalar(<>);

debug("USER: $user","NICK: $nick");

print ":$sname 376 barrycarter :End of /MOTD command.\n";

print ":admin PRIVMSG #$channel  :hello, I am $channel printing even before you do anything\n";

while (<>) {

  # JOIN message
  if (/^JOIN/) {
    print ":$sname 332\n";
  }

  # print to an arbitrary channel the user isnt in
  print ":admin PRIVMSG #$channel :hello, I am $channel\n";

  debug("GOT: $_");
}


