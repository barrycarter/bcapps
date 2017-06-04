#!/bin/perl -w

print "Content-type: text/html\n\n";

# print `date`;
# system("strace 'mkdir -p /var/tmp/cache/00/00'");
# system("date | tee /tmp/out.txt");

# for $i (sort keys %ENV) {
#   print "$i -> $ENV{$i}<br>\n";
# }

# my($out,$err,$res) = cache_command2("mkdir -p /var/tmp/cache/00/00; chmod -f 1777 /var/tmp/cache/00 /var/tmp/cache/00/00");

# my($out,$err,$res) = system("/bin/mkdir -p /var/tmp/cache/00/00");

system("touch /foo/bar.txt /tmp/bar.txt lalal.txt");

system("ls -l /var/tmp");

system("mysql --version");

system("ls -l /");
print `ls -l /`;
print `which touch`;

print `touch /tmp/touchtest2.txt`;
system("touch /tmp/touchtest.txt");

print `whoami`;
print `id`;
# print "OUT: $out\nERR: $err\nRES: $res\n";

die "TESTING";

$globopts{debug} = 1;

$globopts{keeptemp} = 1;

print "ALHPA";

print mysql("SHOW TABLES", "test");

print "BETA";


# TODO: move the to bclib.pl

=item mysql($query,$db,$user="readonly")

Run the query $query on the mysql db $db as user $user and return
results in "raw" format.

TODO: remove the hardcoded 'readonly' before generalizing this function

=cut

sub mysql {
  my($query,$db,$user) = @_;
  unless ($user) {$user = "readonly";}
  my($qfile) = (my_tmpfile2());

  # ugly use of global here
  $SQL_ERROR = "";

  write_file($query,$qfile);
  my($cmd) = "mysql -u $user -E $db < $qfile";
  my($out,$err,$res,$fname) = cache_command2($cmd,"nocache=1");
  debug("ERR: $err");
  # get rid of the row numbers + remove blank first line
  $out=~s/^\*+\s*\d+\. row\s*\*+$//img;
  $out = trim($out);

  if ($res) {
    warnlocal("MYSQL returns $res: $out/$err, CMD: $cmd");
    debug("DB is $db", `pwd`);
    $SQL_ERROR = "$res: $out/$err FROM $cmd";
    return "";
  }
  return $out;
}
