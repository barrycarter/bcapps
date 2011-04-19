#!/bin/perl

# Attempt to pull my stackexchange questions (not answers) into
# wordpress.barrycarter.info

# NOTE: stack API results are gzip compressed

require "bclib.pl";

# work in my own directory
chdir(tmpdir());

# my WP password <h>(sorry, I can't hardcode it!)</h>
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);

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

    post_to_wp("subject=$qhash{title}&body=BLAH FOR NOW&timestamp=$qhash{creation_date}&category=STACK&live=0");
  }
}

# posts to wordpress.barrycarter.info:
# subject = subject of post
# body = body of post
# timestamp = UNIX timestamp of post
# category = category of post
# live = whether to make post live instantly (default=no)

sub post_to_wp {
  # this function has no pass-by-position parameters
  my($options) = @_;
  my(%opts) = parse_form($options);
  defaults("live=0");

  # fake title for testing
  my($title) = strftime("%Y%m%d.%H%M%S", gmtime(time()));

my($req) =<< "MARK";

<?xml version="1.0"?>
<methodCall> 
<methodName>metaWeblog.newPost</methodName> 
<params> 
<param> 
<value> 
<string>MyBlog</string> 
</value> 
</param> 
<param> 
<value>admin</value> 
</param> 
<param> 
<value> 
<string>$pw</string> 
</value> 
</param> 
<param> 
<struct> 

<member> 
<name>description</name> 
<value>This is a test post. You are best off ignoring it.</value>
</member> 
<member> 
<name>title</name> 
<value>$title</value> 
</member> 
<member> 
<name>dateCreated</name> 
<value>
<dateTime.iso8601>20040716T19:20:30</dateTime.iso8601> 
</value> 
</member> 
</struct> 
</param> 
<param>
 <value>
  <boolean>1</boolean>
 </value>
</param> 
</params> 
</methodCall>
MARK
;

  write_file($req,"request");
  system("curl -o answer --data-binary \@request http://wordpress.barrycarter.info/xmlrpc.php");

  debug($req);
  die "TESTING";
}
