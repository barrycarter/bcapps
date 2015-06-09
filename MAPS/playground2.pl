#!/bin/perl

require "/usr/local/lib/bclib.pl";


my(%res) = mysqlhashlist("SELECT * FROM abqaddresses LIMIT 20", "test");

for $i (keys %res) {
  for $j (keys %{$res{$i}}) {
    debug("$i,$j,$res{$i}{$j}");
  }
}

=item mysqlhashlist($query,$db,$user)

Run $query (should be a SELECT statement) on $db as $user, and return
list of hashes, one for each row

TODO: add error checking

TODO: should return an array, not a hash

=cut

sub mysqlhashlist {
  my($query,$db,$user) = @_;
  unless ($user) {$user="''";}
  my(%res,$row);
  my(@restest);
  chdir(tmpdir());

  write_file($query,"query");
  # TODO: for large resultsets, loading entire output may be bad
  my($out,$err,$res) = cache_command2("mysql -u $user -E $db < query 2> /tmp/err.txt");
  # go through results
  for $i (split(/\n/,$out)) {
    # new row
    if ($i=~/^\*+\s*(\d+)\. row\s*\*+$/) {$row = $1; $restest[$row]={}; next;}
    debug("TEST: $row -> $restest[$row]");
    unless ($i=~/^\s*(.*?):\s*(.*)/) {warn("IGNORING: $_"); next;}
    $restest[$row]->{$1}=$2;
    $res{$row}{$1}=$2;
  }
  debug("RESTEST",@restest);
  return %res;
}

