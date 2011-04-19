#!/bin/perl

# Attempt to pull my stackexchange questions (not answers) into
# wordpress.barrycarter.info

# NOTE: stack API results are gzip compressed

require "bclib.pl";

# work in my own directory
chdir(tmpdir());

# TODO: cheating and hardcoding this, but could get it from any of my stack ids
$assoc_id = "aa1073f7-7e3b-4d4d-ace5-f2fca853f998";
$apikey = "jm3pC2swyEWCN_sm3BhjTQ";

# find all stack sites (only need this because /associated below does
# NOT give URLs, grumble)

# below won't work when stack grows over 100 sites!
$fname = cache_command("curl 'http://stackauth.com/1.1/sites?page=1&pagesize=100&key=$apikey'","age=86400&retfile=1");

system("gunzip -fc $fname > json0");
$sites = read_file("json0");

# parse..
$json = JSON::from_json($sites);
%jhash = %{$json};
@items = @{$jhash{items}};

# get data I need
for $i (@items) {
  %hash = %{$i};
  %hash2 = %{$hash{main_site}};
  $site{$hash2{name}} = $hash2{api_endpoint};
}

# find all my ids

$fname = cache_command("curl 'http://stackauth.com/1.1/users/$assoc_id/associated?key=$apikey'","age=86400&retfile=1");

# unzip results
system("gunzip -c $fname > json1");
$json = JSON::from_json(read_file("json1"));
%jhash = %{$json};
@items = @{$jhash{items}};

# get data I need (my id on the site)
for $i (@items) {
  %hash = %{$i};

  # TODO: weird case, maybe fix later
  if ($hash{site_name} eq "Area 51") {next;}

  # map URL to id, not name to id
  $myid{$site{$hash{site_name}}} = $hash{user_id};
}

# and now, my questions on all sites
for $i (sort keys %myid) {

  $url = "$i/1.0/users/$myid{$i}/questions";
  # filename for questions for this site
  $i=~m%http://(.*?)/?$%;
  $outname = $1;

  # my questions
  $fname = cache_command("curl '$url'","age=86400&retfile=1");
  system("gunzip -c $fname > $outname");
  $data = read_file($outname);

  # TODO: not sure why this happens
  unless ($data) {next;}

  $json = JSON::from_json($data);
  %jhash = %{$json};
  @questions = @{$jhash{questions}};

  # list of questions
  for $j (@questions) {
    %qhash = %{$j};
    debug($qhash{question_timeline_url}, $qhash{creation_date}, $qhash{title}, $outname);
  }
}

