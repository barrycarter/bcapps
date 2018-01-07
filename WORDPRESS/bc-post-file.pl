#!/bin/perl

# Given a file (not stream) in the correct format (the output of
# bc-parse-wxr.pl), post it to my blog (or update) using wp-client

# NOTE: per https://core.trac.wordpress.org/ticket/38435
# wp_insert_post() does NOT take category slugs despite what the docs
# say

require "/usr/local/lib/bclib.pl";
my($out, $err, $res);

# these are the headers that are parsed separately so
# $options/@options below should ignore them


my(%excluded) = list2hash("ID", "post_category", "post_author");

# TODO: maybe tags and other taxonomy elements too?
# authors and categories: slug => id
my(%auts, %cats);

# testing only (creds= credentials)
# TODO: get from file
my($creds) = "--ssh=barrycar\@bc4 --path=public_html/test20171209.barrycarter.org";

# TODO: subroutinize these

# determine list of categories/authors and cache as long as possible

my(%knowncats) = get_categories();
my(%knownusers) = get_users();

# read file + split into header and body

my($content, $file) = cmdfile();

# TODO: how many equals should I put here?
# NOTE: the "2" below handles the case "=====..." appears in post body
my($headers, $body) = split(/^======================+/m, $content, 2);

# parse header

debug("ZETO");

my(%hash);
while ($headers=~s/^(.*?): (.*)$//m) {$hash{$1} = trim($2);}

debug("ALPHA");

# convert categories and authors to integers or integer list (as string)

my($usedcats) = catlist_to_intlist($hash{post_category});

debug("USED CATS: $usedcats");

die "TETING";

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

# program specific subroutine, no perldoc required

sub get_categories {

  my(%hash);

  # NOTE: uses global variables here
  my($out, $err, $res) = cache_command2("wp $creds term list category --format=csv", "age=+Infinity");

  for $i (split(/\n/, $out)) {
    my($id, $taxid, $name, $slug, $desc, $parent, $count) = csv($i);
    if ($id eq "term_id") {next;}
    $hash{$slug} = $id;
  }
  return %hash;
}

# program specific

sub get_users {

  my(%hash);

  ($out, $err, $res) = cache_command2("wp $creds user list --format=csv", "age=+Infinity");

  for $i (split(/\n/, $out)) {
    my($id, $login, $name, $email, $registered, $roles) = csv($i);
    if ($id eq "ID") {next;}
    $hash{$login} = $id;
  }
  return %hash;
}

# list of categories to list of integers representing those categories

sub catlist_to_intlist {

  debug("ENTERINT");
  my(%hash);
  my($catlist) = @_;

  for $i ($catlist) {

    debug("GOT: $i");

    # using a hash here allows us to ignore duplicates
    if ($cats{$i}) {$hash{$cats{$i}} = 1; next}

    # exiting entire prog here seems weird, does Perl throw exceptions?
    print "\nInvalid category: $i, valid categories are:\n";
    print "\n",join("\n", sort keys %cats),"\n\n";
    exit(1);
  }
  return join(",",sort keys %hash);
}

