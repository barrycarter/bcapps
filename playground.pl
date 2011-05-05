#!/bin/perl

# Script where I test code snippets; anything that works eventually
# makes it into a library or real program

# chunks are normally separated with 'die "TESTING";'

require "bclib.pl";

@pts = (35.08, -106.66, 48.87, 2.33, 71.26826, -156.80627, -41.2833,
174.783333, -22.88, -43.28);

debug(unfold(voronoi(\@pts)));

die "TESTING";


=item hashlist2sqlite

DOC ME! (but test me first!)

=cut

sub hashlist2sqlite {
  my($hashs, $tabname, $outfile) = @_;
  my(%iskey);
  my(@queries);

  for $i (@{$hashs}) {
    my(@keys,@vals) = ();
    my(%hash) = %{$i};
    for $j (sort keys %hash) {
      $iskey{$j} = 1;
      push(@keys, $j);
      push(@vals, "\"$hash{$j}\"");
    }

    push(@queries, "INSERT INTO $tabname (".join(", ",@keys).") VALUES (".join(", ",@vals).");");
  }

  debug(@queries);
}

exit 1;

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

# $all = read_file("data/sunxyz.txt");

# could try to match newline, but this is easier
$all=~s/\n/ /isg;

# <h>It vaguely annoys me that Perl doesn't require escaping curly braces</h>
while ($all=~s/{([^{}]*?)}/handle($1)/seg) {
  $n++;
  debug("AFTER RUN $n, ALL IS:",$all);
}

debug(*$all);

debug("ALL",$all);

debug("ALL",@{$all});


sub handle {
  my($str) = @_;
  debug("Handling $str");
  return \{split(/\,\s*/, $str)};
  debug("L IS:",@l);
  debug("Returning ". \@l);
  return \@l;
}

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

while ($all=~s/\{([^{}]*?)\}/f($1)/seg) {
  debug("ALL: $all");
}

sub f {
  my($x) = @_;
  return \$x;
}

debug(*$all);

# sub f {return \{split(",",$_[0])};}

# debug(unfold(@res));


die "TESTING";

debug(project(1,0,"mercator",1));


die "TESTING";

# RPC-XML

# get password
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);

# using raw below so i can cache and stuff

$req=<<"MARK";
<?xml version="1.0"?>
<methodCall> 
<methodName>metaWeblog.newPost</methodName> 
<params> 
<param> 
<value> 
<string>MyBlog</string> 
</value> 
</param> 
<param> 
<value>admin</value> 
</param> 
<param> 
<value> 
<string>$pw</string> 
</value> 
</param> 
<param> 
<struct> 

<member> 
<name>description</name> 
<value>Dr. Quest is missing while on an expedition to find the Yeti. Jonny and his friends head to the Himalayas to find him, but run into another scientist who's determined to bring back the Yeti.
</value>
</member> 
<member> 
<name>title</name> 
<value>Expedition To Khumbu</value> 
</member> 
<member> 
<name>dateCreated</name> 
<value>
<dateTime.iso8601>20040716T19:20:30</dateTime.iso8601> 
</value> 
</member> 
</struct> 
</param> 
<param>
 <value>
  <boolean>1</boolean>
 </value>
</param> 
</params> 
</methodCall>
MARK
;

write_file($req,"/tmp/rpc1.txt");
system("curl -o /tmp/rpc2.txt --data-binary \@/tmp/rpc1.txt http://wordpress.barrycarter.info/xmlrpc.php");

die "TESTING";

# reading Mathematica interpolation files

$all = read_file("sample-data/manytables.txt");

while ($all=~s/InterpolatingFunction\[(.*?)\]//s) {
  $func = $1;

  # get rid of pointless domain
  # {} are not special to Perl?!
  $func=~s/{{(.*?)}}//;

  # xvals
  $func=~s/{{(.*?)}}//s;
  $xvals = $1;
  debug("XV: $xvals");

  # split and fix
  @xvals=split(/\,|\n/s, $xvals);

  for $i (@xvals) {
    $i=~s/(.*?)\*\^(\d+)/$1*10**$2/iseg;
  }

  debug($func);

}

