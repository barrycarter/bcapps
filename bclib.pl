# Barry Carter's Perl library (carter.barry@gmail.com)

# required libs
# NOTE: Some people believe you should only 'use' things that the lib
# itself needs, not things that programs calling the lib may
# need. Personally, I just don't care
use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Date::Parse;
use POSIX;
use Text::Unidecode;
use MIME::Base64;
use utf8;
require JSON;

# HACK: defining constants here is probably bad
$PI = 4.*atan(1);
$EARTH_RADIUS = 6371/1.609344; # miles

# HACK: not sure this is right way to do this
our(%globopts);
our(@tmpfiles);

# largest possible path
$ENV{PATH} = "/sw/bin/:/bin/:/usr/bin/:/usr/local/bin/:/usr/X11R6/bin/:$ENV{HOME}/bin:$ENV{HOME}/PERL";

=item list2hash(@list)

Converts @list to a hash where all elements of @list map to 1

=cut

sub list2hash {
  my(@list) = @_;
  my(%hash);
  for $i (@list) {$hash{$i} = 1;}
  return %hash;
}

=item defaults($x)

given a string like "FOO=1&X=BLAH", sets $FOO and $X in globopts hash,
unless they're already set (allows a program to set default options
where user hasn't already set options)

=cut

sub defaults {
  my(%hash) = str2hash($_[0]);

  for $i (sort keys %hash) {
    if (defined($globopts{$i})) {next;}
    $globopts{$i} = $hash{$i};
  }

  # calls parse_options again to do any special processing
  # TODO: could this cause an infinite loop?
  parse_options();
}

=item str2hash($str)

Given $str like x=1&y=2&z=3, return the hash mapping x->1, y->2, z->3

=cut

sub str2hash {
  # TODO: can I combine these into one line (earlier attempt to do so failed)
  my(%hash) = split(/[\&\=]/,$_[0]);
  return %hash;
}

=item parse_options()

Parses things like --foo and --bar=1 on the command line and removes
them from @ARGV

=cut

sub parse_options {

  # find arguments that set options and remove them from ARGV
  my(@x)=grep(/^\-\-[a-z]/i,@ARGV);
  @ARGV=grep(!/^\-\-[a-z]/i,@ARGV);


  for $i (@x){
    # remove the --
    $i=~s/^\-\-//;

    if ($i=~/^(.*?)=(.*)$/) {
      # for cases like --bar=1
      $globopts{$1}=$2;
    } else {
      # if its just --foo, assume --foo=1
      $globopts{$i}=1;
    }
  }
}

=item unfold($ref)

Given a reference to any object, descends into it and returns XML-y
string representation

=cut

sub unfold {
  my(@aa)=@_;
  my(@ac);
  my(%ad);
  
  # if someone sends a list call unfold with a ref to that list
  if ($#aa>0) {return(unfold(\@aa));}

  # it's not a list so only the first element counts
  my($aa)=$aa[0];
  my($ab)=ref($aa);
  if ($ab eq "") {return($aa);}

  # recursively print object (or at least return string to print)
  if ($ab eq "SCALAR") {
    push(@ac,"<scalar $aa>",unfold($$aa),"</scalar $aa>");
  } elsif ($ab eq "ARRAY" || UNIVERSAL::isa($aa,"ARRAY")) {
    push(@ac,"<array $aa>",map(unfold($_),@$aa),"</array $aa>");
  } elsif ($ab eq "HASH" || UNIVERSAL::isa($aa,"HASH")) {
    %ad=%$aa;
    push(@ac,"<hash $aa>");
    for $i (keys %ad) {
      if (!ref($i) && !ref($ad{$i})) {
	push(@ac,"$i: $ad{$i}");
      } else {
	push(@ac,"<key>",unfold($i),"</key>");
	push(@ac,"<val>",unfold($ad{$i}),"</val>");
      }
    }
    push(@ac,"</hash $aa>");
  } elsif ($ab eq "REF") {
    push(@ac,"<ref $aa>",unfold($$aa),"</ref $aa>");
  } else {
    debug("NO CONDITION CAUGHT","AA IS",@aa,"AB: $ab");
  }

  return(join("\n",@ac)."\n");
}

=item debug(@list)

Print list of messages to the standard error, separated by
newlines if --debug given at command line

=cut

sub debug {
  if($globopts{debug}) {
    print STDERR join("\n",@_),"\n";
  }
}

=item dodie($perlcmd)

Try to run Perl code $perlcmd, die if there's an error

=cut

sub dodie {eval($_[0])||die("COMMAND FAILS: $_[0], $!");}


=item cache_command($command, $options)

Runs $command and returns stdout, stderr, and exit status. If command
was run recently, return cached output. $options:

 salt=xyz: store results in file determined by hashing command w/ salt
 retry=n: retry command n times if it fails (returns non-0)
 sleep=n: sleep n seconds between retries
 age=n: if output file is less than n seconds old + no error, return cached
 nocache=1: don't really cache the results (also global --nocache)
 fake=1: don't run the command at all, just say what would be done
 retfile=1: return the filename where output is cached, not output itself
 cachefile=x: use x as cachefile; don't use hash to determine cachefile name
 ignoreerror: assume return code from command is 0, even if it's not

=cut

sub cache_command {
  my($command,$options) = @_;
  my($count,$res);

  # TODO: combine/functionalize next few lines
  my(%defaults) = parse_form("retry=1");
  my(%opts) = parse_form($options);
  for $i (keys %defaults) {
    $opts{$i} = $defaults{$i} unless (exists $opts{$i});
  }

  # TODO: generalize setting specific options from global ones
  if ($globopts{nocache}) {$opts{nocache}=1; $opts{age}=-1;}

  if ($opts{fake}) {
    print "NOT RUNNING: $command\n";
    return;
  }

  # temp file
  my($file) = "/tmp/cache-".sha1_hex("$opts{salt}$command$opts{salt}");
  if ($opts{cachefile}) {$file = $opts{cachefile};}
  my($fileage) = (-M $file)*86400;
  debug("FILE: $file, AGE: $fileage");

  # if file is young enough, return existing values
  if (-f $file && (!read_file("$file.res") || $opts{ignoreerror})
      && ($fileage < $opts{age})) {
    if ($opts{retfile}) {return $file;}
    return (read_file($file), read_file("$file.err"), $res);
  }

  debug("FILE AGE: $opts{age} VS $fileage");

  # run command
  do {
    # if we've run this command already, sleep between runs
    if ($count) {
      debug("Command failed, trying again ($count)");
      sleep($opts{sleep});
    }

    debug("Running command: $command");
    $res = system("($command) 1> $file 2> $file.err");
    $count++;
  } until ($res==0 || $count>$opts{retry} || $opts{ignoreerror});

  # do this so we know if it failed
  write_file($res,"$file.res");

  # if not caching, delete these files when done
  if ($opts{nocache}) {
    debug("PUSHING TO tmpfiles: $file, $file.err, $file.res");
    push(@tmpfiles,$file,"$file.err","$file.res");
  }

  if ($opts{retfile}) {return $file;}
  return (read_file($file), read_file("$file.err"), $res, $file);
}

=item write_file($string, $file)

Write $string to $file

=cut

sub write_file {
  local(*A);
  open(A,">$_[1]")||warnlocal("Can't open $_[1], $!");
  print A $_[0];
  close(A);
}

=item read_file($filename)

Return the entire contents of $filename as a string

=cut

sub read_file {
  # many ways to do this; below not necessarily optimal
  local(*A,$/);
  undef $/;
  open(A,$_[0])||warnlocal("Can't open $_[0], $!");
  my($suck)=<A>;
  close(A);
  return($suck);
}

=item trim($str)

Trims leading/trailing spaces from a string

=cut

sub trim {
    $_[0]=~s/^\s+//isg;
    $_[0]=~s/\s+$//isg;
    return($_[0]);
}

=item min(@list)

Returns minimal item of @list

(not part of POSIX standard?!)

=cut

sub min {
  my($min) = $_[0];
  for $i (@_) {if ($i<$min) {$min=$i;}}
  return $min;
}

=item max(@list)

Returns maximal item of @list

(not part of POSIX standard?!)

=cut

sub max {
  my($max) = $_[0];
  for $i (@_) {if ($i>$max) {$max=$i;}}
  return $max;
}

=item my_tmpfile($prefix="file")

Return a filename in /tmp that is not being used and starts with
$prefix. Appending $$ to filename avoids race condition when forking.

I dislike the regular tmpfile, so use this instead

=cut

sub my_tmpfile {
  my($prefix) = @_;
  unless ($prefix) {$prefix="file";}
  my($x)=rand();
  while (-f "/tmp/$prefix$x$$") {$x=rand();}
  push(@tmpfiles, "/tmp/$prefix$x$$");
  return("/tmp/$prefix$x$$");
}

=item sqlite3($query,$db)

Run the query $query on the sqlite3 db (file) $db and return results
in raw format.

<h>Modules, who needs 'em!</h>

=cut

sub sqlite3 {
  my($query,$db) = @_;
  my($qfile) = (my_tmpfile("sqlite"));

  # ugly use of global here
  $SQL_ERROR = "";

  # if $query doesnt have ;, add it, unless it starts with .
  unless ($query=~/^\./ || $query=~/\;$/) {$query="$query;";}
  write_file($query,$qfile);
  my($cmd) = "sqlite3 -batch -line $db < $qfile";
  my($out,$err,$res,$fname) = cache_command($cmd,"nocache=1");

  if ($res) {
    warnlocal("SQLITE3 returns $res: $out/$err, CMD: $cmd");
    $SQL_ERROR = "$res: $out/$err FROM $cmd";
    return "";
  }
  return $out;
}

=item sqlite3hashlist($query,$db)

Returns a list of hashes representing the results of $query on $db

=cut

sub sqlite3hashlist {
  my($query,$db) = @_;
  my($raw) = sqlite3($query,$db);
  my($hashref) = {};
  my(@res) = ();
  my($count) = 0;
  my($cur);

  # KLUDGE: for empty case
  unless ($raw) {return @res;}

  for $i (split("\n",$raw)) {
    # standard column=val line
    if ($i=~/^\s*(.*?)\s+\=\s+(.*)$/) {
      $cur=$1;
      $$hashref{$cur}=$2;
      next;
    }

    # blank line between results
    if ($i=~/^\s*$/) {
      push(@res,$hashref);
      $hashref = {};
      next;
    }

    # continuation line
    $$hashref{$cur}.=$i;
  }

  push(@res,$hashref); # the last one
  return @res;
}

=item sqlite3val($query,$db)

For queries that return a single row/column, return that row/column

=cut

sub sqlite3val {
  my($query,$db) = @_;
  my(@res) = sqlite3hashlist($query,$db);
  # TODO: if I were really clever, I could combine the two lines below!
  my(@temp) = values %{$res[0]};
  return $temp[0];
}

=item sqlite3cols($tabname,$db)

Return a hash mapping columns in tabname to their "type"

=cut

sub sqlite3cols {
  my($tabname,$db) = @_;
  my($raw) = sqlite3(".schema $tabname",$db);
  my(%ret);

  unless ($raw=~/create table $tabname \((.*?)\)/is) {
    warnlocal("Schema return value not understood");
    return;
  }

  my($schema) = $1;

  for $i (split(/\,/,$schema)) {
    $i=~/^\s*(.*?)\s+(.*)$/||warnlocal("BAD SCHEMA LINE: $i");
    $ret{$1}=$2;
  }
  
  return %ret;
}

=item webdie($str)

The die() command doesn't work well for CGI; this is die for CGI scripts

=cut

sub webdie {
  my($str) = @_;
  print "<p>ERROR: $str<p>\n";
  # exiting w/ 0 to avoid confusing lighttpd
  exit(0);
}

=item cmdfile()

Return contents and name of first command-line argument to program
(not argument to function). Complains if program is called sans
argument

=cut

sub cmdfile {
    my($f)=$ARGV[0]||die("Usage: $0 [options] <filename>");
    if ($#ARGV>=1) {
      die("Usage: $0 [options] <filename>; multiple files ignored, use xargs -n 1");
    }
    unless (-f $f) {die("NO SUCH FILE: $f");}
    unless (-r $f) {die("NO READ PERM: $f");}
    return(read_file($f),$f);
}

=item tmpdir($prefix="file")

Create and return a directory in /tmp that is not being used and
starts with $prefix.

NOTE: Appending $$ to filename below avoids race condition when forking.

=cut

sub tmpdir {
  my($prefix) = @_;
  unless ($prefix) {$prefix="dir";}
  my(@lets)=("a".."z","A".."z","0".."9");
  my(@file);
  my($file);

  do {
    for $i (1..16) {
      my($rand) = rand($#lets);
      push(@file, $lets[$rand]);
    }
    $file = "/tmp/$prefix-".join("",@file)."-$$";
    } until (!(-f $file));

  mkdir($file);
  push(@tmpdirs, $file);
  return($file);
}

=item warnlocal(@msgs)

Localized version of warn() in case I want to overwrite it. Individual
scripts can further overwrite this. This version just does warn()
unless --nowarn is set

=cut

sub warnlocal {
  unless ($globopts{nowarn}) {warn(join("\n",@_));}
}

=item gcddist($x,$y,$u,$v)

Great circle distance between latitude/longitude x,y and
latitude/longitude u,v in miles Source: http://williams.best.vwh.net/avform.htm

=cut

sub gcdist {
    my(@x)=@_;
    my($x,$y,$u,$v)=map {$_*=$PI/180} @x;
    my($c1) = cos($x)*cos($y)*cos($u)*cos($v);
    my($c2) = cos($x)*sin($y)*cos($u)*sin($v);
    my($c3) = sin($x)*sin($u);
    return ($EARTH_RADIUS*acos($c1+$c2+$c3));
}

=item hsv2rgb($hue,$sat,$val, $options)

Given hue, saturation, and value of a color, convert to RGB using *my
own formula* which is not necessarily the "correct" formula. $options:

kml: output in KML format (aabbggrr) not HTML (rrggbb)
opacity: for KML, the opacity in hex format

=cut

sub hsv2rgb {
  my($hue,$sat,$val,$options) = @_;
  my(%opts) = parse_form($options);
  $hue=$hue-floor($hue);
  $hv=floor($hue*6);

  # can't get given/when to work, so...
  if ($hv==0) {$r=1; $g=6*$hue; $b=0;} elsif
    ($hv==1) {$r=2-6*$hue; $g=1; $b=0;} elsif
    ($hv==2) {$r=0; $g=1; $b=6*$hue-2;} elsif
    ($hv==3) {$r=0; $g=4-6*$hue; $b=1;} elsif
    ($hv==4) {$r=6*$hue-4; $g=0; $b=1;} elsif
    ($hv==5) {$r=1; $g=0; $b=6-6*$hue;} else
      {$r=0; $g=0; $b=0;}
  debug("HSV: $hue -> $r $g $b");
  $r=min($r+1-$sat,1)*$val;
  $g=min($g+1-$sat,1)*$val;
  $b=min($b+1-$sat,1)*$val;

  if ($opts{kml}) {
    return sprintf("#$opts{opacity}%0.2x%0.2x%0.2x",$b*255,$g*255,$r*255);
  } else {
    return sprintf("#%0.2x%0.2x%0.2x",$r*255,$g*255,$b*255);
  }
}

# cleanup files created by my_tmpfile (unless --keeptemp set)

sub END {
  local $?;
  if ($globopts{keeptemp}) {return;}

  for $i (@tmpfiles) {
    debug("DELETING: $i");
    unlink($i);
  }

  for $i (@tmpdirs) {
    debug("RM -R: $i");
    system("rm -r $i");
  }
}

# parse_form = alias for str2hash (but some of my code uses it)
sub parse_form {return str2hash(@_);}

# suck = alias for read_file (I was young and foolish...)
sub suck {return read_file(@_);}

# automatically call parse_options (don't expect calling prog to do this)
&parse_options;

1;
