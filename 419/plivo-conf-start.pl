#!/bin/perl

# this script is run when someone calls my 2nd plivo number (1st plivo
# number gets plivo.php); this script puts them info a conference,
# and, more importantly, calls a whole bunch of other scammers into
# the conference too; hilarity results

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";


print << "MARK";
Content-type: application/xml

<?xml version="1.0" encoding="UTF-8"?>
<Response>
<Speak>Please hold while we connect you</Speak>
<Conference record='true'>419
MARK
;

# this dumps the called numbers into conference 419
$answer_url = "http://sms.barrycarter.info/plivo-conf.php";

for $i (@plivo_list) {
  # randomize caller id per call
  $callerid = int(rand()*(9999999999+1));
# $callerid = "16023549152";

#  $cmd = "curl -u '$plivo_auth_id:$plivo_auth_token' -D /tmp/test.txt -L -d 'from=19999999999&to=$i&answer_url=$answer_url' 'https://api.plivo.com/v1/Account/$plivo_auth_id/Call'";
  $cmd = "curl -k -v -H 'Accept: application/json' -H 'Content-type: application/json' -X POST -d '{\"from\":\"1$callerid\",\"to\":\"$i\",\"answer_url\":\"http://sms.barrycarter.info/plivo-conf.php\"}' https://$plivo_auth_id:$plivo_auth_token\@api.plivo.com/v1/Account/$plivo_auth_id/Call/";
  debug("CMD: $cmd");
  system($cmd);
}

print "</Conference></Response>\n";
