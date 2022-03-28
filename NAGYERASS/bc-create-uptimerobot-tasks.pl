#!/bin/perl

# creates uptimerobot tasks after confirming whether they already exist

# Usage: $0 --apikey=apikey (with STDIN as list of lines:

# See bc-create-uptimerobot-tasks-sample.txt for an example

# indicating domain name, MX record, subdomain MX record, A record, more?

# TODO: using mailcontrol.com and dns-lookup.com is sort of cheating,
# would be nice if uptimerobot.com did this on its own

# TODO: consider lowering interval to avoid slamming mailcontrol.com
# and dns-lookup.com

require "/usr/local/lib/bclib.pl";

my($str);

unless ($globopts{apikey}) {die("APIKEY required");}

# obtain a list of existing monitors



while (<>) {

  chomp;

  # ignore comments and empty lines
  if (/^#|^$/) {next;}

  my(%hash) = parse_form($_);

  # fake values to test
  # $hash{domain} = "nodot";

  # TODO: test that certain hash values exist before trying to create monitor

  # create test for A

  $str = "format=json&api_key=$globopts{apikey}&keyword_case_type=0&interval=300&keyword_type=2&timeout=30&url=https://dns-lookup.com/$hash{domain}&friendly_name=$hash{domain}-main-a-record&type=2&keyword_value=$hash{a}";

  # test for subdomain A

  # TODO: using the sha1sum of the domain name as a subdomain is
  # consistent but possibly not "random" enough

  my($subdomain) = sha1_hex($hash{domain});

  $str = "format=json&api_key=$globopts{apikey}&keyword_case_type=0&interval=300&keyword_type=2&timeout=30&url=https://dns-lookup.com/$subdomain.$hash{domain}&friendly_name=$hash{domain}-subdomain-a-record&type=2&keyword_value=$hash{suba}";


    print qq%curl -X POST -H "Cache-Control: no-cache" -H "Content-Type: application/x-www-form-urlencoded" -d "$str" https://api.uptimerobot.com/v2/newMonitor\n%;

#  debug($hash{submx});


}

=item comment

Sample monitor (JSON result), we don't use all these values to create monitor:

         "status" : 2,
         "create_datetime" : 1645312821,
         "keyword_case_type" : 0,
         "interval" : 300,
         "port" : "",
         "keyword_type" : 2,
         "http_username" : "",
         "sub_type" : "",
         "timeout" : 30,
         "http_password" : "",
         "url" : "https://dns-lookup.com/barrycarter.info",
         "id" : 790696086,
         "friendly_name" : "barrydns",
         "type" : 2,
         "keyword_value" : "137.184.87.128"



=cut
