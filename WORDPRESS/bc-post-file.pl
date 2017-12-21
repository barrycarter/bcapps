#!/bin/perl

# Given a file (not stream) in the correct format (the output of
# bc-parse-wxr.pl), post it to my blog (or update) using wp-client

# credentials for testing:
# wp --ssh=barrycar@bc4 --path=public_html/wordpress (commands)

require "/usr/local/lib/bclib.pl";

my($file, $content) = cmdfile2();

debug("CONTENT: $content");



