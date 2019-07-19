#!/bin/perl

# An alarm with a snooze button(s) using yad

# Options:

# --width: width of popup

# TODO: this is bad because Perl script keeps running until snooze or
# cancel is hit

# Usage: $0 message

# TODO: maybe allow more options

# Sample yad: yad --button=1:1 --button=2:2 --button=3:3

require "/usr/local/lib/bclib.pl";

# default option values

defaults("width=1600");

# TODO: this might be bad-- maybe required quoted arg[0]
my($msg) = join(" ", @ARGV);

debug("MSG: $msg");

my($cmd) = "yad --text='$msg' --text-align='center' --width=$globopts{width} 
            --button 1:1m --button 2:2m --button 3:3m 
            --buttons-layout='center'";

$cmd=~s/\n/ /sg;

my($out, $err, $res) = cache_command2($cmd);

