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

my($cmd) = "yad --text='$msg' --text-align='center' --width=$globopts{width} 
            --button 1m:1 --button 2m:2 --button 3m:3 
            --buttons-layout='center' --sticky --undecorated 
            --fontname='Serif bold italic 20' --always-print-result";

$cmd=~s/\n/ /sg;

my($out, $err, $res) = cache_command2($cmd);

debug("OUT: $out, ERR: $err, RES: $res");

# TODO: setting button tags to non-numeric runs command
