#!/bin/perl

# An alarm with a snooze button(s) using yad

# Usage: $0 message

# Options:
# --width: width of popup
# --fontsize: displayed font size

# TODO: this is bad because Perl script keeps running until snooze or
# cancel is hit

# TODO: maybe allow more options

# Sample yad: yad --button=1:1 --button=2:2 --button=3:3

require "/usr/local/lib/bclib.pl";

# default option values

defaults("width=1600&fontsize=30");

# TODO: this might be bad-- maybe required quoted arg[0]

my($msg) = join(" ", @ARGV);

# this maps exit values to button names (note: 0 = done)

# 6 and 7m are important to me, though probably to no one else

my(@times) = ("DONE", "1m", "5m", "6m", "7m", "10m", "15m", "30m",
"45m", "1h", "90m", "2h", "4h", "8h", "16h");

# build up the buttons option (intentional start at 1)

my(@buttons);

for $i (0..$#times) {
  debug("I: $i");
  push(@buttons, "--button $times[$i]:$i");
}

debug(@buttons);

my $buttons = join(" ", @buttons);

debug("BUTTONS: $buttons");

# --fontname doesn't work w/ text entry, this is the hack

$msg = qq%<span font="$globopts{fontsize}">$msg</span>%;

my($cmd) = qq%yad --text='$msg' --text-align='center' --width=$globopts{width} 
            $buttons  --buttons-layout='spread' --sticky --undecorated%;


$cmd=~s/\n/ /sg;

debug($cmd);

my($out, $err, $res) = cache_command2($cmd);

# TODO: would be REALLY nice to get this as stdout, like in zenity, or
# to run a program when button is pressed instead of waiting above

debug("OUT: $out, ERR: $err, RES: $res");

# Perl returns $res vals * 256

$res>>=8;

# if done, do nothing

unless ($res) {exit(0);}

# convert to time and send to at

$times[$res]=~s/m/ minutes/;
$times[$res]=~s/h/ hours/;

open(A, "|at -M 'now + $times[$res]'");

# TODO: better way to do this?

print A $0, " ", join(" ", @ARGV);

close(A);

# TODO: setting button tags to non-numeric runs command (but not working?)
