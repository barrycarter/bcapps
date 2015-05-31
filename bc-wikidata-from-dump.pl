#!/bin/perl

# reads wikidata from the 45G 20150525.json file

require "/usr/local/lib/bclib.pl";

open(A,"/home/barrycarter/20150530/20150525.json");

read(A,$buf,1000000);

$buf=~s/\{\"id\":\"Q8\".*$//s;
$buf=~s/^\[//;
$buf=~s/,$//;

debug(var_dump("hash",JSON::from_json($buf)));


