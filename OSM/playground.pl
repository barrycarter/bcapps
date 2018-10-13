#!/bin/perl

use Google::ProtocolBuffers;
require "/usr/local/lib/bclib.pl";

my $dynamic = Google::ProtocolBuffers::Dynamic->new;
$dynamic->load_string('fileformat.proto', read_file('fileformat.proto'));
$dynamic->load_string('osmformat.proto', read_file('osmformat.proto'));
$dynamic->map({
    package => 'OSMPBF', prefix => 'OSMPBF',
    options => {qw'accessor_style single_accessor'}
});

debug($dynamic);

die "TESTING";

# below failed miserably, at least on 11 Oct 2018

$all = read_file("/home/barrycarter/20181011/albuquerque_new-mexico.osm.pbf");

my($res) = Google::ProtocolBuffers->decode($all);

debug($res);
