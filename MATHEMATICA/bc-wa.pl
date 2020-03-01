#!/bin/perl

# thin wrapper about Wolfram Alpha API

# --type=short|xml: use short or XML query (default is short)

require "/usr/local/lib/bclib.pl";
require "/home/user/bc-private.pl";

defaults("type=short");

my($query) = urlencode(join(" ",@ARGV));

# TODO: remove caching?

my($url);

if ($globopts{type} eq "short") {
  $url = "http://api.wolframalpha.com/v1/result?appid=$private{WAappid}&i=$query";
} elsif ($globopts{type} eq "xml") {
  $url = "http://api.wolframalpha.com/v2/query?appid=$private{WAappid}&input=$query"
} else {
  die("TYPE: $globopts{type} not understood");
}

my($out, $err, $res) = cache_command2("curl -L '$url'", "age=3600");

# for XML trim out plaintext parts (TODO: do other stuff later)

if ($globopts{type} eq "xml") {
  while ($out=~s%<plaintext>(.*?)</plaintext>%%s) {
    print "$1\n";
  }
} elsif ($globopts{type} eq "short") {
  print "$out\n";
} else {
  die("Impossible code point reached");
}

=item comment

URLs that work: (note that 'input=' and 'i=' for different URLs)

Short answers: http://api.wolframalpha.com/v1/result?appid=$private{WAappid}&i=$query

Image answers: http://api.wolframalpha.com/v1/simple?appid=$private{WAappid}&i=$query

Full XML: http://api.wolframalpha.com/v2/query?appid=$private{WAappid}&input=$query

Currently unused examples (from http://products.wolframalpha.com/api/ links):

https://api.wolframalpha.com/v1/spoken?i=Time+in+Buenos+Aires&appid=DEMO

http://api.wolframalpha.com/v1/conversation.jsp?appid=DEMO&i=How+much+does+the+earth+weigh%3f

=cut
