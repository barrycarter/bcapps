#!/bin/perl

# Reminds me to get up and walkaround regularly (via cron), unless a
# reminder is already on screen

# Tried this as simple cron job "pgrep -f 'walkaround' || xmessage get
# up and walkaround &", but the shell started by cron matches
# 'walkaround', ha!

require "/usr/local/lib/bclib.pl";

# run only once (no warnings during lock phase)
$globopts{nowarn}=1;
unless(mylock("bc-walkaround.pl","lock")) {exit(0);}
$globopts{nowarn}=0;

debug("BETA");

$msg = "Get up and walkaround";
$shortmsg = "GUAWA";

# record that this message popped up (can be useful)
# my normal 'diary' file is /home/barrycarter/TODAY/yyyymmdd.txt, but
# I'm not quite prepared to append to that (yet)
my($file) = strftime("/home/barrycarter/TODAY/%Y%m%d.txt", localtime($now));
my($time) = strftime("%H%M%S", localtime($now));
append_file("$time POST: $shortmsg\n",$file);

# reply must be nonempty (or annoy crap out of myself)
my($res);

for (;;) {
  # I have ~/.fvwm2rc so that "sticky" in title makes it sticky:
  # Style "*sticky*" NoTitle, NoHandles, Sticky
  # TODO: make this out/err/res style so I can ignore ugly error:
  # "Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged."
  # hate doing "2> /dev/null" here but "GtkDialog mapped without a
  # transient parent. This is discouraged." is freaking annoying
  $res = `zenity --entry --text "$msg" --width 1024 --title stickymessage 2> /dev/null`;
  if ($res=~/\S/) {last;}
  $msg .= " [reply cannot be blank]";
}

# recompute file here in case day has changed
$now = time();
my($file2) = strftime("/home/barrycarter/TODAY/%Y%m%d.txt", localtime($now));
my($time2) = strftime("%H%M%S", localtime());
append_file("$time2 GUAWA REPLY: $res\n",$file2);
mylock("bc-walkaround.pl","unlock");
