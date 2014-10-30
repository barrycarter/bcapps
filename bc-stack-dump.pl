#!/bin/perl

# starts off as a copy of bc-stack2wp.pl, this attempts to download my
# questions/answers/comments on stack for safekeeping

# NOTE: stack API results are gzip compressed

require "/usr/local/lib/bclib.pl";

# work in my own directory
chdir(tmpdir());

# TODO: cheating and hardcoding this, but could get it from any of my stack ids
$assoc_id = "aa1073f7-7e3b-4d4d-ace5-f2fca853f998";

# find all stack sites (only need this because /associated below does
# NOT give URLs, grumble)

# below won't work when stack grows over 200 sites! (upping pagesize=
# won't help)

for $i (1..2) {
  ($out) = cache_command("curl 'http://api.stackexchange.com/2.2/sites' | gunzip","age=86400");
  $json = JSON::from_json($out);
  %jhash = %{$json};
  debug(var_dump("jhash", {%jhash}));
  push(@items, @{$jhash{items}});
}

# debug("ITEMS",@items);

# get data I need
for $i (@items) {
  %hash = %{$i};
  %hash2 = %{$hash{main_site}};
  debug("HASH",%hash,"HASH2",%hash2);
  $site{$hash2{name}} = $hash2{api_endpoint};
  $site_url{$hash2{api_endpoint}} = $hash2{site_url};
}

# find all my ids (won't work when I'm on more than 100 sites)

my($out, $err, $res) = cache_command2("curl 'http://api.stackexchange.com/2.2/users/$assoc_id/associated' | gunzip","age=86400");

debug("OUT: $out");

die "TESTING";

# warn("Using hardcoded file, since API does not return stack overflow id");
# kludge inside kludge: gunzip won't accept an uncompressed file
# system("gzip -c /home/barrycarter/BCGIT/data/stackcase.txt > stack.gz");
# $fname = "stack.gz";

# get data I need (my id on the site)
for $i (@items) {
  %hash = %{$i};
  debug("HASHALPHGA", %hash);
  debug("MAIN", %{$hash{main_site}});
  debug("HASHXXX",%hash);
  die "TESTING";

  # TODO: weird case, maybe fix later
  if ($hash{site_name} eq "Area 51") {next;}

  debug("SITENAME: $hash{site_name}");

  # map URL to id, not name to id
  debug("HSN: $hash{site_name}, SITE: $site{$hash{site_name}}");
  $myid{$site{$hash{site_name}}} = $hash{user_id};
}

debug("FETA",unfold(%myid));

# and now, my questions on all sites
for $i (sort keys %myid) {
  debug("SITE", $i,$site_url{$i});

  $url = "$i/1.0/users/$myid{$i}/questions";
  # filename for questions for this site
  $i=~m%http://(.*?)/?$%;
  $outname = $1;

  # TODO: handle multiple pages!

  # my questions
  $fname = cache_command("curl '$url'","age=86400&retfile=1");
  system("gunzip -c $fname > $outname");
  $data = read_file($outname);

  debug("<data>$data</data>");

  # TODO: not sure why this happens
  unless ($data) {next;}

  $json = JSON::from_json($data);
  %jhash = %{$json};
  debug("JASH",unfold(\%jhash));
  @questions = @{$jhash{questions}};

  for $j (@questions) {
    %qhash = %{$j};
    debug("QHASH:", unfold($j));

    # question url
    $qurl = "$site_url{$i}$qhash{question_timeline_url}";

    $body = "I posted a question entitled '$qhash{title}' to $outname:<p>
<a href='$qurl'>\n$qurl\n</a><p>Please make all comments/etc on that site, not here.";

    debug("QURL: $qurl");
#    unless ($qurl=~/overflow/i) {
#      warn "KLUDGE TO GET MY OVERFLOW POSTS UPLOAD";
#      next;
#    }

    warn "NOT ACTUALLY POSTING";
#    post_to_wp($body, "site=$wp_blog&author=$author&password=$pw&subject=$qhash{title}&timestamp=$qhash{creation_date}&category=STACK&live=0");

    $qhash{qurl} = $qurl;
    debug("QHASH REF",unfold(\%qhash));
    push(@allquestions, \%qhash);
  }
}

# TODO: accepted_answer_id has vanished somehow

debug("GAMMA");
debug("ALLQ",@allquestions);

unlink("/tmp/stack1.db");
hashlist2sqlite_local(\@allquestions, "questions", "/tmp/stack1.db");

sub hashlist2sqlite_local {
  my($hashs, $tabname, $outfile) = @_;
  my(%iskey);
  my(@queries);

  debug("DELTA", @{$hashs});

  for $i (@{$hashs}) {
    debug("I IS: $i",unfold($i));
    my(@keys,@vals) = ();
    my(%hash) = %{$i};
    for $j (sort keys %hash) {
      $iskey{$j} = 1;
      push(@keys, $j);
      $hash{$j}=~s/\'/''/isg;
      push(@vals, "\'$hash{$j}\'");
    }

    push(@queries, "INSERT INTO $tabname (".join(", ",@keys).") VALUES (".join(", ",@vals).")");
  }

  debug("QUERIES:", @queries);

  # create table and surround block in BEGIN/COMMIT
  unshift(@queries, "CREATE TABLE $tabname (".join(", ",sort keys %iskey).")");
  unshift(@queries, "BEGIN");
  push(@queries, "COMMIT;");

  my($tmpfile) = my_tmpfile();
  debug("TMPFILE: $tmpfile");
  write_file(join(";\n",@queries), $tmpfile);
  system("sqlite3 $outfile < $tmpfile");
}

# TODO: turn off comments for these posts
# TODO: use WP *read* API to confirm no dupes

=item post_to_wp($body, $options)

Posts $body as a new WordPress post with the following options:

  - site: site to post to
  -author: post author
  -password: password for posting
  -subject: subject of post
  -timestamp: UNIX timestamp of post
  -category: category of post
  -live: whether to make post live instantly (default=no)

=cut

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

<param><value><string>thisstringappearstobenecessarybutpointlessinthiscase</string></value></param>

<param><value><string>$opts{author}</string></value></param> 

<param><value><string>$opts{password}</string></value></param>

<param> 
<struct> 

<member><name>categories</name> 
<value><array><data><value>Stack</value></data></array></value> 
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
