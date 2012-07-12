#!/bin/perl
use XML::Bare;
my($ob) = new XML::Bare(text=>'<xml><name>Bob</name></xml>');
for $i (keys %{$ob->{xml}}) {print "KEY: $i\n";}
