#!/bin/perl

# Trivial script to change GET request to POST request so I can do things like:
# #alias 1 #open_url http://el-wiki.net/$0

push(@INC,"/usr/local/lib");
require "bclib.pl";

# headers and base href
print "Content-type: text/html\n\n";
print qq%<base href="http://bots.el-services.net/">\n%;

chdir(tmpdir());

# the query
# nuke everything upto/incl the question mark
$ENV{REQUEST_URI}=~s/^.*?\?//;
# write to file to avoid injection attacks
write_file("action=search&searchname=$ENV{REQUEST_URI}&submit=Search", "post");

system("curl --data-binary \@post http://bots.el-services.net/search.php");

