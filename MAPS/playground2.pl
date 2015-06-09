#!/bin/perl

require "/usr/local/lib/bclib.pl";


debug(mysql("SELECT * FROM abqaddresses LIMIT 20", "test", ""));

# testing mysql subroutine I wrote and hopefully improving it

sub mysql {
  my($query,$db,$user) = @_;
  unless ($user) {$user = "readonly";}
  my($qfile) = (my_tmpfile2());

  # ugly use of global here
  $SQL_ERROR = "";

  write_file($query,$qfile);
  my($cmd) = "mysql -u $user -E $db < $qfile";
  my($out,$err,$res,$fname) = cache_command2($cmd,"nocache=1");
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

