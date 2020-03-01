#!/bin/perl

# thin wrapper about Wolfram Alpha API

require "/usr/local/lib/bclib.pl";
require "/home/user/bc-private.pl";

my($query) = urlencode(join(" ",@ARGV));

# TODO: remove caching? 

my($out, $err, $res) = cache_command2("curl -L 'http://api.wolframalpha.com/v1/result?appid=$private{WAappid}&i=$query'", "age=3600");

print "$out\n";

=item comment

URLs that work:

Short answers: http://api.wolframalpha.com/v1/result?appid=$private{WAappid}&i=$query

Image answers: http://api.wolframalpha.com/v1/simple?appid=$private{WAappid}&i=$query

Full XML: http://api.wolframalpha.com/v2/query?appid=$private{WAappid}&i=$query

=cut
