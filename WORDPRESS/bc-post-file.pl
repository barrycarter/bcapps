#!/bin/perl

# Given a file (not stream) in the correct format (the output of
# bc-parse-wxr.pl), post it to my blog (or update) using wp-client

# credentials for testing:
# wp --ssh=barrycar@bc4 --path=public_html/wordpress (commands)

require "/usr/local/lib/bclib.pl";

my(%hash);

# testing only
my($creds) = "--ssh=barrycar\@bc4 --path=public_html/wordpress";

my($content, $file) = cmdfile();

# split into header and body

debug("CONTENT: $content");

my($headers, $body) = split(/^======================+/m, $content);

debug("HEADERS: $headers", "BODY: $body");

die "TESTING";

while ($headers=~s/^(.*?): (.*)$//m) {$hash{$1} = $2;}

# build the options

my(@options);

# TODO: note quoting here can be wonky
for $i (sort keys %hash) {
  if ($i eq "ID") {next;}
  push(@options, "--$i='$hash{$i}'");
}

my($options) = join(" ", @options);

# TODO: cleanup this entire program
my($tmpfile) = my_tmpfile();
debug("TMP: $tmpfile");

# tmpfile has to be on REMOTE site, grrr
write_file($body, $tmpfile);

system("rsync $tmpfile barrycar\@bc4:/tmp/");

# TODO: system -> cache_command
system("wp post update $hash{ID} $tmpfile $options $creds --debug");

debug("ALL DONE");

die "TESTING";


# TODO: if id == 0 or new or something, this is a new post and I need
# to update the original file w/ new id

# TODO: check category validity

# options to post command

# wp post update <id> --<field>=<value> where:


# trimmed list of categories from
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



