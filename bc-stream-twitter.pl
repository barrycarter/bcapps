#!/bin/perl

# sample app showing twitter streaming

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# what we're looking for
# note: using big locations for testing, will trim
$data = "locations=-107,35,-106,36";

open(A,"curl -s -u $twitter{user}:$twitter{pass} 'https://stream.twitter.com/1/statuses/filter.json?$data'|");

while (<A>) {
  # data is in JSON format
  $json = JSON::from_json($_);
  $str = "[$json->{created_at}] ($json->{id} : $json->{in_reply_to_status_id}) <$json->{user}{screen_name}> $json->{text}";

  $time = strftime("%Y%m%d.%H%M%S", localtime(str2time($json->{created_at})));

  $str = "[$time] <$json->{user}{screen_name}> $json->{text}";
  print "$str\n";

#  debug("TEXT: $json->{text}, $json->{screen_name}, $json->{name}, $json->{id}, $json->{created_at}");
#  debug("RAW: $_");
#  debug("JSON:", unfold($json));
#  debug("VAR:",dump_var(%{$json}));
}
