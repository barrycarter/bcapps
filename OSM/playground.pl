#!/bin/perl

use Google::ProtocolBuffers;
require "/usr/local/lib/bclib.pl";

$all = read_file("/home/barrycarter/20150807/albuquerque_new-mexico.osm.pbf");

my($res) = Google::ProtocolBuffers->decode($all);

debug($res);
