#!/bin/perl

# selectively rips a video (one frame per second) to display it faster

require "/usr/local/lib/bclib.pl";

# TODO: 1280x720 seems to be the best resolution for youtube (even
# though my own screen resolution is lower)

# 256x144 is 5x5 tiling which really seems nice
# TODO: do I want frames?

# TODO: create subdir to hold these and more subdir per film
# TODO: cleanup file names considerably
# TODO: use xargs for multiples

if ($#ARGV > 0) {die "ERROR: accepts only one argument";}

my($file) = @ARGV;

my($out, $err, $res);

# the output file base, cleanedup version of name

$filebase = $file;

# just the tail + strip extension + convert nonalpha to underscore

$filebase=~s%^.*/%%;
$filebase=~s/\.[^\.]*?$//;
$filebase=~s/[^\w]+/_/g;

# creating all frames for all things in a single dir is ugly, but I am
# only doing one frame per second so potentially acceptable

# TODO: maybe check if $filebase_0000001.jpg or whatever exists either
# in this dir or a subdir and dont run if it does qmark

($out, $err, $res) = cache_command2(qq`ffmpeg -i '$file' -vf "select=not(mod(n\\,24)), scale=256:144" -vsync vfr $bclib{home}/VIDEOFRAMES/${filebase}_%08d.jpg`);

debug("OUT: $out, ERR: $err, RES: $res");


