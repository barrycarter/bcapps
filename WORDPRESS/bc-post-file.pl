#!/bin/perl

# Given a file (not stream) in the correct format (the output of
# bc-parse-wxr.pl), post it to my blog (or update) using wp-client

# credentials for testing:
# wp --ssh=barrycar@bc4 --path=public_html/wordpress (commands)

# NOTE: per https://core.trac.wordpress.org/ticket/38435
# wp_insert_post() does NOT take category slugs despite what the docs
# say

require "/usr/local/lib/bclib.pl";
my($out, $err, $res);

# these are the headers that are parsed separately so
# $options/@options below should ignore them

my(%excluded) = list2hash("ID", "post_category", "post_author");

# TODO: maybe tags too?

# authors and categories: slug => id
my(%auts);
my(%cats);

# testing only (creds= credentials)
# TODO: get from file
my($creds) = "--ssh=barrycar\@bc4 --path=public_html/test20171209.barrycarter.org";

# TODO: subroutinize these

# determine list of categories/authors and cache as long as possible

($out, $err, $res) = cache_command2("wp $creds term list category --format=csv", "age=+Infinity");

for $i (split(/\n/, $out)) {
  my(@l) = csv($i);
  # TODO: this is ugly, should really comment or explain assumed headers
  $cats{$l[3]} = $l[0];
}

# this is to kill off the header entry
delete $cats{"slug"};

($out, $err, $res) = cache_command2("wp $creds user list --format=csv", "age=+Infinity");

for $i (split(/\n/, $out)) {
  my(@l) = csv($i);
  # TODO: this is ugly, should really comment or explain assumed headers
  $auts{$l[1]} = $l[0];
}

# TODO: this is seriously ugly, I can probably use shift or something
# above to avoid this

delete $auts{"user_login"};

debug("CAT", %cats, "AUT", %auts);

# read file + split into header and body

my($content, $file) = cmdfile();

# TODO: how many equals should I put here?
# NOTE: the "2" below handles the case "=====..." appears in post body
my($headers, $body) = split(/^======================+/m, $content, 2);

# parse header

my(%hash);
while ($headers=~s/^(.*?): (.*)$//m) {$hash{$1} = trim($2);}

# convert categories and authors to integers

my(@cats);

for $i (csv($hash{post_category})) {
  # trim and lower case
  $i = trim($i);
  $i = lc($i);
  if ($cats{$i}) {push(@cats,$cats{$i}); next}

  print "\nInvalid category: $i, valid categories are:\n";
  print "\n",join("\n", sort keys %cats),"\n\n";
  exit(1);
}

my($cats) = join(",", @cats);

# and now, author (singular)
# TODO: this seems really redundant and ugly

my($author);

# TODO: allow empty author

# TODO: confirm empty cats is ok

if ($hash{post_author}) {

  $author=$auts{$hash{post_author}};

  unless ($author) {
    print "\nInvalid author: $hash{post_author}, valid authors are:\n";
    print "\n",join("\n", sort keys %auts),"\n\n";
    exit(1);
  }
}

# build the options

my(@options);

# special case for post_category and post_author

if (@cats) {push(@options, "--post_category=".join(",",@cats));}

if ($author) {push(@options, "--post_author=$author");}

for $i (sort keys %hash) {
  if ($excluded{$i}) {next;}
  if ($hash{$i}=~/^\s*$/) {next;}
  debug("$i -> $hash{$i}");
  push(@options, "--$i='$hash{$i}'");
}

my($options) = join(" ", @options);

# the remote tmp file will be /tmp not /var/tmp/xx/xx

my($tmpfile) = my_tmpfile2();
my($remotetmp) = $tmpfile;
$remotetmp=~s%^.*/%/tmp/%;
write_file($body, $tmpfile);

# special case for new posts

my($postcommand) = $hash{ID}=~/^\d+/?"update $hash{ID}":"create";

debug("CMD:  post $postcommand $remotetmp $options $creds --debug");

die "TESTING";

# rsync the file over
# TODO: consider removing the tmp files I'm creating remotely

($out, $err, $res) = cache_command2("rsync $tmpfile barrycar\@bc4:$remotetmp");

($out, $err, $res) = cache_command2("wp post $postcommand $remotetmp $options $creds --debug");

debug("OUT: $out", "ERR: $err");

# TODO: if new post created, update input file w/ new ID


# TODO: check category validity

# options to post command

# wp post update <id> --<field>=<value> where:

# trimmed list of fields from
# https://developer.wordpress.org/reference/functions/wp_insert_post/

=item comment
        'post_author'
        'post_date_gmt'
        'post_content'
        'post_title'
        'post_status'
        'post_type'
        'post_name'
        'post_category'
        'tags_input'
        'tax_input'
=cut



debug("HASH", %hash);
