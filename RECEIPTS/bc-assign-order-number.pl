#!/bin/perl

# mostly just for me, this updates the 'refnum' field of
# 'credcardstatements2', to be the order number, assuming there is one
# in the text comments

require "/usr/local/lib/bclib.pl";

my(@results) = mysqlhashlist("SELECT * FROM credcardstatements2 WHERE merchant RLIKE 'doordash'", "test", "user");

for $i (@results) {

  # if refnum already exists, ignore it

  if ($i->{refnum} ne "NULL") {next;}

  # check for order number in comment

  debug("COMMENTS: $i->{comments}");

  unless ($i->{comments}=~s%http://www.doordash.com/orders/(\d+)/%%s) {
    debug("NO ORDER NUMBER FOUND: $i->{oid}");
    next;
  }

  # print UPDATE statement
  print "UPDATE credcardstatements2 SET refnum=$1 WHERE oid=$i->{oid};\n";

  debug($i->{refnum});
}
