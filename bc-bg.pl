#!/bin/perl

# print updated text as my background image
# came from a hideously much longer program
# probably only useful to me <h>but I like spamming github</h>

require "/home/barrycarter/BCGIT/bclib.pl";

# need current time
$now=time();
chdir(tmpdir());

# no X server? die instantly (really only useful for massive rebooting
# and errors early May 2007)
if (system("xset q 1> /dev/null 2> /dev/null")) {exit(0);}

# TODO: add locking so program doesn't run twice


# @info = stuff we print (to top left corner)
# local and GMT time
push(@info,"MT: ".stardate($curtime));
push(@info,strftime("GMT: %Y%m%d.%H%M%S",gmtime($curtime)));

# figure out what alerts to suppress
# format of suppress.txt:
# xyz stardate [suppress alert xyz until stardate (local time)]

@suppress = `egrep -v '^#' /home/barrycarter/ERR/suppress.txt`;

# know which alerts to suppress
for $i (@suppress) {
  ($key,$val) = split(/\s+/,$i);
  $suppress{$key}=$val;
}

# all errors are in ERR subdir (and info alerts are there too)
for $i (glob("/home/barrycarter/ERR/*.err")) {
  for $j (split("\n",read_file($i))) {
    # unless suppressed, push to @info
    if ($suppress{$j} > stardate($curtime)) {next;}
    push(@info,$j);
  }
}

# TODO: add USDCAD/JPY quotes
# TODO: add adjtimex
# TODO: add alarms
# TODO: add weather and forecast

# push output to .fly script
for $i (@info) {
  # TODO: order these better
  push(@fly, "string 0,0,255,0,$pos,medium,$i");
  $pos+=15;
}

# send header and output to fly file
# tried doing this w/ pipe but failed
# setpixel below needed so bg color is black
open(A, "> bg.fly");
print A << "MARK";
new
size 1024,768
setpixel 0,0,0,0,0
MARK
    ;

for $i (@fly) {print A "$i\n";}
close(A);

debug(read_file("bg.fly"));

# using temp file disappears too fast for xv somehow
system("fly -i bg.fly -o /tmp/bg.gif; xv +noresetroot -root -quit /tmp/bg.gif");
