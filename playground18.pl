#!/bin/perl

require "/usr/local/lib/bclib.pl";
use App::perl2js::Converter;
print App::perl2js::Converter->new->convert(read_file("/usr/local/lib/bclib.pl"));
