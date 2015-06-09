#!/bin/perl

require "/usr/local/lib/bclib.pl";


my(@res) = mysqlhashlist("SELECT * FROM abqaddresses LIMIT 20", "test");

for $i (@res) {
  for $j (keys %$i) {
    debug("$i,$j,$i->{$j}");
  }
}

=item mysqlhashlist($query,$db,$user)

Run $query (should be a SELECT statement) on $db as $user, and return
list of hashes, one for each row

NOTE: return array first index is 1, not 0

TODO: add error checking

=cut

sub mysqlhashlist {
  my($query,$db,$user) = @_;
  unless ($user) {$user="''";}
  my(@res,$row);
  chdir(tmpdir());

  write_file($query,"query");
  # TODO: for large resultsets, loading entire output may be bad
  my($out,$err,$res) = cache_command2("mysql -u $user -E $db < query 2> /tmp/err.txt");
  # go through results
  for $i (split(/\n/,$out)) {
    # new row
    if ($i=~/^\*+\s*(\d+)\. row\s*\*+$/) {$row = $1; $res[$row]={}; next;}
    unless ($i=~/^\s*(.*?):\s*(.*)/) {warn("IGNORING: $_"); next;}
    $res[$row]->{$1}=$2;
  }
  return @res;
}

