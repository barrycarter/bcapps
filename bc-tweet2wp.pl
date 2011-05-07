#!/bin/perl

# convert tweet stream to WP posts (similar to bc-stack2wp.pl)
# --fake: don't actually post anything

require "bclib.pl";

# blog vars
# my WP password <h>(sorry, I can't hardcode it!)</h>
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);
# my name <h>(I'm OK with hardcoding this)</h>
$author = "barrycarter";
# my wordpress blog
$wp_blog = "wordpress.barrycarter.info";

# read entire twitter stream
$tweets = read_file("data/tweets-so-far.txt");

while ($tweets=~s%<status>(.*?)</status>%%s) {
  $tweet = $1;

  # create hash (imperfect, but good enough for our purposes)
  %hash = ();
  while ($tweet=~s%<(.*?)>(.*?)</\1>%%s) {$hash{$1}=$2;}

  $body = $hash{text};
  $time = str2time($hash{created_at});
  debug("TIME: $time");

  # send data to post_to_wp (after minor formatting cleanup)
  post_to_wp($body, "site=$wp_blog&author=$author&password=$pw&subject=$hash{text}&timestamp=$time&category=TWITTERTEST&live=0");

}

# TODO: clean this up + add it to bclib.pl
# TODO: turn off comments for these posts
# TODO: use WP *read* API to confirm no dupes
# post_to_wp($body, $options)
# site = site to post to
# author = post author
# password = password for posting
# subject = subject of post
# timestamp = UNIX timestamp of post
# category = category of post
# live = whether to make post live instantly (default=no)

sub post_to_wp {
  # this function has no pass-by-position parameters
  my($body, $options) = @_;
  my(%opts) = parse_form($options);
  defaults("live=0");

  # timestamp (in ISO8601 format)
  my($timestamp) = strftime("%Y%m%dT%H:%M:%S", gmtime($opts{timestamp}));

my($req) =<< "MARK";

<?xml version="1.0"?>
<methodCall> 
<methodName>metaWeblog.newPost</methodName> 
<params>

<param><value><string>why_do_i_need_this</string></value></param>

<param><value><string>$opts{author}</string></value></param> 

<param><value><string>$opts{password}</string></value></param>

<param> 
<struct> 

<member><name>categories</name> 
<value><array><data><value>$opts{category}</value></data></array></value> 
</member> 

<member>
<name>description</name> 
<value><string><![CDATA[$body]]></string></value>
</member> 

<member> 
<name>title</name> 
<value>$opts{subject}</value> 
</member> 

<member> 
<name>dateCreated</name> 
<value>
<dateTime.iso8601>$timestamp</dateTime.iso8601> 
</value> 
</member> 

</struct> 
</param> 

<param><value><boolean>$live</boolean></value></param> 

</params></methodCall>
MARK
;

  write_file($req,"request");
  debug($req);

  if ($globopts{fake}) {return;}

  # curl sometimes sends 'Expect: 100-continue' which WP doesn't like.
  # The -H 'Expect:' below that cancels this
  system("curl -H 'Expect:' -o answer --data-binary \@request http://$opts{site}/xmlrpc.php");

  debug($req);

  debug(read_file("answer"));
}
