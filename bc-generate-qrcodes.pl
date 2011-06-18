#!/bin/perl

# Generate mosaics of QR codes

require "bclib.pl";
use Imager::QRCode;

warn("setting --keeptemp");
$globopts{keeptemp}=1;
chdir(tmpdir());
debug(system("pwd"));

# http://chart.apis.google.com/chart?chs=200x200&cht=qr&chld=|0&chl=http%3A%2F%2Fbarrycarter.info%2F

$im = Imager::QRCode->new(size => 8);

for $i ("aaa".."baa") {
  debug("I: $i");
  $im->plot("http://$i.com")->write(file => "$i.png");
}

# Imager::QRCode->new->plot('http%3A%2F%2Fbarrycarter.info%2F')->write(file => '/tmp/hello.png');

