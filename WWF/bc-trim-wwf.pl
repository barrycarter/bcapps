#!/bin/perl

# Trims large save files from wwf games to smaller files with same data

require "/usr/local/lib/bclib.pl";

($data,$file) = cmdfile();

# playerData is the only thing we need from "header"
$data=~/\s+(playerData:.*?)\n/s;
$pd = $1;

# nuke to "your move" and everything from "sorry"
$data=~s%^(.*?)<h5>Your Move</h5>%%s;
$data=~s%<h2>Sorry</h2>.*$%%s;

# strip multiple spaces
$data=~s/ +/ /isg;

debug("DATA: $data");


