#!/bin/perl

# Given a file (not stream) in the correct format (the output of
# bc-parse-wxr.pl), post it to my blog (or update) using wp-client

# credentials for testing:
# wp --ssh=barrycar@bc4 --path=public_html/wordpress (commands)

require "/usr/local/lib/bclib.pl";

my(%hash);

my($content, $file) = cmdfile();

# split into header and body

my($headers, $body) = split(/======================/, $content);

while ($headers=~s/^(.*?): (.*)$//m) {$hash{$1} = $2;}

# TODO: if id == 0 or new or something, this is a new post and I need
# to update the original file w/ new id

# options to post command

# wp post update <id> --<field>=<value> where:

# trimmed list of categories from
# https://developer.wordpress.org/reference/functions/wp_insert_post/

        'post_author'
        'post_date_gmt'
        'post_content'
        'post_title'
        'post_status'
        'post_type'
        (string) The post type. Default 'post'.
        'comment_status'
        (string) Whether the post can accept comments. Accepts 'open' or 'closed'. Default is the value of 'default_comment_status' option.
        'ping_status'
        (string) Whether the post can accept pings. Accepts 'open' or 'closed'. Default is the value of 'default_ping_status' option.
        'post_password'
        (string) The password to access the post. Default empty.
        'post_name'
        (string) The post name. Default is the sanitized post title when creating a new post.
        'to_ping'
        (string) Space or carriage return-separated list of URLs to ping. Default empty.
        'pinged'
        (string) Space or carriage return-separated list of URLs that have been pinged. Default empty.
        'post_modified'
        (string) The date when the post was last modified. Default is the current time.
        'post_modified_gmt'
        (string) The date when the post was last modified in the GMT timezone. Default is the current time.
        'post_parent'
        (int) Set this for the post it belongs to, if any. Default 0.
        'menu_order'
        (int) The order the post should be displayed in. Default 0.
        'post_mime_type'
        (string) The mime type of the post. Default empty.
        'guid'
        (string) Global Unique ID for referencing the post. Default empty.
        'post_category'
        (array) Array of category names, slugs, or IDs. Defaults to value of the 'default_category' option.
        'tags_input'
        (array) Array of tag names, slugs, or IDs. Default empty.
        'tax_input'
        (array) Array of taxonomy terms keyed by their taxonomy name. Default empty.
        'meta_input'
        (array) Array of post meta values keyed by their post meta key. Default empty.



debug("HASH", %hash);



