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
my($sender) = "admin!admin\@admin";

# TODO: this should be in bclib.pl (remove old copy of debug file)
system("rm /tmp/fakeirc.txt");

# must read two lines from client first, otherwise pidgin whines
my($user) = scalar(<>);
my($nick) = scalar(<>);

# get just the nickname
unless ($nick=~/NICK (.*?)\s*$/) {
  # TODO: die a bit nicer here
  die "NO NICKEE, NO PLAYEE";
}

$nick = $1;

send_msg(":$sname 376 $nick :End of /MOTD command.");
send_msg(":$sender PRIVMSG $nick :hello, I am $channel printing even before you do anything");

while (<>) {

  get_msg($_);

  # JOIN message
  if (/^JOIN/) {
    send_msg(":$sname 332");
  }

  # print to an arbitrary channel the user isnt in
  send_msg(":$sender PRIVMSG $nick :hello, I am $sender");

}

# these are just wrappers for debugging

sub send_msg {
  my($msg) = @_;
  debug("SENDING: $msg");
  print "$msg\r\n";
}

sub get_msg {
  my($msg) = @_;
  debug("GOT: $msg");
}


