# Barry Carter's Perl library (carter.barry@gmail.com)

# per http://alvinalexander.com/perl/edu/articles/pl010015/ include
# all paths that Perl can possibly use, assuming they actually exist

# not actually done

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
use Statistics::Distributions qw(uprob udistr);
use Math::Round;
use Data::Dumper 'Dumper';
use B;

use Astro::Nova qw(get_solar_equ_coords get_lunar_equ_coords get_hrz_from_equ
		   get_solar_rst_horizon get_timet_from_julian
		   get_julian_from_timet get_lunar_rst get_lunar_phase
		   get_apparent_sidereal_time get_mars_equ_coords
		   get_ecl_from_equ);
use Astro::MoonPhase qw(phase phasehunt);
require JSON;

# include sublibs
push(@INC,"/home/user/BCGIT", "/usr/local/lib");

# for X11 goodness (when starting Perl from nagios/cron or similar)
$ENV{'DISPLAY'}=":0.0";

# lets people use different home dirs
our($homedir) = "/home/user";

# git home (and other bclib hash vars)
$bclib{githome} = "/home/user/BCGIT";
$bclib{home} = "/home/user";
$bclib{extdrive} = "/mnt/extdrive";

# where I keep private information that my code can use
$bclib{privdir} = "/home/user/BCPRIV";

# TODO: sort of bad to call this "abbrev" in global lib
our(%ABBREV)=("BC" => lc("Patches"),
	 "BL" => lc("Blowing"),
	 "DR" => lc("Low Drifting"),
	 "FZ" => lc("Supercooled/freezing"),
	 "MI" => lc("Shallow"),
	 "PR" => lc("Partial"),
	 "SH" => lc("Showers"),
	 "TS" => lc("Thunderstorm"),
	 "BR" => lc("Mist"),
	 "DS" => lc("Dust Storm"),
	 "DU" => lc("Widespread Dust"),
	 "DZ" => lc("Drizzle"),
	 "FC" => lc("Funnel Cloud"),
	 "FG" => lc("Fog"),
	 "FU" => lc("Smoke"),
	 "GR" => lc("Hail"),
	 "GS" => lc("Small Hail/Snow Pellets"),
	 "HZ" => lc("Haze"),
	 "IC" => lc("Ice Crystals"),
	 "PL" => lc("Ice Pellets"),
	 "PO" => lc("Dust/Sand Whirls"),
	 "PY" => lc("Spray"),
	 "RA" => lc("Rain"),
	 "SA" => lc("Sand"),
	 "SG" => lc("Snow Grains"),
	 "SN" => lc("Snow"),
	 "SQ" => lc("Squall"),
	 "SS" => lc("Sandstorm"),
	 "UP" => lc("Unknown Precipitation (Automated Observations)"),
	 "VA" => lc("Volcanic Ash")
	);

our($abbrevs)= lc(join("|",sort keys %ABBREV));

# HACK: defining constants here is probably bad

# TODO: consider putting them in a bclib hash or something

$PI = 4.*atan(1);
$DEGRAD=$PI/180; # degrees to radians
$RADDEG=180./$PI; # radians to degrees
$EARTH_RADIUS = 6371/1.609344; # miles

our($MIPERKM) = 1.609344; # miles per kilometer
our($SPEEDOFLIGHT) = 299792458; # meters per second

our($DEGRAD)=$PI/180; # degrees to radians
our($RADDEG)=180/$PI; # radians to degrees
our($HOURRAD)=$PI/12; # hours to radians
our($RADHOUR)=12/$PI; # radians to hours
our($DEGHOUR)=1/15; # degrees to hours
our($HOURDEG)=15; # hours to degrees

our($DAYSPERMONTH) = 365.2425/12;

# this might be a bad idea
our($now) = time();

# note month 0 is blank intentionally
our(@months) = ("", "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December");

# directionsforme.org values I want

our(%d4mekeys) = list2hash("file", "Name", "Manufacturer", "UPC", "url",
"caffeine", "calcium", "cholesterol", "dietaryfiber", "iron",
"monounsaturatedfat", "potassium", "protein", "saturatedfat", "serving size", "servings per container", "sodium", "sugars",
"totalcarbohydrate", "totalfat", "transfat", "vitamina", "vitaminc",
"vitamind", "vitamine", "vitamink", "weight", "servingsize_prepared",
"servingsizeingrams", "calories");

# this key is NOT private because it shows up in URLs, so it's ok to
# put it here; it is protected by referer, however (not that this is
# perfect)

# our($google_maps_key) = "AIzaSyCC5urLnHN5DKVEZti8umw5k2d_-OsHDMo";
our($google_maps_key) = "AIzaSyAGL_Xc8z1fTp8Na-stxE9u8ihnjEbkbbA";

# HACK: not sure this is right way to do this
our(%globopts);
our(%is_tempfile);
our(%shared);

our(@globopts) = ("debug", "nocache", "tmpdir", "nowarn", "fake", "ignorelock",
		  "affirm", "keeptemp", "xmessage", "bgend", "filedebug");

# global options this library supports

$bclib{options_supported} = << "MARK";
--debug: print debugging messages
--filedebug=file: send debugging messages to file, not STDERR
--nocache: do not cache results
--tmpdir=x: use x as temporary directory when needed
--nowarn: if using warnlocal(), suppress warnings
--fake: do not actually post to WP, just fake it
--ignorelock: ignore any locks held by mylock()
--affirm: assume affirmative responses to anything affirm() asks
--keeptemp: keep temporary files
--xmessage: pop up xmessage when program ends
--bgend: write to background image when program ends
--nodetach: don't detach from the terminal even if program normally would
--zombie: run program even if its marked obsolete (DANGEROUS!)
--help: show help on program, don't run it
MARK
;

# largest possible path (really?)

# TODO: let .tcshrc set this
# TODO: adding BCGIT to this = really kludgey
$ENV{PATH} = "/sbin:/opt/metaf2xml/bin/:/sw/bin/:/bin/:/usr/bin/:/usr/local/bin/:/usr/X11R6/bin/:/usr/lib/nagios/plugins:/usr/lib:/usr/sbin/:$ENV{HOME}/bin:$ENV{HOME}/PERL:/usr/lib64/nagios/plugins/:$bclib{githome}:$bclib{githome}/*";

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

=item str2hashref(str)

Does what str2hash does, but returns a reference to a hash

=cut

sub str2hashref {
  my($string) = @_;
  my(%hash) = parse_form($string);
  return \%hash;
}

=item parse_options()

Parses things like --foo and --bar=1 on the command line and removes
them from @ARGV

=cut

sub parse_options {

  # find old style options, convert, warn politely
  # Yes, I realize this blocks args that actually start with -[a-z]
  for $i (@ARGV) {
    if ($i=~s/^-([a-z])/--$1/) {
      warnlocal("Added - to $i");
    }
  }

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
  my($err) = join("\n",@_)."\n";

  # TODO: appending to file each line is inefficient
  if ($globopts{filedebug}) {append_file($err, $globopts{filedebug});}

  # note that both filedebug and debug can be used at the same time
  if($globopts{debug}) {print STDERR $err;}
  return @_;
}

=item webug(@list)

Print debugging messages "Web style" if --debug given at command line

=cut

sub webug {
  if($globopts{debug}) {
    print STDOUT "<p><b>",join("\n",@_),"</b></p>\n";
  }
}

=item dodie($perlcmd)

Try to run Perl code $perlcmd, die if theres an error

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
  # HACK: shouldn't have to do this
  if ($fileage < 0) {$fileage=0;}
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
  if ($opts{nocache}) {$is_tempfile{$file}=1;}

  if ($opts{retfile}) {return $file;}
  return (read_file($file), read_file("$file.err"), $res, $file);
}

=item write_file($string, $file)

Write $string to $file

=cut

sub write_file {
  my($string, $file) = @_;
  local(*A);

  # this may be a terrible idea (creating directory if doesnt exist)
  my($dir) = $file;
  if ($dir=~s/\/[^\/]+?$//isg) {
    unless (-d $dir) {system("mkdir -p $dir");}
  }

  # TODO: return fail value if file cant be written
  # quoting file name to be safe
  open(A, ">$file")||warnlocal("WRITE_FILE() can't open $file, $!");
  print A $string;
  close(A)||warnlocal("WRITE_FILE() can't close $file, $!");
}

=item write_file_new($string, $file, $options)

Write $string to $file.new, then move $file to $file.old and $file.new
to $file (so that $file is never unreadable?). Options:

diff=1: compare the new file and the existing file and do not
overwrite if they are already identical (useful for preserving
timestamps)

TODO: make this fail gracefully if .new cant be written

TODO: allow for .new file to be in a different (temp?) directory in
case writing files to current directory is bad idea

TODO: This wont work for files that have quotation marks, but those
are hopefully rare

=cut

sub write_file_new {
  my($string, $file, $options) = @_;
  my(%opts) = parse_form($options);
  debug("WRITING STRING to $file.new");
  write_file($string,"$file.new");
  debug("DONE WRITING STRING TO $file.new");
  if ($opts{diff}) {
#    my($res) = system("cmp \"$file\" \"$file.new\" 1> /tmp/cmp.out 2> /tmp/cmp.err");
    debug("APPLYING DIFF($file)");
    my($out,$err,$res) = cache_command2("cmp \"$file\" \"$file.new\" 1> /tmp/cmp.out 2> /tmp/cmp.err", "nocache=1");
    debug("OUT: $out, ERR: $err, RES: $res");
    unless ($res) {
      debug("$file and $file.new already identical");
      system("rm \"$file.new\"");
      return;
    }

    debug("$file and $file.new different, overwriting");
  }
  system("mv \"$file\" \"$file.old\"; mv \"$file.new\" \"$file\"");
}

=item append_file($string, $file)

Append $string to $file

=cut

sub append_file {
  local(*A);
  open(A,">>$_[1]")||warnlocal("Can't open $_[1], $!");
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
  my($str) = @_;
  $str=~s/^\s+//isg;
  $str=~s/\s+$//isg;
  return $str;
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
  $is_tempfile{"/tmp/$prefix$x$$"} = 1;
  return("/tmp/$prefix$x$$");
}

=item sqlite3($query,$db)

Run the query $query on the sqlite3 db (file) $db and return results
in raw format.

<h>Modules, who needs \'em!</h>

=cut

sub sqlite3 {
  my($query,$db) = @_;
  my($qfile) = (my_tmpfile2());

  # ugly use of global here
  $SQL_ERROR = "";

 # if $query doesnt have ;, add it, unless it starts with .
  unless ($query=~/^\./ || $query=~/\;$/) {$query="$query;";}
  debug("WROTE: $query to $qfile");
  # adding timeout because cronned jobs tend to fight over db
  write_file(".timeout 15\n$query",$qfile);
  my($cmd) = "sqlite3 -batch -line $db < $qfile";
  my($out,$err,$res,$fname) = cache_command2($cmd,"nocache=1");
#  debug("OUT: $out, ERR: $err, RES: $res, FNAME: $fname");

  if ($res) {
    warnlocal("SQLITE3 returns $res: $out/$err, CMD: $cmd");
    debug("DB is $db", `pwd`);
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
  debug("QUERY: $query, DB: $db");
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

  unless ($raw=~/create table $tabname \((.*?)\)\;/is) {
    warnlocal("Schema return value not understood: $raw");
    return;
  }

  my($schema) = $1;

  for $i (split(/\,/,$schema)) {
    # kill extraneous spaces and apos
    $i = trim($i);
#    debug("I: $i");

    if ($i=~/\'(.*?)\'/) {
      # special case for apostrophe quoted cols with no type
      $ret{$1} = "null";
    } elsif ($i=~/^\s*(.*?)\s+(.*)$/) {
    # for cols w/ types
#      debug("$1 -> $2");
      $ret{$1} = $2;
    } elsif ($i=~/^\s*(\S*?)$/) {
#      debug("$1 -> null");
      $ret{$1} = "null";
    } else {
      warnlocal("BAD SCHEMA LINE: $i");
    }
  }
  
  return %ret;
}

=item webdie($str,$header)

The die() command doesn\'t work well for CGI; this is die for CGI scripts

If $header given, print it as a header (otherwise, assume calling
program has printed header)

=cut

sub webdie {
  my($str,$header) = @_;
  if ($header) {print "$header\n\n";}
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
      die("Usage: $0 [options] <filename>; multiple files ignored, use xargs -n 1; files given: @ARGV");
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
  # if we already have a tmpdir (perhaps passed as --tmpdir=), use it
  if ($globopts{tmpdir}) {return $globopts{tmpdir};}

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
  $istmpdir{$file} = 1;
  # only create one tmpdir per program: lets subroutines call tmpdir w/o
  # fear of cluttering up /tmp
  $globopts{tmpdir} = $file;
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

=item gcdist($x,$y,$u,$v)

Great circle distance between latitude/longitude x,y and
latitude/longitude u,v in miles; given coordinates must be in degrees

Source: http://williams.best.vwh.net/avform.htm

=cut

sub gcdist {
    my(@x)=@_;
#    debug("GCDIST GOT:",@x);
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

format=decimal: return as integers

=cut

sub hsv2rgb {
  my($hue,$sat,$val,$options) = @_;
  my($r,$g,$b);
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
  } elsif ($opts{format} eq "decimal") {
    return sprintf("%0.2d,%0.2d,%0.2d",$r*255,$g*255,$b*255);
  } else {
    return sprintf("#%0.2x%0.2x%0.2x",$r*255,$g*255,$b*255);
  }
}

=item mod($x,$y)

Returns $x modulo $y, neither has to be an integer

=cut

sub mod {
  my($x,$y) = @_;
  return $x-$y*floor($x/$y);
}

=item urlencode($str)

URL encodes $str

=cut

sub urlencode {
  my($str) = @_;
  $str=~s/([^a-zA-Z0-9])/"%".unpack("H2",$1)/iseg;
  $str=~s/ /\+/isg;
  return $str;
}

=item sph2xyz($theta,$phi,$r, $options)

Converts spherical ($theta,$phi,$r) to Cartesian ($x,$y,$z)

degrees=1: assume theta and phi are in degrees, not radians

=cut

sub sph2xyz {
  my($th,$ph,$r,$options)=@_;
  my(%opts) = parse_form($options);
  if ($opts{degrees}) {$th=$th*$DEGRAD; $ph=$ph*$DEGRAD;}
  return($r*cos($ph)*cos($th),$r*cos($ph)*sin($th),$r*sin($ph));
}


=item xyz2sph($x,$y,$z,$options)

Converts ($x,$y,$z) to spherical coordinates ($theta,$phi,$r). Options:

 degrees=1: return $th and $phi in degrees, not radians


(unless $deg set, in which case returns degrees)

=cut

sub xyz2sph {
    my($x,$y,$z,$options)=@_;
#    debug("XYZ: $x $y $z");
    my(%opts) = parse_form($options);
    my(@ret)=(atan2($y,$x),atan2($z,sqrt($x*$x+$y*$y)),
	      sqrt($x*$x+$y*$y+$z*$z));
    # normalize
    if ($ret[0]<0) {$ret[0]+=2*$PI;}
    if ($opts{degrees}) {$ret[0]/=$DEGRAD; $ret[1]/=$DEGRAD;}
    return(@ret);
}

=item voronoi(\@points, $options)

Returns the Voronoi tesselation (in polygons) for a list of 2-D
points. The list must be passed by reference, and is actually a 1-D
list where each 2 element pair is treated like a 2-element list.

This subroutine is a thin wrapper around qhull, and just
subroutine-ifys what I have already done in bc-temperature-voronoi.pl

Options:
 infinityok: include polygons with points at infinity (not working)
 infinityclip: include polygons w/ pts at infinity, but remove infinity points
 default: ignore polygons w/ pts at infinity

=cut

sub voronoi {
  # TODO: @pts is really a 2-D array, but we pass it as a 1-D array (bad?)
  my($pts, $options) = @_;
  my(@pts) = @{$pts};
  my(%opts) = parse_form($options);
  my(@ret) = ();
  # TODO: this dir goes away at end of prog, not end of subroutine (bad?)
  chdir(tmpdir());

  # put points into input file
  # TODO: below seems tedious; shorter way to do this?
  local(*A);
  open(A,">points");
  print A "2\n";
  print A ($#pts+1)/2 ."\n";
  for ($i=0; $i<=$#pts; $i+=2) {
    print A "$pts[$i] $pts[$i+1]\n";
  }
  close(A);
  debug("FILE:",read_file("points"));
  system("qvoronoi s o < points > output");

  # break output into lines/polygons
  my(@regions) = split(/\n/, read_file("output"));

  # number of dimensions
  my($di) = shift(@regions);

  # TODO: "my" variable $pts masks earlier declaration in same scope

  # number of points, regions, and something else (#infinite regions?)
  my($pts, $regions, $x) = split(/\s+/,shift(@regions));

  debug("REGIONS:",@regions);

  # going thru regions (which start at $pts+1; first $pts entries are points)
  for $i ($pts+1..$#regions) {
    debug("POLYGON $i",$regions[$i]);

    # TODO: ignoring unbounded regions now, but should fix
    if ($regions[$i]=~/ 0( |$)/ && !$opts{infinityok}) {next;}

    # the numbers of the points making up this polygon
    my(@points)=split(/\s+/,$regions[$i]);
    debug("POINTS",@points);
    # the first one is dimension (uninteresting)
    shift(@points);

    # map the rest to actual point coords
    map($_=trim($regions[$_]),@points);

    # if we somehow have no points, ignore
    unless (@points) {next;}

    debug("POINTS",@points);

    # add polygon to result list (must use ref here)
    # must use $i to compensate for skipped polygons
    debug("ASSIGNING ret[$i-$pts] to @points");	
    $ret[$i-$pts] = \@points;
  }

  return @ret;
}

=item to_mercator($lat,$lon)

Converts $lat, $lon (degrees) to google maps yx Mercator projects
(top left = 0,0; bottom right = 1,1); can return abs($y)>1 for far
south/north latitudes. Options:

 order=(xy|yx): return coordinates in xy or yx format (latter is default)

NOTE: return order is yx, not xy

=cut

sub to_mercator {
  my($lat,$lon, $options) = @_;
  my(%opts) = parse_form($options);

  if (abs($lat)>=90) {return "ERR";}
  my($y) = 1/2-1*(log(tan($PI/4+$lat/180*$PI/2))/2/$PI);
  if ($opts{order} eq "xy") {
    return ($lon+180)/360, $y;
    # else below is actually optional, but omitting it is confusing
  } else {
    return $y,($lon+180)/360;
  }
}

=item convert_time($secs, $format, $options)

Convert time interval in seconds to years/months/days/etc based on
$format (documented below, but very strftime-like).

$options unused

TODO: format < 10 seconds with leading 0

=cut

sub convert_time {
  my($sec, $format, $options) = @_;
  my(%secs);

  # requestable components (straight from strftime):
  # %C = centuries, %Y = years, %m = months, %U = weeks
  # %d = days, %H = hours, %M = minutes, %S = seconds

  # number of seconds for the above (Gregorian calendar sans leap seconds)
  # Year = 365.2425 days (so seconds for months/years/centuries looks weird)
  %secs = ("S" => 1, "M" => 60, "H" => 3600, "d" => 86400, "U" => 604800,
	   "m" => 2629746, "Y" => 31556952, "C" => 3155695200);

  # figure out what components are requested in $format; we have to
  # return them biggest-to-smallest, not in the order specified
  my(@components)=($format=~/%([CYmUdHMS])/g);

  # and sort them
  @components = sort {$secs{$b} <=> $secs{$a}} @components;

  # and convert
  for $i (@components) {
    # compute how many whole $i units in $sec and subtract them off
    my($units) = floor($sec/$secs{$i});
    debug("SECBEFORE: $sec");
    $sec -= $secs{$i}*$units;
    debug("UNITS: $units","SECAFTER: $sec");
    # and substitute in format
    $format=~s/%$i/$units/g;
  }

  return $format;

}

=item forex_quotes()

Obtain current FOREX quotes; return as hash of bid/ask values

<h>Unsolved problem: How to spell FoReX</h>

=cut

sub forex_quotes {
  my(%hash); # for return values
  my($browser) = "nozilla";
  my($out,$err,$res) =  cache_command("curl -A '$browser' www.forexpros.com/common/quotes_platform/quotes_platform_data.php | tidy -xml","retry=5&sleep=1&age=30");
  debug("OUT: $out");

  # loop through each parity
  while ($out=~s%([A-Z]{3})/([A-Z]{3})(.*?</div>)\s*</div>\s*</div>%%s) {
    my($parity, $data) = ("$1$2", $3);
    # prices for parity
    my(@prices) = ($data=~m%<div class="quotes_platform_16" dir="ltr">(.*?)</div>\s*<div class="quotes_platform_17[^\"]*">(.*?)</div>%isg);
    # HACK: I should do this in a much more general way
    if ($parity=~/USDJPY/) {$prices[1]*=100; $prices[3]*=100;}

    $hash{$parity}{bid} = $prices[0] + $prices[1]/10000;
    $hash{$parity}{ask} = $prices[2] + $prices[3]/10000;
  }

  return %hash;
}

=item nadex_quotes($parity, $options)

<h>The double use of the word 'options' here (financial instrument vs
parameters to a subroutine) amuses me</h>

Obtains NADEX option quotes for $parity, given as "USD-CAD" (for example).

Return values are $hash{"USDCAD"}{strike}{Unix_exp_time}{bid|ask|updated}

Options:
  nointra=1: Do not obtain intradaily options
  cache=t: Cache results for t seconds (default: 15m)

This function REQUIRES a file called "nadex-cookie.txt":

To obtain this cookie (requires Firebug):
  - Log into nadex.com (bugmenot.com has a demo username/pw)
  - Turn on Firebug and go to the Net/All panel
  - On main screen, click on any specific option
  - In Firebug, look at your first GET request
  - Copy/paste the cookie into a nadex-cookie.txt file
  - The cookie will look something like sample-data/nadex-cookie.txt
  - Do not use Firefox's cookies.sqlite: it doesn't work

TODO: automate cookie obtaining procedure

TODO: try to identify bad cookie earlier w/o multiple web accesses first

TODO: query intraday options intelligently based on current time; no
need to query them all all the time

=cut

sub nadex_quotes {
 my($parity, $options) = @_;
 my(%hash); # to hold return values
 $parity = uc($parity);
 unless ($parity=~/\-/) {
   warnlocal("PARITY MUST CONTAIN: -");
   return;
 }

 my($cookie) = read_file("/home/barrycarter/nadex-cookie.txt");
 chomp($cookie);
 my($dataq)=0;
 # putting defaults first lets $options override
 my(%opts) = parse_form("cache=600&$options");

 # HACK: I'm sometimes logged in w/ my live account and sometimes w/
 # my demo account, so I never know what nadex-cookie.txt has (I
 # updated it manually frequently from whicheever account I'm logged
 # into)
 $cookie=~/(demo|www)\.nadex\.com/isg;
 my($prehost) = $1;
 unless ($prehost) {warnlocal("nadex_quotes fails; bad cookie"); return;}
 debug("PREHOST: $prehost, COOKIE: $cookie");

 # TODO: using /tmp here is ugly, but I don't see a way around it.
 # I can't use cache-command, since I'm using curl's wildcarding feature

 # commands to obtain daily, weekly, and intra-daily options

 # TEMP HACK: for some reason OPT-2 is the one today (sometimes OPT-3)
my($daily_cmd) = "curl -v -L -k -o /tmp/daily.$parity.#1-#2.txt -v -L -H 'Cookie: $cookie' 'https://$prehost.nadex.com/dealing/pd/cfd/displaySingleMarket.htm?epic=N{B}.D.$parity.OPT-1-[1-21].IP'";
# my($daily_cmd) = "curl -v -L -k -o /tmp/daily.$parity.#1-#2.txt -v -L -H 'Cookie: $cookie' 'https://$prehost.nadex.com/dealing/pd/cfd/displaySingleMarket.htm?epic=N{B}.D.$parity.OPT-3-[1-21].IP'";
# my($daily_cmd) = "curl -v -L -k -o /tmp/daily.$parity.#1-#2.txt -v -L -H 'Cookie: $cookie' 'https://$prehost.nadex.com/dealing/pd/cfd/displaySingleMarket.htm?epic=N{B}.D.$parity.OPT-2-[1-21].IP'";

# my($daily_cmd) = "curl -v -L -k -o /tmp/daily#1-#2.txt -v -L -H 'Cookie: $cookie' 'https://$prehost.nadex.com/dealing/pd/cfd/displaySingleMarket.htm?epic=N{B}.D.$parity.OPT-2-[1-21].IP'";
 my($weekly_cmd) = "curl -v -L -k -o /tmp/weekly.$parity.#1-#2.txt -v -L -H 'Cookie: $cookie' 'https://$prehost.nadex.com/dealing/pd/cfd/displaySingleMarket.htm?epic=N{B}.W.$parity.OPT-1-[1-14].IP'";
 my($intra_cmd) = "curl -v -L -k -o intra.$parity.#1-#2-#3.txt -v -L -H 'Cookie: $cookie' 'https://$prehost.nadex.com/dealing/pd/cfd/displaySingleMarket.htm?epic=N{B}.I.$parity.OPT-[1-8]-[1-3].IP'";

 # and obtain data (since I'm using curl -o, below doesn't actually
 # return anything, so I ignore the return value)

 debug("DAILY: $daily_cmd");
 debug("WEEKLY: $weekly_cmd");
 cache_command($daily_cmd, "age=$opts{cache}");
 cache_command($weekly_cmd, "age=$opts{cache}");
 unless ($opts{nointra}) {cache_command($daily_cmd, "age=$opts{cache}");}

 # parse results
 # TODO: in theory, could get old intra results here
 for $i (glob ("/tmp/daily.$parity.*.txt /tmp/weekly.$parity.*.txt /tmp/intra.$parity*.txt")) {
   my($all) = read_file($i);

   # option name
   unless ($all=~m%<title>(.*?)</title>%) {
     warnlocal("NO DATA IN: $i");
     next;
   }

   $title = $1;
   $title=~s/\|.*//;
   $title=~s/>\s+/>/g;

   # skip bad
   if ($title=~/^sorry/i) {next;}

   # confirm we got at least SOME data
   $dataq = 1;

   # title pieces + cleanup
   debug("TITLE: $title");
   my($par, $strdir, $tim, $dat) = split(/\s/, $title);
   $par=~s/\///isg;
   for $j ($tim,$dat) {$j=~s/[\(\)]//isg;}
   $strdir=~s/>//isg;

   # Unix time
   # TODO: EST5EDT does NOT work below, but should; this will be
   # inaccurate once we leave DST (so I change it regularly sigh)
   $utime = str2time("$dat $tim GMT-4");
   debug("$utime <- $dat $tim");

   # last updated time
   my($updated) = 0;
   while ($all=~s%<span class="updated updateTime left">(.*?)</span>%%g) {
     $updated=$1;
   }

   # convert updated to time + calculate minute
   # str2time() defaults to today
   debug("UPTIME: $updated");
   my($uptime) = str2time("$updated GMT-5");

   # TODO: below is ugly, there should be better way
   # however, if that's in the future, assume yesterday update
   if ($uptime > time()) {$uptime-=86400;}
   # if it's too far in the past, add one day
   if (time() - $uptime > 86400) {$uptime+=86400;}

   # grab values
   my(@vals)=();
   while ($all=~s%<span class="valueNotFX">(.*?)</span>%%) {
     $val = $1;
     $val=~s/<.*?>//isg;
     push(@vals, $val);
   }

  ($obid, $oask) = @vals;

   # TODO: not sure skipping no bid/ask is a good idea here
   # (later decided it was and replacing "-" with 0)
#   if ($obid eq "-" || $oask eq "-") {next;}

   if ($obid eq "-") {$obid="0";}
   if ($oask eq "-") {$oask="100";}

   debug("PAR IS: $par");
   $hash{$par}{$strdir}{$utime}{bid} = $obid;
   $hash{$par}{$strdir}{$utime}{ask} = $oask;
   $hash{$par}{$strdir}{$utime}{updated} = $uptime;
   debug("SETTING $par/$strdir/$utime");
 }

 unless ($dataq) {
   warnlocal("GOT NO DATA: BAD COOKIE? MARKET CLOSED? NETWORK DOWN?");
   # <h>warnlocal("ELVES ON STRIKE? DEMONS ATTACKING? BAD MOON PHASE?")</h>
   return;
 }

 return %hash;
}

=item nestify($str)

Given a $str (that looks like contents of data/moonxyz.txt for
example), return a nested array of contents).

HACK: this is pretty much a kludge function to read Mathematica
output. There are probably MUCH better ways to do this, but using an
"inside out" recursive approach has a certain uniqueness.

=cut

sub nestify {
  my($all) = @_;
  my($n)=-1;
  my(@res);

  # convert all {stuff} and [stuff] into list refs
  while ($all=~s/[\{\[]([^\{\}\[\]]*)[\}\]]/f1($1)/eisg) {}

  # TODO: this conflicts w/ f1 in outer scope, if any; same for f2
  sub f1 {
    my($str) = @_;
    $str=~s/\n/ /isg;
    $str=~s/\s+/ /isg;
    $res[++$n] = $str;
#    debug("$str -> RES$n");
    return "RES$n";
  }

  # now turn it into a proper list of lists (of lists...)
  return f2($all);

  sub f2 {
    my(@ret);
    my($val) = @_;
    for $i (split(/[\,\s)]+\s*/,$val)) {
      if ($i=~/RES(\d+)/) {
	push(@ret, [f2($res[$1])]);
      } else {
	push(@ret, $i);
      }
    }
    return @ret;
  }
}

=item forex_quote($parity, $time)

Obtains price of $parity (as "USD/CAD") at or near $time (in Unix seconds).
Options:

  - list=true: return list of quotes (in ugly XML format right now),
  not just a single quote

Requires: free API username/password from http://api.efxnow.com/forum/index.php

TODO: confusing name, since it's close to forex_quotes(); however, may
get rid of forex_quotes() as using efxnox.com's API seems easier
anyway

# TODO: default time to now?

=cut

sub forex_quote {
  my($parity, $time, $options) = @_;
  my($price);
  my(%opts) = parse_form($options);
  my(@res);

  # obtain username/password/brand
  my($username,$password,$brand) = split("\n",read_file("/home/barrycarter/efx-info.txt"));

  # obtain key (needed for any sort of access)
  my($key) = cache_command("curl 'http://api.efxnow.com/DEMOWebServices2.8/Service.asmx/GetRatesServerAuth?UserID=$username&PWD=$password&Brand=$brand'","age=3600&retry=5");

  # strip XML and spaces
  $key=~s/<.*?>//isg;
  $key=~s/\s//isg;

  # bad key
  if ($key=~/authenticationproblem/i) {
    warnlocal("BAD KEY: $key");
    return;
  }

  # Convert Unix time to
  # http://api.efxnow.com/DEMOWebServices2.8/Service.asmx?op=GetHistoricRatesDataSet
  # use a 5 minute boundary on each side (TODO: too much? too little?)
  # NOTE: cheating and using ISO-8601, but EFX accepts that too
  # TODO: in theory, will get data for nearby times too, but not caching it:
  # ie: forex_quote($x, $y) and forex_quote($x, $y+1) requires 2 API accesses
  # EFX uses ET, sigh

  my($tz) = $ENV{TZ};
  $ENV{TZ} = "EST";
  my($st) = strftime("%F\T%H:%M:%S", localtime($time-300));
  # trying shorter time, since +300 seems to make it unhappy now
  # my($en) = strftime("%F\T%H:%M:%S", localtime($time+300));
  my($en) = strftime("%F\T%H:%M:%S", localtime($time+30));
  $ENV{TZ} = $tz;

  my($url) = "http://api.efxnow.com/DEMOWebServices2.8/Service.asmx/GetHistoricRatesDataSet?Key=$key&Quote=$parity&StartDateTime=$st&EndDateTime=$en";
  my($rates) = cache_command("curl '$url'", "age=86400");

  debug("URL: $url", "RATES: $rates, TIME: $time");

  # TODO: probably better way to keep track of mintime (using "large
  # value" is bad)
  my($mintime) = 1e+9;

  # parse
  while ($rates=~s%<HistoricRates[^>]*?>(.*?)</HistoricRates>%%is) {
    my($quote) = $1;
    # below only if list=true
    push(@res, $quote);
    my(%hash);
    while ($quote=~s%<(.*?)>(.*?)</\1>%%) {$hash{$1}=$2;}

    # how far away is this quote, time-wise?
    my($deltat) = abs(str2time($hash{Time}) - $time);

    # if it's the closest so far, record it
    if ($deltat < $mintime) {
      $mintime = $deltat;
      $price = ($hash{Bid}+$hash{Offer})/2;
    }
  }

  if ($opts{list}) {return @res;}

  return $price;
}


=item hermione($x, \@xvals, \@yvals)

Computes the Mathematica interpolation (which I have dubbed the
"Hermione interpolation") for @xvals -> @yvals at $x

<h>"oh barry, do be careful!"</h>

=cut

sub hermione {
  my($x,$xvals,$yvals) = @_;
#  debug("hermione($x,$xvals,$yvals)");
  my(@xvals) = @{$xvals};
  my(@yvals) = @{$yvals};

#  debug("XVALS",@xvals);

  # compute size of x intervals, assuming they are all the same
  my($intsize) = ($xvals[-1]-$xvals[0])/$#xvals;

  # what interval is $x in and what's its position in this interval?
  # interval 0 = the 1st interval
  my($xintpos) = ($x-$xvals[0])/$intsize;
  my($xint) = floor($xintpos);
  my($xpos) = $xintpos - $xint;

  my($ret) =  hermm1($xpos)*$yvals[$xint-1] +
              herm0($xpos)*$yvals[$xint] +
              hermp1($xpos)*$yvals[$xint+1] +
       	      hermp2($xpos)*$yvals[$xint+2];

  return $ret;

  # I dub these the Hermione polynomials
  sub hermm1 {my($x)=@_; ($x-2)*($x-1)*$x/-6;}
  sub herm0 {my($x)=@_; ($x-2)*($x-1)*($x+1)/2;}
  sub hermp1 {my($x)=@_; $x*($x+1)*($x-2)/-2;}
  sub hermp2 {my($x)=@_; ($x-1)*$x*($x+1)/6;}
}

=item matrixmult(\@x,\@y)

Multiply matrices (2D arrays) x and y. To multiply a matrix by a
vector do something like:

matrixmult(\@mat, [[$x],[$y],[$z]])

so that the second argument is a reference to an array of references

=cut

sub matrixmult {
    my($a,$b)=@_;
    my(@a)=@$a;
    my(@b)=@$b;
#    debug("B: $b",@b);
    my($rows,$cols)=($#a,$#{$b[0]});
    my($share)=$#b;
    my(@ans);

#    debug("ROWS: $rows+1, COLS: $cols+1");

    for $i (0..$rows) {
	for $j (0..$cols) {
	    for $k (0..$share) {
#	      debug("$i,$j,$k -> $a[$i][$k] * $b[$k][$j]");
		$ans[$i][$j]+= $a[$i][$k]*$b[$k][$j];
	    }
	}
    }
    return(@ans);
}


=item position($object, $t=now, $options)

Determine the position (right ascension [0,24] and declination
[-90,+90] of $object at time $t, using Hermite approximation. Requires
data/{$object}fake[xy].txt and only accurate for the span in that
file.

TODO: I really need to start creating sub libraries?

=cut

sub position {
  my($obj, $t) = @_;
#  debug("POSITION($obj,$t)");
  unless ($t) {$t = time();}

  my(@data) = (read_file("$ENV{HOME}/BCGIT/data/${obj}fakex.txt"), 
	       read_file("$ENV{HOME}/BCGIT/data/${obj}fakey.txt"));
  my(@nest) = (nestify($data[0]), nestify($data[1]));
  my(@xvals0) = @{$nest[0]};
  my(@x2vals0) = @{$nest[1]};
  my(@yvals, @xvals, @yvals2, @xvals2);

#  debug("XVALS:",@xvals);

  for $i (@xvals0) {
    my(@j) = @{$i};
    $j[0]=~s/\*\^(\d+)/e+$1/isg;
    push(@xvals, $j[0]);
    push(@yvals, $j[1]);
  }

  # TODO: blech! redundant code! (@xvals could be an array of arrays?)
  for $i (@x2vals0) {
    my(@j) = @{$i};
    $j[0]=~s/\*\^(\d+)/e+$1/isg;
    push(@xvals2, $j[0]);
    push(@yvals2, $j[1]);
  }

  # obtain psuedo-xy coordinates
#  debug("XV2:",@xvals2);
  my($xcoord) = hermione($t, \@xvals, \@yvals);
  my($ycoord) = hermione($t, \@xvals2, \@yvals2);

  # computing pos
  my($ra) = atan2($ycoord,$xcoord)/$PI*12;
  if ($ra<0) {$ra+=24;}
  my($dec) = (sqrt($xcoord**2+$ycoord**2)-$PI)/$PI*180;

  debug("RETURNING: $ra, $dec");

  return $ra,$dec;
}

=item gmst($t=now)

Compute the Greenwich Mean Siderial Time at Unix time t

=cut

sub gmst {
  my($t)=@_;
  unless ($t) {$t = time();}

  # from http://en.wikipedia.org/wiki/Sidereal_time
  # 946728000 = unix time at 2000 January 1, at 12h UT
  my($res) = 18.697374558 + 24.06570982441908*($t-946728000.)/86400.;
  return fmodp($res,24);
}

=item greeks_bin($cur, $str, $exp, $vol)

Return the greeks and fair value of a binary option, given $cur, the
current price of the underlying, $str, the option strike price, $exp,
the time to expiration in years, and $vol, the volatility (per year).

Returned values (in order):
  - fair value
  - delta: per pip
  - theta: per hour (since this is mostly for NADEX)
  - vega: per .01 change

=cut

# greeks + value of binary option
sub greeks_bin {
  debug("GREEKS_BIN",@_,"ENDARG");
  my($cur, $str, $exp, $vol) = @_;

  # nesting subroutines = bad?
  sub bin_value {
    my($cur, $str, $exp, $vol) = @_;
    debug("BIN_VALUE($cur, $str, $exp, $vol)");

    # easy cases (0 volatility = same price at expiration)
    if ($exp <= 0 || $vol==0) {return ($cur>$str?1:0);}

    return uprob(log($str/$cur)/($vol*sqrt($exp)));
  }

  # things to return: fair value, delta, theta, etc
  my($val) = bin_value($cur, $str, $exp, $vol);
  # TODO: this is NOT the correct way to calculate delta, theta, etc
  my($delta) = bin_value($cur+.0001, $str, $exp, $vol) - $val;
  # TODO: this could yield a negative expiration time
  my($theta) = bin_value($cur, $str, $exp-1/365.2425/24, $vol) - $val;
  my($vega) = bin_value($cur, $str, $exp, $vol+.01) - $val;

  return ($val, $delta, $theta, $vega);

}

=item bin_volt($price, $strike, $exp, $under)

Computes the volatility of a binary option, given its current $price,
the $strike price, the years to expiration $exp, and the price of the
underlying instrument $under

NOTE: I realize all my valuations are for "call" style options, but
this is probably OK.

NOTE: will pretty much obsolete nadex-vol.pl (?)

NOTE: see older versions of bc-nadex-vol.pl for formula derivation

=cut

sub bin_volt {
  my($price, $strike, $exp, $under) = @_;
  debug("bin_volt($price, $strike, $exp, $under)");
  # can't calculate volatility if price is 50
  # volatility meaningless if price is 0 or 100
  if ($price == 50 || $price == 100 || $price ==0) {return 0;}
  return log($strike/$under)/udistr($price/100)/sqrt($exp);
}

=item post_to_wp($body, $options)

Posts $body as a new WordPress post with the following options:

  - site: site to post to (eg, wordpress.barrycarter.info)
  - author: post author (eg, barrycarter)
  - password: password for posting
  - subject: subject/title of post (if editing, use current subject)
  - timestamp: UNIX timestamp of post
  - category: category of post
  - live: whether to make post live instantly (default=no)

Optional:

  - action: wp.editPage to edit existing page/post
  - postid: id of page/post (if editing existing)
  - wp_slug: slug (autoset for new posts)

=cut

sub post_to_wp {
  my($body, $options) = @_;
  my(%opts) = parse_form($options);
  my(%defaults) = parse_form("live=0&action=metaWeblog.newPost");
  for $i (keys %defaults) {
    $opts{$i} = $defaults{$i} unless (exists $opts{$i});
  }

  # timestamp (in ISO8601 format)
  my($timestamp) = strftime("%Y%m%dT%H:%M:%S", gmtime($opts{timestamp}));

  # if editing, new strings to insert in request
  my($strs);
  if ($opts{postid}) {
    @strs = ("<param><value><string>$opts{postid}</string></value></param>",
	     "<member><name>wp_slug</name><value><string>$opts{wp_slug}</string></value></member>");
  }

my($req) =<< "MARK";

<?xml version="1.0"?>
<methodCall> 
<methodName>$opts{action}</methodName> 
<params>

<param><value><string>x</string></value></param>

$strs[0]

<param><value><string>$opts{author}</string></value></param> 

<param><value><string>$opts{password}</string></value></param>

<param> 
<struct> 

$strs[1]

<member><name>categories</name> 
<value><array><data><value>$opts{category}</value></data></array></value> 
</member> 

<member>
<name>description</name> 
<value><string><![CDATA[$body]]></string></value>
</member> 

<member> 
<name>title</name> 
<value>$opts{subject}</value> 
</member> 

<member> 
<name>dateCreated</name> 
<value>
<dateTime.iso8601>$timestamp</dateTime.iso8601> 
</value> 
</member> 

</struct> 
</param> 

<param><value><boolean>$opts{live}</boolean></value></param> 

</params></methodCall>
MARK
;

  write_file($req,"/tmp/request");
  debug($req);

  if ($globopts{fake}) {return;}

  # curl sometimes sends 'Expect: 100-continue' which WP doesn't like.
  # The -H 'Expect:' below that cancels this
  system("curl -H 'Expect:' -o /tmp/answer --data-binary \@/tmp/request http://$opts{site}/xmlrpc.php");

  debug($req);

  return read_file("/tmp/answer");
}


=item xmlrpc($site, $method, \@params, $options)

Runs the XMLRPC $method on $site, using @params as the parameters
(must be a listref, not a list).

$site is the XMLRPC endpoint (eg, http://wordpress.barrycarter.info/xmlrpc.php)

@params are in the format "value:type" [currently cant pass values
with colons in them... \: does NOT work as escape <h>though it does
make a cute emoticon</h>]

$options currently unused

TODO: only supports simple non-struct requests at the moment

=cut

sub xmlrpc {
  chdir(tmpdir());
  my($site, $method, $params, $options) = @_;
  my(@params) = @$params;
  my($call) = << "MARK";
<?xml version="1.0"?><methodCall>
<methodName>$method</methodName><params>
MARK
;

  for $i (@params) {
    if ($i=~/^(.*?):(.*)$/) {
      $call .= "<param><value><$2>$1</$2></value></param>\n";
    } else {
      $call .= "<param><value>$i</value></param>\n";
    }
  }

  $call .= "</params></methodCall>";
  write_file($call, "input.txt");

  # make the call
  ($out, $err, $res) = cache_command("curl --data-binary \@input.txt http://wordpress.barrycarter.info/xmlrpc.php");

  return $out;

}

=item findroot(\&f, $x1, $x2, $e, $maxsteps=50, $options)

Find where f [a one-argument function] reaches 0 (to an accuracy of
$e) between $x1 and $x2. Stop if $maxsteps reached before specified
accuracy. Options:

delta: stop and return when the x difference reaches this value,
regardless of difference in y value

<h>I wrote this function years ago, so its not as polished as my
current coding</h>

=cut

sub findroot {
    my($f,$x1,$x2,$e,$maxsteps,$options)=@_;
    if ($maxsteps==0) {$maxsteps=50;}
    my($le,$ri)=($x1,$x2);
    my($steps,$mid,$fmid);
    my(%opts) = parse_form($options);

    # value of the function at interval edges
    my($fle,$fri)=(&$f($le),&$f($ri));

    # same sign on both sides of interval?

    # TODO: same sign -> product is positive (ugly workaround to
    # non-imported signum function)

    if ($fle*$fri > 0) {
      debug("FLE: $fle, FRI: $fri");
      warnlocal("INVALID BINARY SEARCH");
      return();
    }

    # infinite loop broken by $maxsteps
    for (;;) {
	$steps++;

	# is x delta small?
	if ($opts{delta}&&(abs($ri-$le)<$opts{delta})) {return $mid;}

	# find value at midpoint
	$mid=($le+$ri)/2;
	$fmid=&$f($mid);

	# close enough? return midpoint
	if (abs($fmid)<$e) {return($mid);}

	# too many steps?
	if ($steps>$maxsteps) {
	  warnlocal("NO ROOT FOUND");
	  return();
	}

	# find which side the midpoint matches and continue w/ FOR loop
	# NOTE: could've used recursion here, though I doubt it'e more efficient
	# NOTE: ugly use to check same signedness here, see note above
	if ($fle*$fmid>0) {
	    $le=$mid;
	    $fle=$fmid;
	} else {
	    $ri=$mid;
	    $fri=$fmid;
	}
    }
}

=item findmin (\&f,$a,$d,$e,$maxsteps=50)

A non-calculus technique [ternary method] (the "interval technique",
<h>formally known as "Caesar's divisa in partes tres" method</h>) to
find the x value for the minimum of f [a one-argument function] on the
interval [$a, $d] within $e (as measured in x, not f(x)), provided that:

  - f is continuous on [$a,$d]
  - f has a UNIQUE local minimum in [$a,$d]
  - f has no local maximum in [$a,$d]
  - <h>Other conditions I've now forgotten</h>

<h>Like findroot, I wrote this ages ago, so my coding style sucks more
than normal</h>

=cut

sub findmin {
    my($f,$a,$d,$e,$maxsteps,$steps,$b,$c)=@_;
    if ($maxsteps==0) {$maxsteps=50;}
    
    for (;;) {
	$steps++;

	# break interval into 3 pieces, and find function value on those pieces
	# intervals are [$a,$b], [$b,$c], and [$c,$d]
	($b,$c)=($a*2/3+$d/3,$a/3+$d*2/3);
	($fa,$fb,$fc,$fd)=(&$f($a),&$f($b),&$f($c),&$f($d));
#	debug("$a -> $fa, $b -> $fb, $c -> $fc, $d -> $fd");

	# too many steps?
	if ($steps>$maxsteps) {
	  warnlocal("NO MIN FOUND");
	  return();
	}

	if ($fc>=$fb && $fd>=$fc) {
	  # if f($d) > f($c) > f($b), then min can't be in [$c,$d]
#	  debug("OMIT SEGMENT 3");
	  $d=$c;
	} elsif ($fb<=$fa && $fc<=$fb) {
	  # if f($a) > f($b) > f($c), min can't be in [$a,$b]
#	  debug("OMIT SEGMENT 1");
	  $a=$b;
	} elsif ($fb<=$fa && $fd>=$fc) {
	  # if f($b) < f($a) AND f($c) < $f(d), min must be in [$b,$c]
#	  debug("OMIT SEGMENTS 1 and 3");
	  ($a,$d)=($b,$c);
	} else {
	  # impossible, unless intial parameters bad
	  warn("INVALID MIN SEARCH");
	  return();
	}

	if (($d-$a)<$e) {return(($a+$d)/2);}
    }
}

=item stardate($time=now, $options)

Returns $time in somewhat human (<h>Vulcan, Andorran, Betazoid, etc</h>)
readable format, yyyymmdd.hhmmss

Options:
 localtime=1: use localtime, not gmtime

<h>I've coded this many different ways over the years: I think I
finally found the right way to do this!</h>

=cut

sub stardate {
  my($time, $options) = @_;
  unless ($time) {$time = time();}
  my(%opts) = parse_form($options);
  if ($opts{localtime}) {
    return strftime("%Y%m%d.%H%M%S", localtime($time));
  } else {
    return strftime("%Y%m%d.%H%M%S", gmtime($time));
  }
}

=item datestar($str)

Does the opposite of stardate(): given a date in
yyyymmdd[.][hh][mm][ss] format, return Unix time.

TODO: has to be a much shorter way to do this?

=cut

sub datestar {
  my($str) = @_;
  debug("DATESTAR($str)");
  my(@frac);
  # yyyymmdd must be present
  $str=~s/^(\d{4})(\d{2})(\d{2})//;
  my($y,$m,$d) = ($1,$2,$3);

  # hh, mm, ss may be present (along with dots?)
  while ($str=~s/^\.?(\d{2})//) {push(@frac, $1);}
  # if any of above missing, use 0s
  push(@frac,"00","00","00");
  return str2time("$y-$m-$d $frac[0]:$frac[1]:$frac[2]");
}

=item minus(\@l1, \@l2)

Returns the set-theoretic difference of list l1 and l2, which must be
passed as pointers

=cut

sub minus {
  my($x,$y)=@_;
  my(%z);

  for $i (@$x) {$z{$i}=1;}
  for $i (@$y) {delete $z{$i};}
  return keys %z;
}

=item sendmail($from, $to, $subject, $body)

Uses sendmail -v to send email from $from to $to with subject $subject
and body $body.

Returns the stdout/stderr/return value of sendmail -v

=cut

sub sendmail {
  my($from,$to,$subject,$body)=@_;
  chdir(tmpdir());
  my($str) = << "MARK";
From: $from
To: $to
Subject: $subject

$body

MARK
    ;
  write_file($str, "mailme");
  return cache_command("sendmail -v -f$from -t < mailme");
}


=item elhrlen()

Determine the length of an Eternal Lands hour (in RL seconds) by
looking at log files since my last connection: the length given in the
wiki appears to be inaccurate. This is a one-shot "hack" function.

Only includes latest connection so there are no gaps in the warnings.

=cut

sub elhrlen {
  my(@l);
  my($tot);
  local(*A);
  open(A,"tac ~/.elc/main/srv_log.txt | egrep -i 'minute warning for the coming hour|connecting to server...' |");

  # ultimately, we're just computing the difference between the first
  # and last entries, but doing it one line at a time helps when total
  # time period exceeds 24 hours

  while(<A>) {
    if (/connecting to server/i) {last;}
    /^\[(\d{2}):(\d{2}):(\d{2})\]/||warnlocal("BAD LINE: $_");
    push(@l,$1*3600+$2*60+$3);
  }

  # Starting at 1, since first diff is l[1] - l[0]
  for $i (1..$#l) {
    my($diff) = $l[$i]-$l[$i-1];
    # if we've crossed a 24h line
    if ($diff>0) {$diff-=86400;}
    $tot+=$diff;
    debug("$diff / $tot");
  }

  return -$tot/$#l;

}

=item unix2el($time=now)

Converts Unix $time in seconds to Eternal Lands time (a list of [year,
month, date, hours, minutes, seconds]), assuming that server has not
been reset since subroutine last updated.

Run elhrlen() occasionally to keep this accurate.

=cut

sub unix2el {
  my($time) = @_;
  # default to now
  unless ($time) {$time=time();}

  # Base times (based on server log)
  my($ubase) = str2time("11 Jul 2011 13:01:59 MDT");
  # note format below is sec, min, hour, day, month, year, NOT same as in docs
  my(@ebase) = (0,59,0,27,11,27);
  # below = seconds-in-minute, minutes-in-hour, hours-in-day (only 6 in EL)
  # days-in-month (always 30 in EL), months-in-year
  my(@eltimes) = (60, 60, 6, 30, 12);

  # RL seconds since base time
  my($rl) = $time-$ubase;
  # EL seconds since base time (EL hour = 3638.95652173913 based on elhrlen)
  my($el) = 3600*$rl/3638.95652173913;

  debug("RL/EL: $rl/$el");
#  $ebase[0] += $rl;
  $ebase[0] += $el;
#  $ebase[0] += 61*$rl/60;

  # now push seconds to minutes, etc
  for $i (0..$#ebase-1) {
    # eg: 1214 seconds = 20 minutes and 14 seconds
    debug("I: $i, $eltimes[$i]");
    $ebase[$i+1] += int($ebase[$i]/$eltimes[$i]);
    $ebase[$i] = $ebase[$i]%$eltimes[$i];
  }

  return reverse @ebase;
}

=item blank($x)

Is $x nothing but (possibly 0) space characters (not really worth
being a function, but I'm porting progs that use it)

=cut

sub blank {$_[0]=~/^\s*$/;}

=item ctof($c)

OBSOLETE: Convert $c degrees Celsius to Farenheit

Use convert() instead

=cut

sub ctof {$_[0]*1.8+32;}

=item nice_sec($secs, $nosecs)

Given a number of seconds $secs, display it a nice way, returning
minutes/hours/etc. If $nosecs is set, do not display seconds in return.

NOTE: this is another function I wrote ages ago that doesn't look very
good, but I need it to port some of my older stuff.

=cut

sub nice_sec {
    my($s,$nosecs)=@_;
    if ($nosecs) {$s+=30;} # roundoff kludge
    my(@a)=(60,60,24,30.436875,12,1000);
    my(@out);
    my($m,$aa);
    my(@b)=("seconds","minutes","hours","days","months","years","eons");
    for(@a){
      if($m=$s%$_){unshift(@out,$m,$b[0])}
      $s=int($s/$_);shift(@b);
    }
    $aa=join(" ",@out);
    if ($nosecs) {$aa=~s/\s*\d+\s+seconds//;}
    return($aa);
}

=item rh($temp, $dew)

Return the relative humidity, given the temperature and dew point,
both in Celsius.

NOTE: I have no idea where I got this formula

=cut

sub rh {
  my($c,$d)=@_;
  return(exp(17.67*$d/(243.5+$d))/exp(17.67*$c/(243.5+$c)));
}

=item hi($temp, $rh)

Compute the heat index, given the temperature $temp in Farenheit, and
the relative humidity $rh a percent (0 < $rh < 100).

Source: http://www.hpc.ncep.noaa.gov/heat_index/hi_equation.html

NOTE: I'm not convinced this formula is accurate.

NOTE: these functions really belong in another lib, especially since
their names are only two letters long + they could be easily confused
w/ other functions

=cut

sub hi {
  my($t,$rh)=@_;
  if ($t<70) {return($t);} # per email from Pubnws@noaa.gov
  my($a)=-42.379+2.04901523*$t+10.14333127*$rh-.22475541*$t*$rh -.00683783*$t*$t-.05481717*$rh*$rh+.00122874*$t*$t*$rh+.00085282*$t*$rh*$rh-.00000199*$t*$t*$rh*$rh;
  if ($rh<=13 && $t>=80 && $t<=112) {
    $a-=((13-$rh)/4)*sqrt((17-abs($t-95))/17);
  }
  if ($rh>=85 && $t>=80 && $t<=87) {
    $a+=(($rh-85)/10)*((87-$t)/5);
  }
  return($a);
}

=item wc($temp, $speed)

Compute wind chill temperature (in Farenheit), give temperature $temp
(in Farenheit) and wind speed $speed (in miles per hour).

<h>Don't you love how consistent I am using metrics vs the Imperial system?</h>

NOTE: functions I import from my earlier work often have
differently-named parameters (eg, $t and $w below instead of $temp and
$speed), and don't follow my standard options-passing format.

=cut

sub wc {
  my($t,$w)=@_;
  if ($w<3 || $t>=50) {return($t);}
  return(35.74+0.6215*$t-(35.75-0.4275*$t)*$w**.16);
}

=item wind($speed, $dir, $gust)

Returns a descriptive phrase for a wind blowing at $speed knots, from
angular direction $dir, and gusting to $gust knots.

=cut

sub wind {
  my($speed,$dir,$gust)=@_;
  my($a,$b);
  $speed=int(.5+1.1507784538*$speed);
  if ($speed==0) {return("calm");}
  $gust=int(.5+1.1507784538*$gust);
  @winddirs=("N","NNE","NE","ENE", "E","ESE","SE","SSE", "S","SSW","SW","WSW", "W","WNW","NW","NNW","N");

  @winddirs=("north","north-northeast","northeast","east-northeast",
	     "east","east-southeast","southeast","south-southeast",
	     "south","south-southwest","southwest","west-southwest",
	     "west","west-northwest","northwest","north-northwest","north");
  $a=$winddirs[int($dir/22.5+.5)];
  $b="from the $a at $speed mph";

  if ($dir=~/^vrb$/i) {$b="variable at $speed mph";}
  if ($gust>$speed) {$b="$b, with gusts to $gust mph";}
  return($b);
}

=item maxclouds(@list)

Given a list @list of METAR cloud covers, return a descriptive phrase
based on the maximum cloudiness.

<h>I dislike the word "scattered" and replaced it</h>

=cut

sub maxclouds {
  my(@a)=@_;
  if ($#a==-1) {return();} # if no list, return blank not clear
  my($max,$i); # max will hold max clouds
  %CLOUDCOVER=("clr" => 0, "few" => 1, "sct" => 2, "bkn" => 3, "ovc" => 4);
  @clouds=("clear","partly cloudy","moderately cloudy","mostly cloudy","overcast");
  for $i (@a) {
    $i=~s/^([a-z]{3}).*$/$1/isg;
    $max=max($max,$CLOUDCOVER{lc($i)});
  }
  
  return($clouds[$max]);
}

=item wrap($string,$cols,$chop)

Wrap $string to occupy approximately $cols columns; if $chop is set,
drop last newline in return value.

=cut

sub wrap {
    my($string,$cols,$chop)=@_;
    $string=~s/\s+$//sg;
    while ($string=~s/([^\s]{$cols})([^\s]+)/$1 $2/sg) {};
    $string=~s/(.{0,$cols})( |$)/$1\n/mg;
    $string=~s/[\n\r]+/\n/sg;
    if ($chop) {
	$string=~s/\s+$//g;
    }
    return($string);
}

=item csv()

Stolen directly from PERL FAQ 4.28 and thus undocumented.

=cut

sub csv {
    my($str)=@_;
    my(@res);

    # has trouble with ",," so fixing
    while ($str=~s/,,/, ,/isg) {}
    while ($str=~m/\"([^\"\\]*(\\.[^\"\\]*)*)\"|([^,]+)/g) {
        push(@res, defined($1) ? $1:$3);
    }
    return(@res);
}


=item write_wiki_page($wiki, $page, $newcontent, $comment, $user="", $pass="")

Replaces (or creates) page $page on mediawiki $wiki with $newcontent
and comment $comment. Logs in as $user/$pass

$wiki: API endpoint for mediawiki

Returns whatever cache_command returns for the final edit call (not
terribly useful, may change this)

=cut

sub write_wiki_page {
  my($wiki, $page, $newcontent, $comment, $user, $pass)= @_;
  # use map() below?
  ($page, $newcontent) = (urlencode($page), urlencode($newcontent));
  my(%hash);

  # cookie file must be consistent, so I can cache
  my($cookiefile) = "/var/tmp/".sha1_hex("$user-$wiki");

  # authenticate to wiki (but cache, so not doing this constantly)

  # get token and sessionid and cookie prefix
  my($out, $err, $res) = cache_command2("curl -L -b  $cookiefile -c $cookiefile '$wiki' -d 'action=login&lgname=$user&lgpassword=$pass&format=xml'", "age=3600");
   debug("FIRST: $out");
  # hashify results
  $out=~s/(\S+)=\"(.*?)\"/$hash{$1}=urlencode($2)/iseg;

  # and use it to login
  my($log_res) = cache_command2("curl -L -b $cookiefile -c $cookiefile '$wiki' -d 'action=login&lgname=$user&lgpassword=$pass&lgtoken=$hash{token}&format=xml'", "age=3600");
   debug("SECONE: $out");


  # now obtain token for page itself
  # TODO: requesting tokens 1-page-at-a-time is probably bad
  my($out, $err, $res) = cache_command2("curl -L -b $cookiefile -c $cookiefile '$wiki?action=query&prop=info&intoken=edit&titles=$page&format=xml'", "age=3600");
   debug("THIRD: $out");
  # hashify
  $out=~s/(\S+)=\"(.*?)\"/$hash{$1}=urlencode($2)/iseg;

  # write newcontent to file (might be too long for command line)
  my($tmpfile) = "/var/tmp/".sha1_hex("$user-$wiki-$page");
  # Could use multiple -d's to curl, but below is probably easier
  write_file("action=edit&title=$page&text=$newcontent&comment=$comment&token=$hash{edittoken}&format=xml", $tmpfile);

  # can't cache this command, but using cache_command to get vals
  return cache_command("curl -L -b $cookiefile -c $cookiefile '$wiki' -d \@$tmpfile");
}

=item convert($quant, $from, $to)

Converts $quant from $from units to $to units (eg, Celsius to
Farenheit), but returns "NULL" (string) if $quant is "NULL" (string),
and "ERR" if it can't convert.

This is just a hack function to convert weather data w/o losing "NULL"

=cut

sub convert {
  my($quant, $from, $to) = @_;

  # "MM" is null for buoy reports
  if ($quant eq "NULL" || $quant eq "MM" || $quant=~/^\s*$/) {return "NULL";}

  # meters per second to knots
  if ($from eq "mps" && $to eq "kt") {return $quant*1.944;}

  # celsius to farenheit
  if ($from eq "c" && $to eq "f") {return $quant*1.8+32;}

  # hectopascals to inches of mercury
  if ($from eq "hpa" && $to eq "in") {return $quant/33.86;}
  
  # millibars to inches of mercury
  if ($from eq "mb" && $to eq "in") {return $quant*0.0295333727;}

  # meters per second to miles per hour
  if ($from eq "mps" && $to eq "mph") {return 2.23693629*$quant;}

  # knots <h>per hour</h> to miles per hour
  if ($from eq "kt" && $to eq "mph") {return 1.15077945*$quant;}

  # meters to feet
  if ($from eq "m" && $to eq "ft") {return $quant/.3048;}

  debug("CONVERT DISLIKES:",@_);

  return "ERR";
}


=item coalesce(\@list)

Returns first non-empty item of @list, or the literal string "NULL" if
there aren't any. The null string and undefined value are considered
empty, but the number "0" (or anything that has strlen) is not.

=cut

sub coalesce {
  my($listref) = @_;
  my(@list) = @{$listref};
  for $i (@list) {if (length($i)>0 && $i ne "NULL") {return $i;}}
  return "NULL";
}

=item hashlist2sqlite(\@hashes, $tabname)

Given a list of @hashes and a table $tabname, return a list of queries
to populate $tabname with data from @hashes.

=cut

sub hashlist2sqlite {
  my($hashs, $tabname) = @_;
  my(%iskey);
  my(@queries);

  for $i (@{$hashs}) {
    debug("HASH: $i");
    my(@keys,@vals) = ();
    my(%hash) = %{$i};
    for $j (sort keys %hash) {
      # ignore blank keys (can't use them anyway)
      if ($j=~/^\s*$/) {next;}
      $iskey{$j} = 1;
      # mysql does not like apostrophes around column names
      push(@keys, "$j");
      # strip newlines
      $hash{$j}=~s/\n//isg;
      $hash{$j}=~s/\"/&quot;/isg;
      push(@vals, "\"$hash{$j}\"");
    }

    push(@queries, "INSERT OR IGNORE INTO $tabname (".join(", ",@keys).") VALUES (".join(", ",@vals).")");
  }

  return @queries;
}

=item dump_var($prefix, $var)

Better version of unfold(), stolen from
http://stackoverflow.com/questions/7716409/

=cut

sub dump_var {
  # TODO: warn if initial call has no $var, but that's ok for recursive calls
    my ($prefix, $var) = @_;
    my $ref = ref($var) || ""; 
    my @rv;
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Terse = 1;
    if (ref $var eq 'ARRAY') {
        for my $i (0 .. $#$var) {
            push @rv, dump_var($prefix . "->[$i]", $var->[$i]);
        }
    } elsif (ref $var eq 'HASH') {
        foreach my $key (sort keys %$var) {
            push @rv, dump_var($prefix . '->{'.Dumper($key).'}', $var->{$key});
	  }
      } elsif (ref $var eq 'SCALAR') {
        push @rv, dump_var('${' . $prefix . '}', $$var);
      } else {
        push @rv, "$prefix = " . Dumper($var) . ";\n";
      }
    return @rv;
  }

=item in_you_endo()

Run all END subroutines, even if they wouldn't be run otherwise (eg,
due to exec).

=cut

sub in_you_endo {
  my(@ENDS) = B::end_av->ARRAY;
  foreach $i (@ENDS) {
    debug("in_you_endo()");
    $i->object_2svref->();
  }
}

=item findmax(\&f,$a,$d,$e,$maxsteps=50)

Thin wrapper around findmin to find function max

=cut

sub findmax {
  my($f,$a,$d,$e,$maxsteps,$steps,$b,$c)=@_;
  my($nf) = sub {-1*&$f($_[0])};
  return findmin($nf,$a,$d,$e,$maxsteps,$steps,$b,$c)
}

=item randomize(\@list)

Randomize @list and return

=cut

sub randomize {
  my($listref) = @_;
  my(@list) = @{$listref};

  # swap random element later in list (or same place)
  for $i (0..$#list) {
    # random element at $i or later
    my($rand) = rand($#list-$i+1)+$i;

    # 3-in-hand swap
    my($temp) = $list[$rand];
    $list[$rand] = $list[$i];
    $list[$i] = $temp;
  }

  return @list;
}

=item moon_age($t=now)

Determines lunar age (days since last new moon) at $t using
abqastro.db; also returns nearest phase (past/future) w/ time to/from
that phase

Note that this calculation is in UTC/GMT, not ABQ time

=cut

sub moon_age {
  my($time) = @_;
  # impossible age so that max below works
  my($age,$nphase,$closest) = (9999, "", 9999);
  unless ($time) {$time=time();}

  # convert time to sqlite3 format (for some reason "strftime('%s',
  # time) > x" doesn't seem to work), and add 10 days so we get next
  # phase as well
  $stime = strftime("%Y-%m-%d %H:%M:%S",gmtime($time+86400*10));

  # find "nearest 6" moon phases
  my($query) = "SELECT *, (strftime('%s', time)-$time)/-86400. AS days FROM abqastro WHERE time <= '$stime' AND event IN ('New Moon', 'First Quarter', 'Last Quarter', 'Full Moon') ORDER BY time DESC LIMIT 6";
  my(@res) = sqlite3hashlist($query,"/home/barrycarter/BCGIT/db/abqastro.db");

  # loop to find lunar age, and closest phase
  for $i (@res) {

    # if new moon is in past, and closer than any other new moon, that's age
    debug("DAYS: $i->{days}, $age, $i->{event}");
    if ($i->{event}=~/new/i && $i->{days} > 0 && $i->{days} < $age) {
      $age = $i->{days};
    }

    # is this the closest phase
    debug(abs($i->{days}), $closest, "FOO");
    if (abs($i->{days}) < abs($closest)) {
      $nphase = $i->{event};
      $closest = $i->{days};
    }

  }

  return ($age,$nphase,$closest);

}

=item cpanel($site, $user, $pass, $port=2083)

Log into cPanel $site running on port $port, authenticating as
$user/$pass, and get back summary data (currently in hideous raw form)

=cut

sub cpanel {
  my($site, $user, $pass, $port) = @_;
  unless ($port) {$port=2083;}
  my($cmd) = "curl -Lk -u $user:$pass 'https://$site:$port/'";
  debug("CMD: $cmd");
  my($out) = cache_command($cmd, "age=1800");
  return $out;
}

=item jd2unix($jd, $dir="jd2unix|unix2jd")

Given the Julian date or Unix time, return the other based on $dir

=cut

sub jd2unix {
  my($t, $dir) = @_;
  if ($dir eq "jd2unix") {return ($t-2440587.5)*86400;}
  elsif ($dir eq "unix2jd") {return $t/86400+2440587.5;}
  else {warnlocal("second argument not understood")}
}

=item linear_regression(\@x,\@y)

Computes the linear regression between same-sized arrays x and
y. Packages like Math::GSL::Fit probably do this better, but I cant
get them to compile <frowny face>

Also returns average of ys, since I calculate it anyway, and
(reference to a) list of running regression (for same reason)

TODO: above is very kludgey

TODO: this seems really inefficient

TODO: this actually returns SUM of ys not the average, fix this but make sure it doesnt break other programs

=cut

sub linear_regression {
  my($xref, $yref) = @_;
  my($sumxy, $sumx, $sumy, $sumx2, $cov, $var, $a, $b, @running);
  my(@x) = @{$xref};
  my(@y) = @{$yref};
  debug("X",@x,"Y",@y);
  my($n) = $#x+1;

  # empty list = special case
  if ($n==0) {return NaN,NaN,NaN;}

  # 1-elt list = special case?
  # TODO: is this really a special case?
  if ($n==1) {return NaN,NaN,$y[0];}

  # from wikipedia
  for $i (0..$#x) {
    $sumxy += $x[$i]*$y[$i];
    $sumx += $x[$i];
    $sumy += $y[$i];
    $sumx2 += $x[$i]*$x[$i];

    # convenience variable
    my($count) = $i+1;

    # intentionally computing this each time for "running regression"
    $cov = $sumxy/$count - $sumx*$sumy/$count/$count;
    $var = $sumx2/$count - $sumx*$sumx/$count/$count;
    if ($var) {
      $b = $cov/$var;
      $a = ($sumy-$b*$sumx)/$count;
    } else {
      ($a,$b) = ($y[0],0);
    }

    push(@running,$a,$b);
 }

  return $a,$b,$sumy,\@running;
}

=item fmodp($num, $mod)

Returns the same thing as fmod($num,$mod), but adds $mod if result
would be negative.

=cut

sub fmodp {
  my($num,$mod) = @_;
  my($res) = fmod($num,$mod);
  if ($res<0) {$res+=$mod;}
  return $res;
}

=item find_nearest_zenith($obj,$lat,$lon,$t0=now,$options)

Return Unix second of when $obj reaches zenith at $lat/$lon, close to
$time ($time should not be close to time of nadir)

$options:

nadir=1: find nearest nadir, not zenith
which=-1,0,1: if -1, find previous not nearest; +1 = find next not nearest
<h>abed=1: find nearest abed</h>

=cut

sub find_nearest_zenith {
  my($obj, $lat, $lon, $t0, $options) = @_;
  debug("GOT",@_);
  my(%opts) = parse_form($options);
  unless ($t0) {$t0=time();}
  my($time) = $t0;

  # run this loop forever, until sufficient accuracy reached
  for (;;) {

    # objects current ra/dec and az/el
    my($ra,$dec) = position($obj, $time);

    # find nadir instead?
    if ($opts{nadir}) {$ra = fmodp($ra+12,24);}
    debug("RA: $ra");

    # current local siderial time (between 0 and 24)
    my($lst) = fmodp(gmst($time) + ($lon/15), 24);

    # hours to zenith (assuming incorrectly that siderial hour = clock hour)
    # between 0 and 24
    my($hours) = fmodp($ra-$lst,24);
    debug("TIME: $time, LST: $lst, RA: $ra, HOURS: $hours");

    # .001 hour = .015 degrees = close enough
    if (abs($hours)<.001 || abs($hours-24)<.001) {

      # if we found next and they wanted previous...
      if ($opts{which}==-1 && $time > $t0) {
	# &which=0 below is a hideous way to force closest on the recursion
	return find_nearest_zenith($obj,$lat,$lon,$t0-86400,"$options&which=0");
      }

      # if we found perv and they wanted next...
      if ($opts{which}==1 && $time < $t0) {
	return find_nearest_zenith($obj,$lat,$lon,$t0+86400,"$options&which=0");
      }

      return $time;
    }

    # nextguess is time until location ra = object ra
    # we are using $time to store the guesses
    if ($hours>12) {
      $time += ($hours-24)*3600;
    } else {
      $time += $hours*3600;
    }
  }
}

=item inner_regex($str, $regex, $options)

Given string $str, replace $regex with token string that's guarenteed
not to appear in $str itself. Return the parsed string and a hash
mapping the replacement back to the original string.

$options currently unused

TODO: not super happy with [TOKEN-], don't really need it.

TODO: should I be using Perl::Tokenize or similar here?

=cut

sub inner_regex {
  my($str, $regex, $options) = @_;
  my($n, $token, %hash) = (0);
  my(@l);

  # find token not in string
  # TODO: this could theoretically fail, but unlikely
  # <h>the second statement below is dedicated to the
  # Society for the Prevention of Menstruation (ARGHHH)</h>
  do {$rand=rand(); $rand=~s/\.//;} until ($str!~/$rand/);

  $str=~s/($regex)/inner_regex_helper($1)/eg;

  sub inner_regex_helper {
    $hash{$rand}{$n} = shift;
    return "[TOKEN-$rand-$n]";
  }

  return $str, {%hash};
}

=item osm_cache_bc($lat,$lon)

Given the "lower left" (southwest) latitude/longitude of a 0.1x0.1
degree box, return the data for that box (and cache results)

Really only useful for stuff in OSM/ (so that all programs there use
the same caching scheme)

This function subsumes get_osm() in bc-osm-browser.pl

TODO: Memory caching here is probably a bad idea

=cut

sub osm_cache_bc {
  my($lat,$lon) = @_;

  # .2f just to make sure we're rounded to 2 digits
  # $sha is legacy variable name; sha1sum no longer involved
  # NOTE: I had the call to sprintf completely messed up earlier :(
  # The -.005 is for rounding
  # 0.7 added to get rid of 0.6 results
  my($sha) = sprintf("OSM-0.7-%.2f,%.2f",$lat-.005,$lon-.005);

  # is it already cached in memory?
  if ($shared{osm}{$sha}) {return $shared{osm}{$sha};}

  # no splitting into subdirectories
  my($dir) = "/var/cache/OSM/";

  # if file doesn't already exist, get it
  unless (-f "$dir/$sha") {
    my($cmd) = sprintf("curl -o $dir/$sha 'http://api.openstreetmap.org/api/0.6/map/?bbox=%.2f,%.2f,%.2f,%.2f'", $lon-.005, $lat-.005, $lon+.005, $lat+.005);
#    my($cmd) = sprintf("curl -Lo $dir/$sha 'http://api.openstreetmap.org/api/0.7/map/?bbox=%.2f,%.2f,%.2f,%.2f'", $lon-.005, $lat-.005, $lon+.005, $lat+.005);
    debug("CMD: $cmd");
    debug("OUT: $out");
    my($out, $err, $res) = cache_command($cmd);
  }

  debug("Returning cached info");
  $shared{osm}{$sha} = read_file("$dir/$sha");
  return $shared{osm}{$sha};
}

=item osm_map($lat, $lon, $zoom, $options)

Obtain and cache the level $zoom slippy? map for $lat, $lon Returns
name of file with PNG in it, and the x/y positions of $lat/$lon in
that PNG file (assuming 256x256 tiles). Options:

xy=1: assume $lat and $lon are x and y coordinates, do no conversion

=cut

sub osm_map {
  my($lat, $lon, $zoom, $options) = @_;
  my(%opts) = parse_form($options);
  my($x,$y,$px,$py);

  if ($opts{xy}) {
    ($x, $y) = ($lat,$lon);
    ($px,$py) = (-1,-1); # nonsensical
  } else {
    # convert to mercator
    ($y,$x) = to_mercator($lat, $lon);

    # figure out where in map $lat/$lon occurs
    ($x,$y) = ($x*2**$zoom, $y*2**$zoom);

    # for now, intentionally not rounding
    ($px, $py) = (($x-int($x))*256, ($y-int($y))*256);

    # use zoom to figure out canonical name
    $y = floor($y);
    $x= floor($x);
  }

  my($url) = "$zoom/$x/$y.png";
  my($fname) = "/var/cache/OSM/$zoom,$x,$y.png";

  # if it doesn't exist, get it
  unless (-f $fname) {
    cache_command("curl -o $fname http://tile.openstreetmap.org/$url");
  }

  return $fname,$px,$py;
}

=item slippy2latlon($x,$y,$zoom,$px,$py)

Return the latitude and longitude of the $px/$py point on a slippy map
whose zoom value is $zoom and whose x and y values are $x and $y

(mostly copied from bc-mytile.pl)

=cut

sub slippy2latlon {
  my($x,$y,$zoom,$px,$py) = @_;

  # convert x/y to scaled coordinates (and add in pixel)
  $x = ($x+$px/256)/2**$zoom;
  $y = ($y+$py/256)/2**$zoom;

  # and convert
  my($lat) = -90 + (360*atan(exp($PI - 2*$PI*$y)))/$PI;
  my($lon) = $x*360-180;

  return $lat,$lon;
}

=item closest($x0,$y0,$x1,$y1,$x2,$y2,$options)

Return the smallest distance between the point $x0,$y0 and the line
segment through ($x1,$y1) and ($x2,$y2), and the point on the line
where $x0,$y0 is closest

$options currently unused

TODO: allow closest distance to entire line, not just segment

=cut

sub closest {
  my($x0,$y0,$x1,$y1,$x2,$y2) = @_;

  # if x1,y1 to x2,y2 is parametrized by t, this t yields the smallest
  # distance see playground.m for more details; there does NOT appear
  # to be a simpler formula
  my($t) = ($x1**2-$x1*$x2+$x0*(-$x1+$x2)-($y0-$y1)*($y1-$y2))/($x1**2- 2*$x1*$x2+$x2**2+($y1-$y2)**2);

  # since we're limiting to segment, truncate t at 0,1
  $t = min(max($t,0),1);

  # point on segment where this min is acheived
  my($minx) = $x1+$t*($x2-$x1);
  my($miny) = $y1+$t*($y2-$y1);

  # and distance
  my($dist) = sqrt(($x0-$minx)**2 + ($y0-$miny)**2);

  return $dist,$minx,$miny;
}

=item rotrad($th, $ax="x|y|z")

The 3D matrix that rotates $th radians around the $ax axis

=cut

sub rotrad {
    my($th,$ax)=@_;
    my($si,$co)=(sin($th),cos($th));
    if ($ax eq "x") {return(([1,0,0],[0,$co,$si],[0,-$si,$co]));}
    if ($ax eq "y") {return(([$co,0,-$si],[0,1,0],[$si,0,$co]));}
    if ($ax eq "z") {return(([$co,-$si,0],[$si,$co,0],[0,0,1]));}
}

=item rotdeg($th, $ax="x|y|z")

Does exactly what rotrad does, but $theta is given in degrees

=cut

sub rotdeg {
    my($th,$ax)=@_;
    return(rotrad($th*$PI/180,$ax));
}

=item mylock($name,$action="lock|unlock|murder")

Takes the lock $name if $action = "lock"; returns the lock $name if
action = "unlock"

If $action = "murder", kill the process currently holding the lock and take it

returns 1 on success, 0 on failure (including case where lock already held)

If --ignorelock is set, always returns 1

TODO: improve this to only warn when asked

TODO: this code is hideous, improve it

TODO: keep track of things I lock/unlock so I can clean them up in sub END

TODO: create subdirs when needed

NOTE: relies on /proc, which is terrible

=cut

sub mylock {
  my($name,$action) = @_;
  my($lockdir) = "/usr/local/etc/locks";
  # reading this early (for a file that may not exist) is slightly ugly
  # avoiding read_file to avoid no such file error(?)
  my($text) = `cat $lockdir/$name 2> /dev/null`;

  # murder case
  if ($action eq "murder") {
    if ($text) {
      # try to kill process if it exts, fail if cant
      unless (kill_softly($text)) {return 0;}
    }
    # now, just a regular lock
    $action = "lock";
  }

  # global override (dangerous, assuming user knows what they're doing)
  if ($globopts{ignorelock}) {return 1;}

  # if unlocking...
  if ($action eq "unlock") {

    # check to see that I own lock file, then remove it
    if ($text eq $$) {
      unlink("$lockdir/$name");
      return 1;
    }

    # does lock belong to defunct process?
    if (-d "/proc/$text" && $text) {
      warnlocal("LOCK $name owned by living process $text, can't unlock");
      return 0;
    }

    # lock belongs to dead process
    warnlocal("LOCKFILE $name exists, but $text is dead or empty proc");
    unlink("$lockdir/$name");
    return 1;
  }

  # if locking or murdering...
  if ($action eq "lock") {

    # if lock doesn't exist, write my PID to it and return success
    unless ($text) {
      write_file($$,"$lockdir/$name");
      return 1;
    }

    # do I own it?
    if ($text eq $$) {
      warnlocal("LOCK $name already mine (not an error)");
      return 1;
    }

    # owned by a living process?
    if (-d "/proc/$text" && $text) {
      warnlocal("LOCK $name owned by living process $text");
      return 0;
    }

    # lock owned by dead proc
    warnlocal("LOCK owned by dead or null proc $text, replacing");
    write_file($$,"$lockdir/$name");
    return 1;

  }

  warnlocal("ACTION $action not understood");
  return 0;
}

=item gnumeric2array($file)

Converts a simple gnumeric spreadsheet (in raw form: ie, compressed
XML) to an array of arrays. Only works w/ very simple sheets

=cut

sub gnumeric2array {
  my($file) = @_;
  my($res) = join("",`zcat -f $file`);
  my(@ret);

  # ugly hack (required because of /s below)
  $res=~s%^.*?<gnm:Cells>\s*%%s;
  $res=~s%</gnm:Cells>.*$%%s;

  while ($res=~s%<gnm:Cell(.*?)>(.*?)</gnm:Cell>%%s) {
    my($info,$val) = ($1,$2);
    # extract row/col from info (TODO: error check)
    $info=~/Row="(.*?)" Col="(.*?)"/i;
    $ret[$1][$2] = $val;
  }

  return @ret;
}

=item obtain_weights($time, $until="")

Obtain all weights since $time from my "today" files until time $until
(given as unix seconds, treated as infinity if null [default]), return as
hash.

Another unbelievable useless function that only I use

=cut

sub obtain_weights {
  my($time, $until) = @_;
  my(@days, %rethash);

  # all days since $time (need +86400 to compensate for time zones?)
  for ($i=$time; $i<=time()+86400; $i+=86400) {
    push(@days, strftime("%Y%m%d.txt",localtime($i)));
  }

  my($days) = join(" ",@days);
  my(@res) = `cd /home/barrycarter/TODAY; egrep '#[0-9.]*%[0-9.]*%' $days 2> /dev/null`;

  for $i (@res) {
    # date/time
    $i=~/^(\d{8}\.)txt:(\d{6})/||next;
    my($datetime) = str2time("$1 $2");
    if ($until && $datetime>=$until) {next;}
    # ignore too early
    if ($datetime < $time) {next;}
    # weight
    $i=~/([\d\.]+)\#/||next;
    my($weight) = $1;
    $rethash{$datetime} = $weight;
  }

  return %rethash;

}

=item datediff($t1,$t2)

Return seconds between $t1 and $t2, both in format that str2time will accept

Mostly intended for command line calling

TODO: use "date -d" instead?

=cut

sub datediff {
  my($t1,$t2) = @_;
  return str2time($t2)-str2time($t1);
}

=item upc2upc($upc)

Converts a UPE-E code UPC-A code using
http://en.wikipedia.org/wiki/Universal_Product_Code

=cut

sub upc2upc {
  my($upc) = @_;
  my($check1, $check2);

  # <h>Unlike ISBN numbers, UPC codes do not contain Xs. This is an
  # Easter egg in my code, so I can prove people copied it. Of course,
  # this is open source, making the Easter egg pointless</h>

  unless ($upc=~/^[0-9x]+$/) {
    # return 'as is' for non-UPC
    # killed warning, just annoying since I know some queries arent
    # warn "NOT A UPC CODE: $upc";
    return $upc;
  }

  # vaguely hideous to use if/then/else here

  # already complete
  if (length($upc)==12) {return $upc;}

  # special case for me only
  if (length($upc)==11) {return "0$upc";}

  # UPC-E with check digit
  if (length($upc)==7) {
    $upc=~s/(.)$//;
    $check1 = $1;
  }

  # now the 0-9 cases (these are checkdigitless)
  # the dash is solely for my benefit and will be removed
  # TODO: Im sure theres a simpler way to do this (w/o using
  # Business:UPC or whatever). WARNING: hideous code ahead

  if ($upc=~/(..)(...)0/) {
    $upc = "0${1}000-00$2";
  } elsif ($upc=~/(..)(...)(1|2)/) {
    $upc = "0$1${3}00-00$2";
  } elsif ($upc=~/(...)(..)3/) {
    $upc = "0${1}00-000$2";
  } elsif ($upc=~/(....)(.)4/) {
    $upc = "0${1}0-0000$2";
  } elsif ($upc=~/(....)(5|6|7|8|9)/) {
    $upc = "0$1-0000$2";
  } else {
    warn("NOT A UPC-E CODE: $upc");
    return;
  }

  # strip hyphen
  $upc=~s/\-//isg;

  $check2 = compute_upc_check_digit($upc);

  if ($check1 && $check1 != $check2) {
    warn("Computed check digit doesnt match given check digit: $upc");
  }

  return "$upc$check2";
}

=item run_nagios_test($host, $service)

Runs the nagios test identified by $service on $host as a one-off

=cut

sub run_nagios_test {
  my($host, $service) = @_;

  # TODO: allow for alternate file here
  my($all) = read_file("/var/nagios/status.dat");

  # this relies a bit too heavily on order
  unless ($all=~m%\{.*?host_name=$host[^\}]*?service_description=$service.*?check_command=(.*?)\n%is) {
    warn "COULD NOT FIND: $host/$service";
    return;
  }

  my($cmd) = $1;

  # break command into pieces
  my(@cmd) = split(/\!/,$cmd);

  # assign to ENV vars
  # TODO: only supports 2 arguments (could use loop w/ eval but yeesh!)
  # TODO: check that $cmd[0] is "raw" or "bc" (but actually never "bc")
  # $cmd[0] intentionally ignored below
  $ENV{NAGIOS_ARG1} = $cmd[1];
  $ENV{NAGIOS_ARG2} = $cmd[2];
  $ENV{NAGIOS_HOSTNAME} = $host;

  my($res) = system("/home/barrycarter/BCGIT/NAGIOS/bc-nagios-test.pl");

  # TODO: make below work

#  my($out, $err, $res) = cache_command2("/home/barrycarter/BCGIT/NAGIOS/bc-nagios-test.pl");

#  debug("OUT: $out, ERR: $err, RES: $res");

  # TODO: make below part optional
  # force instant check as well
  $now = time();
  # this should work w 0 instead of $now?
  system ("echo '[0] SCHEDULE_FORCED_SVC_CHECK;$host;$service;0' >> /var/nagios/rw/nagios.cmd");
  return $res;
}

=item radecazel($ra, $dec, $lat, $lon, $time)

Return the azimuth and elevation of an object with right ascension $ra
and declination $dec, at latitude $lat and longitude $lon at Unix time
$time

=cut

sub radecazel {
  my($ra,$dec,$lat,$lon,$t)=@_;
  $ra*=$HOURRAD;
  $dec*=$DEGRAD;
  $lat*=$DEGRAD;
  $lon*=$DEGRAD;
  my($lst)=gmst($t)*$HOURRAD+$lon;
  my($ha,$az,$el)=($lst-$ra,,); 
  $az=atan2(-sin($ha)*cos($dec),cos($lat)*sin($dec)-sin($lat)*cos($dec)*cos($ha));
  $el=asin(sin($lat)*sin($dec)+cos($lat)*cos($dec)*cos($ha));
  return($az*$RADDEG,$el*$RADDEG);
}

=item next_email_fh(\*A)

Given a filehandle, return the header and body of the next email in
that filehandle (assumes nothing else uses or moves the pointed in A).

=cut

sub next_email_fh {
  my($fh) = @_;
  my($all, $seen);

  while (<$fh>) {
    # TODO: improve this... From line should contain env sender and date too
    # We stop when we see the next From (not the one from our own message)
    if (/^From \S+ (mon|tue|wed|thu|fri|sat|sun)/i && ++$seen>=2) {last;}
    $all .= $_;
  }

  # unread next line (unless eof)
  if (eof($fh)) {return;}
  seek($fh, -length($_), 1);
  # we have the entire message, split into head and body
  $all=~m/^(.*?)\n\n(.*)$/is;
  my($head,$body) = ($1,$2);

  # the equal sign as continuation
  $body=~s/\=\n//isg;

  return ($head,$body);
}

=item compute_upc_check_digit($upc)

Given an 11-digit UPC-A code (not a UPC-E code), compute the check
digit. Useful for computing UPC-E check digits after expansion.

http://en.wikipedia.org/wiki/Universal_Product_Code#Check_digits

=cut

sub compute_upc_check_digit {
  my($upc) = @_;
  my(@arr) = split(//,$upc);
  # we want arr to start with 1 to match instructions
  unshift(@arr,"");
  my($tot);

  # NOTE: Yes, I couldve written a for loop here
  for $i (1,3,5,7,9,11) {$tot += 3*$arr[$i];}
  for $i (2,4,6,8,10) {$tot += $arr[$i];}

  # <h>It vaguely bothers me this works; it bothers me more that I used it</h>
  return (10-($tot%10))%10;
}

=item arraywheaders2hashlist(\@array, $index="", $options)

Given an array of arrays where the first row is treated as a header
row, return a list of hashes mapping hash key (header) to value.

If $index set, return an additional hash (outside of the return array)
whose keys are the specified index on the hash, and whose value is the
hash itself

$options currently unused <h>but not for long!</h>

=cut

sub arraywheaders2hashlist {
  my($arrayref, $index, $options) = @_;
  my(@arr) = @{$arrayref};
  my(@ret);
  my(%hash) = ();
  my(%hash2) = ();

  # the header row's length
  my($len) = $#{$arr[0]};

  # starting at first NONheader row
  for $i (1..$#arr) {
    my(%hash) = ();

    # TODO: this is probably bad
    $hash{raw_array} = $arr[$i];

    for $j (0..$len) {
      $hash{$arr[0][$j]} = $arr[$i][$j];
    }
    push(@ret,\%hash);
    # set the key for the second hash to return
    $hash2{$hash{$index}} = \%hash;
  }

  return \@ret, \%hash2;
}


=item gnumeric2sqlite3($gnm, $tab, $sql)

Given a simple gnumeric spreadsheet (with a header row) in file $gnm,
construct a table $tab in the SQLite3 db $sql (any existing tables in
$sql named $tab will be destroyed)

=cut

sub gnumeric2sqlite3 {
  my($gnm,$tab,$sql) = @_;
  my(@cmds);

  # does using this function really help
  my(@arr) = gnumeric2array($gnm);

  # create the table
  push(@cmds, "BEGIN");
  push(@cmds, "DROP TABLE IF EXISTS $tab");
  my(@fields);

  for $i (@{$arr[0]}) {
    # sqlite3 will happily create tables with '*' in field names, but
    # it messes up other progs
    # TODO: tighten this up to alphanumerics only (not even spaces?)
#    $i=~s/\*//isg;
    push(@fields, "'$i'");
  }
  my($fields) = join(", ",@fields);
  push(@cmds, "CREATE TABLE $tab ($fields)");

  debug("ARR",@arr);
  # now, the rows
  for $i (1..$#arr) {
    # HACK: using consistent order to avoid fieldnames, works but icky
    @vals = ();
    for $j (0..$#fields) {
      $arr[$i][$j]=~s/\'/''/isg;
      push(@vals, "'$arr[$i][$j]'");
    }
    my($vals) = join(", ",@vals);
    push(@cmds,"INSERT INTO $tab VALUES ($vals)");
  }

  push(@cmds, "COMMIT");

  # TODO: better file naming here
  write_file(join(";\n",@cmds).";\n", "/tmp/commands.sql");
  # TODO: error checking <h>(not really, but I put it in to pretend)</h>
  system("sqlite3 $sql < /tmp/commands.sql");
}

=item wii_tennis($wl="W|L",$sc="0|15|30|40", $ns, $delta="")

Attempts to validate
http://orden-y-concierto.blogspot.de/2013/04/wii-sports-tennis-skill-points-system.html
by computing expected change in Wii Tennis skill level based on
victory/loss, losers point score $sc, new skill level $ns, and $delta,
the change in skill level.

TODO: generalize for non-Elisa/Sarah

=cut

sub wii_tennis {
  my($wl,$sc,$ns,$delta) = @_;
  my($asy);

  # TODO: make this hash "our" in bclib.pl?
  # note the +1200 adjustment for Elisa/Sarah
  my(%winhash) = (0=>1200+1200,15=>1050+1200,30=>900+1200,40=>800+1200);
  my(%losehash) = (0=>0+1200,15=>150+1200,30=>300+1200,40=>400+1200);

  # the asymptote
  if ($wl=~/^w/i) {
    $asy = $winhash{$sc};
  } elsif ($wl=~/^l/i) {
    $asy = $losehash{$sc};
  } else {
    warn "$wl is not w|l";
    return;
  }

  # the computed new score
  my($cns) = ($asy+19*($ns-$delta))/20;

  # TODO: more meaningful return value
  return $cns;
}

=item crossproduct($x1,$y1,$z1,$x2,$y2,$z2)

Return the vector cross product of {x1,y1,z1} and {x2,y2,z2}. Just
hardcodes the formula from Mathematica.

TODO: compute this myself and allow 3+ dimensions

TODO: probably should pass vectors as listrefs, not as 3 args each

=cut

sub crossproduct {
  my($x1,$y1,$z1,$x2,$y2,$z2) = @_;
  return ($y1*$z2-$y2*$z1, $x2*$z1-$x1*$z2, $x1*$y2-$x2*$y1);
}

=item dotproduct(\@v1,\@v2,$options)

Returns the dot product of v1 and v2 ($options currently unused)

=cut

sub dotproduct {
  my($v1ref,$v2ref,$options) = @_;
  my($res);
  my(@v1) = @{$v1ref};
  my(@v2) = @{$v2ref};
  for $i (0..$#v1) {$res+=$v1[$i]*$v2[$i];}
  return $res;
}

=item norm(\@v,$options)

Return the norm of vector v ($options currently unused)

<h>NORM!</h>

=cut

sub norm {
  my($vref) = @_;
  my(@v) = @{$vref};
  my($ret);
  for $i (@v) {$ret+=$i*$i;}
  return sqrt($ret);
}

=item vecapply(\@v1,\@v2,$f)

Apply the function $f (which must be a *string* not a function
reference) pointwise to v1 and v2, return the resulting vector.

NOTE: this would work WAY better if $f were a function reference, but
I plan to use simple builtin functions, and converting a simple
builtin function to a ref seems hard:
http://stackoverflow.com/questions/1585560/can-you-take-a-reference-of-a-builtin-function-in-perl

=cut

sub vecapply {
  my($v1ref,$v2ref,$f) = @_;
  my(@v1)= @{$v1ref};
  my(@v2)= @{$v2ref};
  my(@res);
  # in addition to being ugly, this is inefficient
  for $i (0..$#v1) {$res[$i] = eval("$v1[$i] $f $v2[$i]");}
  return @res;
}

=item gcstats($lat1,$lon1,$lat2,$lon2,$r)

Given two latitudes/longitudes in degrees, find the lat/lon point r
percentage of the way (0<=r<=1) between the first and second points
(true parametric circle, not projected parametrization of line);
return value is also in degrees

TODO: expand this to give more, incl distances and bearing

TODO: this is NOT efficient if computing for multiple $r (ie, if
computing a path)-- should I pass $r as a listref or something?

=cut

sub gcstats {
  my(@rads) = @_;
  # convert first 4 params to radians
  for $i (@rads[0..3]) {$i*=$DEGRAD;}
  my($lat1,$lon1,$lat2,$lon2,$r) = @rads;

  # the value of t for which v(t) is perpendicular to p1
  # (see greatcircle.m)
  my($t)=1/(1-cos($lat1)*cos($lat2)*cos($lon1-$lon2)-sin($lat1)*sin($lat2));

  # the xyz equivalents of two points
  my(@p1) = sph2xyz($lon1,$lat1,1);
  my(@p2) = sph2xyz($lon2,$lat2,1);

  # the straight line point r% from p1 to p2 (returned as xyz)
  my(@xyz) = vecapply([map($_*$r,@p2)],[map($_*(1-$r),@p1)],"+");

  # the value of the "thru the earth" line at $t, normalized
  my(@perp) = vecapply([map($_*(1-$t),@p1)],[map($_*$t,@p2)],"+");
  @perp = map($_/norm([@perp]),@perp);

  # angle between the two (dot products) + straight line ("thru earth") dist
  my($ang) = acos(dotproduct([@p1],[@p2]));
  my($dist) = norm([vecapply([@p1],[@p2],"-")]);

  # great circle now parametrized by @perp + @p1
  # the angle we want is $r*$ang (ie, r% of the whole angle)
  my(@fin) = vecapply([map($_*cos($r*$ang),@p1)], [map($_*sin($r*$ang),@perp)], "+");
  # back to spherical coords ($rdist should be 1, computed JFF)
  my($rlon,$rlat,$rdist) = xyz2sph(@fin,"degrees=1");

  # TODO: return this stuff way better
  return $rlat,$rlon,@xyz,$ang,$dist;
}

=item cache_command2($command, $options)

version 2: write name of command to file and use /var/tmp and multiple
levels of subdirectories to avoid filling /tmp and making it too
large. However, I broke several features when upgrading this function
(commented out options are broken in this version)

Runs $command and returns stdout, stderr, and exit status. If command
was run recently, return cached output. $options:

 salt=xyz: store results in file determined by hashing command w/ salt
 (useful if running multiple instances of the same command)

 age=n: if output file is less than n seconds old + no error, return cached

 fake=1: dont run the command at all, just say what would be done

 cachefile=x: use x as cachefile; dont use hash to determine cachefile name

# retry=n: retry command n times if it fails (returns non-0)
# sleep=n: sleep n seconds between retries
 # TODO: documentation for nocache below is wrong
# nocache=1: dont really cache the results (also global --nocache)
# retfile=1: return the filename where output is cached, not output itself
# ignoreerror: assume return code from command is 0, even if its not

=cut

sub cache_command2 {
  my($command,$options) = @_;
  my($now) = time(); # useful to know when run above/beyond file timestamp
  my($cached) = 0; # default: not cached
  my($file); # output file

  my(%opts) = parse_form($options);

  # if $command is a listref, we are evaluating a Perl function
  if (ref($command) eq "ARRAY") {
    debug("$command is array, doing Perl function");
    die "TESTING";
  }

  # TODO: global nocache means don't *USE* cached results
  # TODO: local nocache would mean don't CREATE cached results

  if ($opts{cachefile}) {
    $file = $opts{cachefile};
  } else {
    # determine "name" of tmpfile
    $file = sha1_hex("$opts{salt}$command$opts{salt}");
    # split into two levels of subdirs
    $file=~m/^(..)(..)/;
    my($d1,$d2) = ($1, $2);
    # put in /var/tmp/cache (add username to avoid collision)
    $file = "/var/tmp/cache/$d1/$d2/$file-$ENV{USER}";
    # make sure dir exists
    unless (-d "/var/tmp/cache/$d1/$d2") {
      # /tmp style directory
      system("mkdir -p /var/tmp/cache/$d1/$d2; chmod -f 1777 /var/tmp/cache/$d1 /var/tmp/cache/$d1/$d2");
    }
  }

  # TODO: slightly inefficient to compute this when unneeded
  my($fileage) = (-M $file)*86400;

  # NOTE: I was doing this all in one complex IF statement, but it is
  # easier to understand this way

  if ($globopts{nocache}) {
  # if global nocache, then not cached
    debug("--nocache, not cached");
  } elsif (!(-f $file && -s $file)) {
    # for cache_command2, zero size is impossible
    debug("$file does not exist (or has zero size), not cached");
  } elsif ($opts{age}<=0) {
    # setting age=-1 can be useful for testing (instead of just omitting age=)
    debug("opts{age} < 0, $file not cached");
  } elsif ($fileage > $opts{age}) {
    debug("$file age $fileage > opts{age} $opts{age}, not cached");
  } else {
    debug("result cached in $file ($fileage <= $opts{age})");
    $cached = 1;
  }

  unless ($cached) {
    # if fake, just say command would be run
    if ($opts{fake}) {return "NOT CACHED: $command";}
    # otherwise, run command
    my($res) = system("($command) 1> $file-out 2> $file-err");
    my($etime) = time();
    my($stdout,$stderr) = (read_file("$file-out"), read_file("$file-err"));
    # delete now unneeded files
    unlink("$file-out","$file-err");
    # write cached results to $file
    write_file(join("\n", (
			   "<caller>$0</caller>",
			   "<cmd>$command</cmd>",
			   "<time>$now</time>",
			   "<stdout>$stdout</stdout>",
			   "<stderr>$stderr</stderr>",
			   "<status>$res</status>",
			   "<etime>$etime</etime>",
			   "\n"
			   )), $file);
    # and return them
    return $stdout, $stderr, $res;
  }

  # reamining case, cached result exists
  # if faking, just indicate cache exists
  if ($opts{fake}) {return "CACHED: $command";}
  debug("CACHED, returning contents of $file");

  # read/parse/return cached value
  my($cached) = read_file($file);

  # TODO: this is seriously hacky and must stop
  $cached=~s%^<caller>.*?</caller>\s*%%isg;

  # TODO: allow myself to add more tags without having to rewrite
  # below constantly?
  unless ($cached=~m%^\s*<cmd>(.*?)</cmd>\s*<time>(.*?)</time>\s*<stdout>\s*(.*?)\s*</stdout>\s*<stderr>\s*(.*?)\s*</stderr>\s*<status>(.*?)</status>%s) {
    warn "BROKEN CACHE FILE: $file";
    return;
  }

  # bad form to return $2, $3, $4 "as is"?
  my($stdout,$stderr,$res) = ($3,$4,$5);
  return $stdout, $stderr, $res;
}

=item my_tmpfile2()

Returns a non-existant file in /var/tmp/xx/yy/ that can be used as a
temp file (creates parent directories as needed). Similar to
my_tmpfile() but uses sub directories to avoid overfilling /tmp

=cut

sub my_tmpfile2 {
  my($d1,$d2,$x);
  do {
    # pid and username helps prevent collision
    $x = sha1_hex(rand().$$.$ENV{USER});
    # split into two levels of subdirs
    $x=~m/^(..)(..)/;
    ($d1,$d2) = ($1, $2);
    # make sure dir exists
    unless (-d "/var/tmp/cache/$d1/$d2") {
      # use /tmp permissions/mode
      system("mkdir -p /var/tmp/cache/$d1/$d2; chmod -f 1777 /var/tmp/cache/$d1 /var/tmp/cache/$d1/$d2");
    }
  } until (!(-f "/var/tmp/cache/$d1/$d2/$x"));
  # mark as tempfile for later deletion + return
  $is_tempfile{"/var/tmp/cache/$d1/$d2/$x"}=1;
  return "/var/tmp/cache/$d1/$d2/$x";
}

=item affirm($key)

affirm user has typed a given $key ($key="" is an acceptable value).

-affirm autoaffirms everything

=cut

sub affirm {
  my($aa)=@_;
  if ($globopts{affirm}) {return;}
  $ab=lc(<STDIN>);
  chomp($ab);
  unless ($ab eq $aa) {die("AFFIRM FAILED: $ab ne $aa");}
  return();
}

=item voronoi_map(\@hashlist, $options)

Given @hashlist, a list of hashrefs, return a KML map (KMZ file)
representing the voronoi diagram. Each hash must have at least these
keys: id, x, y, label, color (KML-style); id must be unique

Primarily intended for latitude/longitude "google style" maps

The KMZ file should be copied, not used directly

$options currently unused

TODO: this seems to leave off one (or more?) points, not sure why

TODO: option for placemarks at the points themselves

=cut

sub voronoi_map {
  my($hashlistref, $options) = @_;
  my(@hashlist) = @{$hashlistref};
  my($tmpfile) = my_tmpfile("voronoi");
  local *A;
  open(A,">$tmpfile.kml");

  # header/footer
  my($header) = read_file("/usr/local/lib/kmlhead.txt");
  my($footer) = read_file("/usr/local/lib/kmlfoot.txt");
  print A "$header\n";

  # the Voronoi diagram
  my(@vor);
  for $i (@hashlist) {
    debug("I: $i");
    push(@vor, $$i{x}, $$i{y});
  }
  my(@tess) = voronoi(\@vor);

  debug("TESS",@tess,"ENDTESS");

  # the chunk for each polygon
  for $i (0..$#tess) {
    # not each point pair has a polygon
    unless ($tess[$i]) {next;}
    my(@points);
    # hash in @hashlist corresponding to this polygon
    my(%hash) = %{$hashlist[$i]};
    debug("I: $tess[$i], II: %hash");
    # polygon header
    my($body) = << "MARK";
<Placemark><styleUrl>#$hash{id}</styleUrl>
<description>$hash{label}</description>
<Polygon><outerBoundaryIs><LinearRing><coordinates>
MARK
;
    # style URL
    my($style) = << "MARK";
<Style id="$hash{id}">
<PolyStyle><color>$hash{color}</color>
<fill>1</fill><outline>0</outline></PolyStyle></Style>
MARK
;

    # the points for this polygon (pointless polygons OK w/ google)
    for $j (@{$tess[$i]}) {
    $j=~s/ /,/;
    push(@points, $j);
  }
    my($tail) = "</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>";

    print A "$body\n",join("\n",@points),"\n","\n$tail\n",$style,"\n";
  }

  print A $footer;
  close(A);
  system("zip $tmpfile.kmz $tmpfile.kml");
  return "$tmpfile.kmz";
}

=item parse_metar($metar)

Converts a METAR report into a hash (matches weather2.sql format)

TODO: handle SLP + maybe other fields

=cut

sub parse_metar {
  my($a)=@_;
  debug("parse_metar($a)");

  my(%b)=(); # to hold results
  my(@clouds)=(); # to hold multiple clouds
  my(@weather)=(); # multiple weathers
  my(@leftover)=(); # anything i can't parse

  # we want to store the full metar
  $b{observation}=$a;

  # fix things like "2 1/2SM" and "3/4SM", eval to avoid div by zero death
  eval {$a=~s!(\d+)\s+(\d)/(\d)sm!eval($1+$2/$3)."SM"!ie};
  eval {e$a=~s!(\d)/(\d)sm!eval($1/$2)."SM"!ie};

  # split METAR by spaces
  @b=split(/\s+/,$a);

  # first field is always station
  $b{id}=shift(@b);

  # second field is ddhhmm in GMT
  $aa=shift(@b);

  if ($aa=~/(\d{2})(\d{2})(\d{2})z/i) {
    ($day,$hour,$min)=($1,$2,$3);
  } else {
    return ("ERROR" => "INVALID TIME: $aa");
  }

  # need to figure out month and year (only really an issue at month change)

  # current time/date (just need month and year)
  my($ignore,$ignore,$ignore,$mday,$mon,$year) = gmtime();
  # Perl bizzarely counts months 0..11, and year 0 is 1900
  $mon++;
  $year+=1900;

  # if report date is in future, subtract one month
  debug("CURRENT TIME: ",time());
  debug("$year-$mon-$day $hour:$min");
  debug("REPORT TIME:", str2time("$year-$mon-$day $hour:$min"));

  if (str2time("$year-$mon-$day $hour:$min UTC") > time()) {
    $mon--;
    if ($mon==0) {$year--; $mon=12;}
  }

  # we will return time in sqlite3 format
  $b{time} = "$year-$mon-$day $hour:$min:00";
  debug("TIME: $b{time}");

  # remaining fields may be in any order
  for $i (@b) {

    # trim trailing equals
    $i=~s/\=$//;

    # wind direction/speed
    if ($i=~/^(\d{3}|vrb)(\d{2})kt/i) {
      ($b{winddir},$b{windspeed})=($1,$2);
      next;
    }

    # wind direction/speed (gusting)
    if ($i=~/^(\d{3}|vrb)(\d{2})g(\d{2})kt/i) {
      ($b{winddir},$b{windspeed},$b{gust})=($1,$2,$3); 
      next;
    }

    # visibility
    if ($i=~s/sm$//i) {
      # we no longer assign visibility since its not in weather2.sql
#      $b{visibility}=$i;
      next;
    }

    # temp/dew point in C (whole degrees)
    # more than 3 digits = bad
    if ($i=~m!^(M?\d{1,3})/(M?\d{1,3})$!) {
      # if we already have a more accurate temperature from RMK, ignore this
      if (exists $b{temperature}) {next;}

      ($b{temperature},$b{dewpoint})=($1,$2);
      if ($b{temperature}=~s/^m//i) {$b{temperature}*=-1;}
      if ($b{dewpoint}=~s/^m//i) {$b{dewpoint}*=-1;}
      next;
    }

    # some reports have temperature only, no dewpoint
    if ($i=~m!^(M?\d{1,3})/$!) {
      # if we already have a more accurate temperature from RMK, ignore this
      if (exists $b{temperature}) {next;}

      $b{temperature}=$1;
      if ($b{temperature}=~s/^m//i) {$b{temperature}*=-1;}
      next;
    }

    # RMK section sometimes has more accurate temperature and dewpoint
    if ($i=~m!^t(\d)(\d{3})(\d)(\d{3})$!i) {
      ($b{temperature},$b{dewpoint})=((-2*$1+1)*$2/10,(-2*$3+1)*$4/10);
      next;
    }

    # Barometric pressure in inches
    if ($i=~/^a(\d{4})/i) {
      $b{pressure}=$1/100; 
      next;
    }

    # Barometric pressure in millibars; we convert to inches for consistency
    if ($i=~/q(\d+)/i) {
      if (exists $b{pressure}) {next;}
      $b{pressure}=round2(convert($1,"mb","in"),2);
      next;
    }

    # Note down how much cloud cover there is
    if ($i=~/^(clr|few|sct|bkn|ovc)/i) {push(@clouds,$i); next;}

    # signifigant weather
    if ($i=~/^([\+\-]?)($abbrevs|)($abbrevs)$/i) {
      # TODO: this returns "-RA", need to return "light rain"
      push(@weather,$i);
      next;
    }

    # Was this report automatically generated? (not used)
#    if ($i eq "AUTO") {$b{type}="AUTO"; next;}

    # uninteresting stuff (data on sensors, sea-level pressure,
    # non-aviation temperature, remarks separator); we preserve this
    # in the METAR field (and leftover field) but don't break it out
    # into separate fields

    if ($i=~/^ao\d$/i || $i=~/^slp\d+$/i || $i=~/^4(\d{8})$/|| $i eq "RMK") {
      next;
    }

    push(@leftover,$i);
  }

  # combine lists into strings (but no leftover, we can't use it)
  if (@clouds) {
    $b{cloudcover}=join(" ",@clouds);
  } else {
    $b{cloudcover} = "NULL";
  }

  if (@weather) {
    $b{events}=join(" ",@weather);
  } else {
    $b{events} = "NULL";
  }

#  $b{leftover}=join(" ",@leftover);


  # convert units as needed
  $b{windspeed} = round2(convert($b{windspeed},"kt","mph"));
  $b{temperature} = round2(convert($b{temperature}, "c", "f"),1);
  $b{dewpoint} = round2(convert($b{dewpoint}, "c", "f"),1);

  return(%b);
}

=item round2($num,$digits)

Round $num to $digits digits, but preserve NULLs (empty = NULL)

=cut

sub round2 {
  my($num,$digits) = @_;
  # TODO: improve this to deal with other strings
  if ($num eq "NULL" || $num eq "") {return "NULL";}
  return sprintf("%0.${digits}f", $num);
}

=item column_data($data, [@columns])

Given a line of data and a list of column positions, return data
corresponding to those columns

=cut

sub column_data {
  my($data,$colref) = @_;
  my(@cols) = @{$colref};
  my(@res);

  for $j (0..$#cols) {
    push(@res,substr($data, $cols[$j], $cols[$j+1]-$cols[$j]));
  }

  return @res;
}

=item get_raws_obs()

Obtain weather information from http://raws.wrh.noaa.gov/rawsobs.html

NOTE: Temperatures are in Farenheit and wind speeds are in mph <h>also
known as the "good" or "correct" units</h>

RAWS does not provide: pressure <h>("you can not handle
PRESSURE!")</h>, cloudcover, events

TODO: maybe use solar radiation readings (could be used to determine
cloudcover maybe)

=cut

sub get_raws_obs {
  my(@res);
  # chdir to correct directory (creating it if needed, die if still no)
  system("mkdir -p /var/tmp/raws");
  dodie('chdir("/var/tmp/raws")');
  # index page almost never changes
  my($out,$err,$res) = cache_command2("curl http://raws.wrh.noaa.gov/rawsobs.html", "age=86400");
  # use parallel
  local(*A);
  open(A, "| parallel -j 10");
  my(@stns);

  # find hrefs and push to "well known" files
  while ($out=~s%"(http://raws.wrh.noaa.gov/.*?)"%%s) {
    my($url) = $1;
    unless ($url=~/stn\=(.*)/s) {next;}
    my($stn) = $1;
    push(@stns,$stn);
    # if we have a file less than an hour old, do nothing
    if (-f $stn && -M $stn < 1/24.) {next;}
    print A "curl -o $stn '$url'\n";
  }
  close(A);

  # now look thru data
  for $i (@stns) {
    my(%hash);
    my($data) = read_file($i);
    # get lat/lon/name/id
    $data=~s/^.*?\={20,}\s*(.*?)(\r|\n)+.*\={20,}\s+//s;
    my($meta) = $1;
    # if there is absolutely no data, no point in doing more
    unless ($data) {
      debug("$i: NO DATA");
      next;
    }

    # fixed for RAWS
    $hash{type} = "RAWS";
    $hash{source} = "http://raws.wrh.noaa.gov/rawsobs.html";

    # info not provided
    for $j ("pressure", "cloudcover", "events") {$hash{$j} = "NULL";}

    # first 23 chars are name (w/ spaces)
    $meta=~s/^(.{23})//;
    $hash{name} = $1;
    $hash{name}=~s/\s*$//isg;
    # then id, elev, lat, lon (elev is in ft!)
    my($lat,$lon);
    # we do NOT use GOES ID
    ($hash{id},$hash{elevation},$lat,$lon) = split(/\s+/, $meta);
    # using more familiar id here, overriding above
    $hash{id} = $i;
    # correct lat/lon
    unless ($lat=~m/^(\d+):(\d+):(\d+)$/) {warn "BAD LAT: $lat";}
    $hash{latitude} = $1+$2/60+$3/3600;

    unless ($lon=~m/^(\d+):(\d+):(\d+)$/) {warn "BAD LON: $lon";}
    # all longitudes are negative
    $hash{longitude} = -1*($1+$2/60+$3/3600);

    # of what remains first line is now current data
    $data=~s/\n.*$//isg;
    $hash{observation} = $data;
    $hash{observation}=~s/\s+/ /isg;
    my(@data) = column_data($data, [25,28,33,39,43,48,67,74]);
    # remove spaces/slashes
    for $j (@data) {$j=~s/[\s\/]//isg;}
    my($day,$time,$jnk);
    ($day,$time,$hash{temperature},$hash{dewpoint},$wind,$jnk,$gust) = @data;

    # parse wind
    unless ($wind=~/^(..)(..)$/) {warn "BAD WIND: $wind";}
    $hash{winddir} = $1*10;
    $hash{windspeed} = $2;
    if ($gust=~/g(\d+)/) {$hash{gust} = $1;} else {$hash{gust} = "NULL";}

    # parse time and date (don't need 00 minute)
    $time=~/(\d{2})(\d{2})/||warn("BAD TIME: $time");
    my($hr,$mi) = ($1, $2);
    my($today) = strftime("%d", gmtime(time()));
    if ($day <= $today+1) {
      $hash{time} = strftime("%Y-%m-$day $hr:$mi:00", gmtime(time()));
    } else {
      my($year, $month) = split(/\-/, strftime("%Y-%m", gmtime(time())));
      $month--;
      if ($month < 0) {$year--; $month=12;}
      $hash{time} = "$year-$month-$day $hr:$mi:00";
    }

    # check for "MM" values (and convert to null)
    for $j (keys %hash) {if ($hash{$j} eq "MM") {$hash{$j} = "NULL";}}

    # push to result
    push(@res, {%hash});
  }

  return @res;
}

=item xmessage($message, $bg)

Shows a message in an Xwindow using xmessage + waits for reply (if $bg
is set, do not wait for reply, and background xmessage)

=cut

sub xmessage {
  my($msg,$bg) = @_;
  my($BGCHAR);
  my($tempfile)=my_tmpfile("xmess");
  write_file("Message from $0 at ".`date`.$msg, $tempfile);
  if ($bg) {$BGCHAR="&";}
  # revert to home directory to avoid problems
#  my($ret)=system("cd; xmessage -geometry 1024 -nearmouse -file $tempfile -buttons OK:0,BAD:2 -default OK 1> $tempfile.out 2> $tempfile.err $BGCHAR");
  # hard coded change 23 Oct 2018, sigh
  my($ret)=system("cd; xmessage -geometry 1600 -nearmouse -file $tempfile -buttons OK:0,BAD:2 -default OK 1> $tempfile.out 2> $tempfile.err $BGCHAR");
  # don't kill temp file too fast
  if ($bg) {sleep(1); return 0;}
  # if not backgrounding, read result
  if($ret || (-s "$tempfile.err")) {
    my($aa)=read_file("$tempfile.err");
    die("Got back non-zero $ret or non-empty STDERR ($aa) from xmessage");
  }
}

=item sunmooninfo($lon,$lat,$time=now)

Return hash of info about the sun/moon at $lon, $lat at time $time

=cut

sub sunmooninfo {
  my($lon,$lat,$time) = @_;
  my(%info); # return hash
  unless ($time) {$time=time();}
  debug("TIME: $time");

  # construct observer
  my($observer) = Astro::Nova::LnLatPosn->new("lng"=>$lon,"lat"=>$lat);
  # jd2unix() would also do this
  my($jd) = get_julian_from_timet($time);

  # sidereal time
  $info{sidereal_time} = fmodp(get_apparent_sidereal_time($jd)+$lon/15,24);

  # to hold results
  my(%rst);

  # independent of $observer (next few lines)
  $rst{sunpos} = get_solar_equ_coords($jd);
  $rst{moonpos} = get_lunar_equ_coords($jd);
  # ugly way to get whether phase is increasing, but no other way?
  my($p1) = get_lunar_phase($jd); 
  my($p2) = get_lunar_phase($jd-1/100000.);
  # I count phases "backwards"
  $info{moon}{phase} = 180-$p1;
  $info{moon}{dir}=($p2>$p1);

  $rst{sunaa} = get_hrz_from_equ($rst{sunpos}, $observer, $jd);
  $rst{moonaa} = get_hrz_from_equ($rst{moonpos}, $observer, $jd);

  for $i ("ra", "dec") {
    for $j ("sun", "moon") {
      $info{$j}{$i} = eval("\$rst{${j}pos}->get_$i()");
    }
  }

  # and the altaz
  for $i ("alt", "az") {
    for $j ("sun", "moon") {
      $info{$j}{$i} = eval("\$rst{${j}aa}->get_$i()");
    }
  }

  ($stat,$rst{sun})=get_solar_rst_horizon($jd, $observer, -5/6.);
  ($stat,$rst{moon})=get_lunar_rst($jd, $observer);

  for $i ("rise", "set", "transit") {
    for $j ("sun", "moon") {
      # hideous coding, hideous use of eval
      $info{$j}{$i}=eval("get_timet_from_julian(\$rst{$j}->get_$i())");
    }
  }

  my($stat,$rst) = get_solar_rst_horizon($jd, $observer, -6.);
  $info{sun}{dawn} = get_timet_from_julian($rst->get_rise());
  $info{sun}{dusk} = get_timet_from_julian($rst->get_set());
  return %info;
}

=item np_rise_set($lon, $lat, $time=now, $obj="sun|moon", $which="rise|set", $dir="-1|1")

Gives the next/previous rise/set time of the sun/moon for an observer
at $lon, $lat at time $time

TODO: add various twilights

=cut

sub np_rise_set {
  my($lon, $lat, $time, $obj, $which, $dir) = @_;
  unless ($time) {$time = time();}
  my($observer,$jd,$stat,$data,$eventtime,$tempfunc);

  # for speed reasons, can not use sunmooninfo()
  # TODO: allow sunmooninfo to provide one or the other if desired
  $observer = Astro::Nova::LnLatPosn->new("lng"=>$lon,"lat"=>$lat);
  $jd = get_julian_from_timet($time);

  # the various twilights
  if ($obj=~/astro/i) {
    $tempfunc = sub {return get_solar_rst_horizon(@_,-18);}
  } elsif ($obj=~/naut/i) {
    $tempfunc = sub {return get_solar_rst_horizon(@_,-12);}
  } elsif ($obj=~/civ/i) {
    $tempfunc = sub {return get_solar_rst_horizon(@_,-6);}
  } elsif ($obj=~/sun/i) {
    $tempfunc = sub {return get_solar_rst_horizon(@_,-5/6);}
  } elsif ($obj=~/moon/i) {
    $tempfunc = sub {return get_lunar_rst(@_);}
  } else {
    warn "$obj not understood";
    return;
  }

  # have to start 1 day in the wrong direction to avoid missing next set/etc
  for (my($i)=$jd-$dir; $i<=2465789; $i+=$dir/2.) {
    ($stat, $data) = &$tempfunc($i, $observer);
    $eventtime = eval("\$data->get_$which()");
    # eventtime must meet sorting criteria wo being insanely high/low
    if ($dir==+1 && $eventtime>=$jd && $eventtime <= 2465789) {last;}
    if ($dir==-1 && $eventtime<=$jd && $eventtime >= 2440587) {last;}
  }

  return get_timet_from_julian($eventtime);
}

=item dec2deg($deg)

Convert $deg to sign (+ or -), degrees, minutes, seconds (return list
of 4 items), such that degrees/minutes/seconds are all positive

TODO: if ignoring seconds on return, minutes are rounded incorrectly

=cut

sub dec2deg {
  my($deg) = @_;
  return $deg>=0?"+":"-", floor(abs($deg)), floor(abs($deg)*60)%60,
    round(abs($deg)*3600)%60;
}

=item kill_softly($pid)

Attempts to kill $pid, normally at first, but using -9 if
necessary. Returns 1 on success, 0 on failure (which can occur even
with kill -9).

NOTE: relies on /proc which is terrible

=cut

sub kill_softly {
  my($pid) = @_;
  my($sig);

  for $i (0..6) {
    # try killing
    if ($i>=4) {$sig="-9";} else {$sig="";}
    system("kill $sig $pid");
    # worked?
    unless (-d "/proc/$pid") {return 1;}
    # if not, sleep 1s before next try
    sleep(1);
  }

  # still alive?
  if (-d "/proc/$pid") {return 0;}
  return 1;
}

=item mooninfo($t)

Return, as a list, the moons age at time $t, the closest major phase,
and the time to/from that major phase.

Phases: 0 = new, 1 = first quarter, 2 = full, 3 = last quarter, 4 = new

Astro::MoonPhase::phase() does NOT return the correct age

=cut

sub mooninfo {
  my($t) = @_;
  my(%rethash);

  my(@phases) = phasehunt($t);
  my($age) = ($t-$phases[0])/86400;

  # closest phase
  my(@phasedist) = sort {abs($phases[$a]-$t) <=> abs($phases[$b]-$t)} (0..4);

  return ($t-$phases[0])/86400, $phasedist[0], ($t-$phases[$phasedist[0]])/86400;
}

=item option_check(\@list)

Confirms that all global options are in @list (or are global options
that this library understands

=cut

sub option_check {
  my($listref) = @_;
  my(@l) = @{$listref};
  push(@l, @globopts);
  my(%l) = list2hash(@l);

  for $i (keys %globopts) {
    unless ($l{$i}) {
      die("OPTION NOT UNDERSTOOD: $i");
    }
  }
}

=item bc_check_mount($fs)

Checks that $fs is mounted (I know exchange.nagios.org has this, but
using my own version).

=cut

sub bc_check_mount {
  my($fs) = @_;

  # stolen from bc-elec-snap which did this first
  # get the devno for the root device
  my($out, $err, $res) = cache_command("/usr/local/bin/stat / | grep -i device:");
  unless ($out=~m%device: (.*?)\s+%i) {
    print "ERR: could not stat /\n";
    return 2;
  }

  my($devroot) = $1;
  my($out, $err, $res) = cache_command("timed-run 60 /usr/local/bin/stat $fs | grep -i device:");
  unless ($out=~m%device: (.*?)\s+%i) {
    print "ERR: could not stat $fs, stdout/err is: $out/$err/$res\n";
    return 2;
  }

  my($fsroot) = $1;

  if ($devroot eq $fsroot) {
    print "ERR: / and $fs have same device number, not mounted\n";
    return 2;
  }

  debug("$devroot vs $fsroot");
  return 0;
}


=item findroot2(\&g, $le, $ri, $e, $options)

Does what findroot() does but chooses more intelligent midpoints
optinally using "secant method" (plus minor coding improvements)

Find where g [a one-argument function] reaches 0 (to an accuracy of
$e) between $le and $ri. Stop if $opts{maxsteps} reached before specified
accuracy. Options:

delta: stop and return when the x difference reaches this value,
regardless of difference if y value

method:
  - mid: use midpoint method (default [not always fastest, but no spec cases])
  - weight: use weighted method
  - weight2: use double weighted method

=cut

sub findroot2 {
  my($g,$le,$ri,$e,$options)=@_;
  debug("FINDROOT2($f,$le,$ri,$e,$options)");
  my(%opts) = parse_form("maxsteps=50&method=mid&$options");
  # TODO: not happy about this, but needed for real number equivalence?
  my($zeroval) = 5e-8;
  my($steps,$mid,$fmid,$fle,$fri);

  # wrap g in a cache function
  my(%cache);
  my($f) = sub {
    unless ($cache{$_[0]}) {$cache{$_[0]}=&$g($_[0])};
    return $cache{$_[0]};
  };

  # loop "forever"
  for (;;) {
    # count steps; return what we have so far if too many
    if ($steps++>$opts{maxsteps}) {
      warnlocal("TOO MANY STEPS");
      return $mid;
    }

    # value of the function at interval edges
    # TODO: would caching f() be useful?
    ($fle,$fri)=(&$f($le),&$f($ri));

    # same sign on both sides of interval? bad!
    if (signum($fle) == signum($fri)) {
      warnlocal("INVALID BINARY SEARCH");
      return();
    }

    # the "target" is the negative of the half smaller absolute value
    # for more rapid convergence
    my($target);
    if (abs($fle) > abs($fri)) {$target = $fri/-2.;} else {$target = $fle/-2.;}

    # determine midpoint based on method
    if ($opts{method}=~/weight/) {
      $mid = ($ri*$fle - $le*$fri)/($fle-$fri); 
    } elsif ($opts{method}=~/weight2/) {
      $mid = ($le*($target-$fri) + $ri*($fle-$target))/($fle-$fri);
    } else {
      $mid = ($le+$ri)/2.;
    }

    # however, if "midpoint" is $le or $ri, nudge it
    if (abs($mid-$le) < $zeroval) {$mid = $le+$zeroval;}
    if (abs($mid-$ri) < $zeroval) {$mid = $ri-$zeroval;}
    $fmid=&$f($mid);

    debug("$le -> $fle, $mid -> $fmid, $ri -> $fri");

    # is x delta small?
    if ($opts{delta}&&(abs($ri-$le)<$opts{delta})) {return $mid;}

    # close enough? return midpoint
    if (abs($fmid)<$e) {return $mid;}

    # $mid now becomes either the right or left endpoint
    if (signum($fmid) == signum($fle)) {$le = $mid;} else {$ri = $mid;}
  }
}

=item signum($x)

Returns whether x is positive, negative, or 0.

=cut

sub signum {
  my($x) = @_;
  if ($x>0) {return 1;}
  if ($x<0) {return -1;}
  return 0;
}

=item get_usno_calendar($year, $longitude, $latitude, $type="[mscna]"

Obtain the USNO moon/sun rise/set/twilight table for $year at
$longitude, $latitude
(http://aa.usno.navy.mil/data/docs/RS_OneYear.php).

Placename is always blank, timezone is always GMT, no DST corrections.

This is primarily to compare Astro::Nova to USNO, especially at
extreme latitudes.

$type is:

m - moonrise/set
s - sunrise/set
c - civil twilight
n - nautical twilight
a - astronomical twilight

=cut

sub get_usno_calendar {
  my($year, $longitude, $latitude, $type) = @_;

  # converts $type to value of type for USNO
  my(%convert)=("s"=>0,"m"=>1,"c"=>2,"n"=>3,"a"=>4);
  unless (length($convert{$type})) {warn "$type not understood"; return;}

  # if we have this cached return it
  my($file) = "/usr/local/etc/astro/$year,$longitude,$latitude,$type";
  if (-f $file) {return $file;}

  # the post URL
  my($url) = "http://aa.usno.navy.mil/cgi-bin/aa_rstablew.pl";

  # xx0 = sign of longitude, xx1 = degrees of longitude, xx2 = minutes of long.
  # yy[012] = same for latitude

  # longitude string
  my(@l) = dec2deg($longitude);
  my($lnstring) = sprintf("xx0=%d&xx1=%d&xx2=%d", $l[0] eq "-"?-1:1, $l[1], $l[2]);

  # latitude string
  @l = dec2deg($latitude);
  my($latstring) = sprintf("yy0=%d&yy1=%d&yy2=%d", $l[0] eq "-"?-1:1, $l[1], $l[2]);

  # zz0 = sign of timezone, zz1 = value of timezone, xxy= year
  # FFX=2: using second form on page; ZZZ=END (necessary)
  my($str) = "FFX=2&xxy=$year&type=$convert{$type}&zz1=0&zz0=1&$lnstring&$latstring&ZZZ=END";

  # its somewhat surprising that USNO accepts GET values, but they do
  my($out,$err,$res) = cache_command2("curl -o $file '$url?$str'","age=86400");
  return $file;
}

=item fmodn($num, $mod)

Returns the same thing as fmod($num,$mod), result is between -$mod/2
and +$mod/2

=cut

sub fmodn {
  my($num,$mod) = @_;
  my($res) = fmod($num,$mod);
  # TODO: does this work if $mod is negative?
  if ($res<-$mod/2) {return $res+$mod;}
  if ($res>$mod/2) {return $res-$mod;}
  return $res;
}

=item unixsort($s1,$s2,$soptions)

Sort strings $s1 and $s2 as they would be sorted by "sort $soptions"
in Unix. Useful for bc-sgrep.pl when sorted file is not in 'locale'
order. Returns -1, 0, 1, just as <=> or cmp would

=cut

sub unixsort {
  my($s1,$s2,$soptions) = @_;
  debug("unixsort($s1,$s2,$soptions)");
  # special case
  if ($s1 eq $s2) {return 0;}
  chdir(tmpdir());
  write_file("$s1\n$s2", "sortme");
  system("sort $soptions sortme | head -1 > sortme-sorted");
  # TODO: this is ugly
  my($rf) = read_file("sortme-sorted");
  chomp($rf);
  if ($rf eq $s1) {return -1;}
  if ($rf eq $s2) {return +1;}
  warn("unixsort($s1,$s2) failed");
  return NaN;
}

=item current_line(\*A, $delim="\n", $whence=1)

Seeks backwards in filehandle A to find the start of the current line
(as identified by delimiter $delim), returns that line, and seeks
forward to next delimiter.

If $whence = -1, seek to previous delimiter

=cut

sub current_line {
  my($fh, $delim, $whence) = @_;
  unless ($delim) {$delim="\n";}
  unless ($whence) {$whence=1;}
  my($char,@char);

  # read backwards (TODO: this is inefficient?)
  do {
    read($fh,$char,1);
    # TODO: why does SEEK_CUR not work below?
    seek($fh,-2,1);
  } until ($char eq $delim || tell($fh)==0);

  # store this in case $whence is -1 (0 if we've hit start of file)
  my($pos) = 0;
  # restore file position (unless we've hit start of file)
  if (tell($fh)) {
    $pos = tell($fh);
    seek($fh,+2,1);
  }

  # and now scan forwards
  do {
    read($fh,$char,1);
    push(@char, $char);
  } until ($char eq $delim || eof($fh));

  if ($whence==-1) {seek($fh,$pos,SEEK_SET);}

  return join("",@char);
}

=item find_attached_scanners()

Return a hash of attached of scanners attached:

$hash{vendor}{product} = USB address

TODO: this is ugly, Id prefer to use vendor/product names, not ids,
but not all my scanners have vendor/product names, sigh

=cut

sub find_attached_scanners {
  my(@scanners) = `sudo sane-find-scanner | egrep -i '^found'`;
  my(%hash);
  for $i (@scanners) {
    $i=~s/vendor=(\S+)//;
    my($vendor) = $1;
    $i=~s/product=(\S+)//;
    my($product) = $1;
    $i=~s/at (.*?)$//;
    my($usb) = $1;
    $hash{$vendor}{$product}=$usb;
  }

  return \%hash;
}

=item mv_after_diff($source, $options)

Move $source.new to $source and $source to $source.old; however, if
$source.new and $source are already identical (per cmp), do
nothing. $options:

 nocmp = don't compare to see if files are equal, always overwrite
 (useful when timestamps are important)

TODO: add rm=1 option to remove .new file in case of equality (but
safer to keep it around "just in case")

TODO: This wont work for files that have quotation marks, but those
are hopefully rare

TODO: all for arbitrary source/target files, now just source.new?

=cut

sub mv_after_diff {
  my($source, $options) = @_;

  my(%opts) = parse_form($options);

  my($out,$err,$res);

  unless ($opts{nocmp}) {
    ($out,$err,$res) = cache_command2("cmp \"$source\" \"$source.new\" 1> /tmp/cmp.out 2> /tmp/cmp.err", "nocache=1");
    debug("OUT: $out, ERR: $err, RES: $res");
    unless ($res) {
      debug("$source and $source.new already identical");
      return;
    }
  }

  debug("$source and $source.new different or nocmp=1, overwriting");
  system("mv \"$source\" \"$source.old\"; mv \"$source.new\" \"$source\"");
}

=item num2base($num,$base)

Convert $num to base $base, returning a list of integers (lowest byte
first) corresponding to $num

=cut

sub num2base {
  my($num,$base) = @_;
  my(@ret);

  while ($num) {
    push(@ret, $num%$base);
    $num = floor($num/$base);
  }
  return @ret;
}

=item fetlife_user_data($file)

Given a (possibly BZIPed) file that contains FetLife users profile
data, return a hash of specific data

=cut

sub fetlife_user_data {
  my($file) = @_;
  my(%data);
  $data{filename} = $file;
  $data{mtime} = (stat($file))[9];

  my($all);
  if($file=~/\.bz2$/){$all=join("",`bzcat $file`);}else{$all=read_file($file);}

  # TODO: decide if %meta is useful to me in some way
  my(%meta);

  # inactive profile
  if ($all=~s%You are being <a href="https://fetlife.com/home">redirected</a>.</body></html>%%) {
    $data{latestactivity} = "inactive";
    return %data;
  }

  # thumbnail URL (correct 200 to 60 for consistency)
  # TODO: check this degrades nicely if no thumb/blank thumb
  $all=~s%(https://fl.*?_200\.jpg)%%;
  $data{thumbnail} = $1;
  $data{thumbnail}=~s/_200\.jpg/_60.jpg/;

  # get rid of footer
  $all=~s/<em>going up\?<\/em>.*$//s;

  # title (= username)
  $all=~s%<title>(.*?) - Kinksters - FetLife</title>%%s||warn("BAD TITLE: $all");
  $data{screenname} = $1;

  # number
  $all=~s%"/conversations/new\?with=(\d+)"%%;
  $data{id} = $1;

  # data source is user page itself
  $data{source} = "https://fetlife.com/users/$data{id}";

  # after getting title, get rid of header
  $all=~s%^.*</head>%%s;

  # latest activity (could get all activity on front page, but no)
  $all=~s%<span class="quiet small">(.*? ago)</span>%%;
  # leaving this in "fetlife format", like "3 hours ago"
  $data{latestactivity} = $1;

  # after getting latest activity, nuke the activity feed, it interferes
  $all=~s%<ul id="mini_feed">(.*?)</ul>%%s;

  # now grab events (but not those in activity feed)
  while ($all=~s%<a href="/events/(\d+)">(.*?)<%%s) {
    $data{event}{$2} = 1;
    $meta{event}{$2}{number} = $1;
  }

  # number of pics (may have commas)
  if ($all=~s/view pics.*?\(([\,\d]+)\)//) {
    $data{npics} = $1;
    $data{npics}=~s/,//g;
  }

  # and vids
  if ($all=~s/view vids.*?\(([\,\d]+)\)//) {
    $data{nvids} = $1;
    $data{nvids}=~s/,//g;
  }

  # number of friends (may have commas)
  if ($all=~s%Friends <span class="smaller">\(([\d\,]+)\)</span>%%s) {
    $data{nfriends} = $1;
    $data{nfriends}=~s/,//g;
  }

  # age, and orientation/gender
  $all=~s%<span class="small quiet">(.*?)</span></h2>%%s||warn("NO EXTRA DATA($i): $all");
  my($extra) = $1;
  $extra=~s/^(\d+)(.*)\s+(.*?)$//;
  ($data{age}, $data{gender}, $data{role}) = ($1, $2, $3);

  # city if first /cities link in page
  # TODO: get state/etc
  while ($all=~s%<a href="/(cities|administrative_areas|countries)/(\d+)">(.*?)</a>%%) {
    $data{$1} = $3;
    $meta{$1}{$3}{number} = $2;
  }

  # just to make scripts happy
  $data{city} = $data{cities};
  $data{state} = $data{administrative_areas};
  $data{country} = $data{countries};

  # "realify" quotes (needed for csv below)
  $all=~s/\&quot\;/\"/sg;

  # get groups
  # TODO: exclude activity feed!
  while ($all=~s/<li><a href="\/groups\/(\d+)">(.*?)<\/a><\/li>//s) {
    $data{groups}{$2} = $1;
  }

  # get fetishes in better way
  while ($all=~s/(Into|Curious about):(.*)$//m) {
    my($type, $fetishes) = ($1, $2);

    # look for ones with role attached first
    while ($fetishes=~s%<a href="/fetishes/(\d+)">([^<>]*?)</a>\s*<span class="quiet smaller">\((.*?)\)</span>%%) {
      $data{fetish}{$type}{$2} = $3;
      $meta{fetish}{$2}{number} = $1;
    }

    # ones without a role
    while ($fetishes=~s%<a href="/fetishes/(\d+)">([^<>]*?)</a>%%) {
      $data{fetish}{$type}{$2} = 1;
      $meta{fetish}{$2}{number} = $1;
    }

    # make sure we got them all
    $fetishes=~s/<.*?>//g;
    $fetishes=~s/[\,\s\.]//g;
    if ($fetishes) {warn "LEFTOVER FETISHES ($file): $fetishes";}
  }

  # table fields with headers/colons
  # TODO: "looking for" is multivalued
  # TODO: "relationships in" is multivalued (but may not be of interest,
  # except for 6 degrees stuff?, which wouldn't include "friends" in general?)
  while ($all=~s%<tr>\s*<th[^>]*>(.*?)</th>\s*<td>(.*?)</td>\s*</tr>%%is) {
    ($key, $val) = (lc($1),$2);
    $key=~s/:\s*$//isg;
    $key=~s/[\/\s]//isg;
    $val=~s/\'//isg;
    $data{$key} = $val;
  }

  # parse out relationshipstatus + dsrelationshipstatus
  for $j ("relationshipstatus", "dsrelationshipstatus") {
    while ($data{$j}=~s%<li>(.*?)</li>%%) {
      my($rel) = $1;
      # need underscore below to avoid overwriting variable we're reading from
      if ($rel=~s%^(.*?)\s*<a href="/users/(\d+)">.*?</a>%%m) {
	$data{"_$j"}{$1}{$2} = 1;
      } else {
	$data{"_$j"}{$rel}{0} = 1;
      }
    }
    # fix the hash (hopefully)
    $data{$j} = $data{"_$j"};
    delete $data{"_$j"};
  }

  # and islookingfor
  for $j (split("<br/>", $data{islookingfor})) {
    $data{"_islookingfor"}{$j} = 1;
  }
  # and fix
  $data{islookingfor} = $data{"_islookingfor"};
  delete $data{"_islookingfor"};

  return %data;
}

=item ieee754todec($str,$options)

Converts $str in IEEE-754 format to decimal number. If $str is not in
IEEE-754 format, return it as is (however, is $str is
apostrophe-quoted, will remove apostrophes)

Options:

mathematica=1: return in Mathematica format (exact), not decimal

binary=1: return as binary string (first 7 bytes are mantissa, 8th
byte is exponent +16 if exponent is negative, +32 if mantissa is
negative)

=cut

sub ieee754todec {
  my($str,$options) = @_;
  my(%opts) = parse_form($options);

  $str=~s/\'//g;

  # HACK: if string is pure hex (no exponent), return its hex value
  if ($str=~/^[0-9A-F]+$/) {return hex($str);}

  # if not a properly formatted string, return as is
  # TODO: throw an exception here
  unless ($str=~/^(\-?)([0-9A-F]+)\^(\-?)([0-9A-F]+)$/) {return $str;}
  my($sgn,$mant,$expsign,$exp) = ("${1}1",$2,"${3}1",$4);
  my($pow) = $expsign*hex($exp)-length($mant);

  # for mathematica, return value is easy
  if ($opts{mathematica}) {return qq%${sgn}*FromDigits["$mant",16]*16^$pow%;}

  # pad to 14 characters
  $mant = substr($mant."0"x14,0,14);

  # if binary, convert now
  if ($opts{binary}) {
    # mantissa to binary
    $mant=~s/(..)/chr(hex($1))/eg;
    # exponent to binary (adding signs as needed)
    $mant .= chr(hex($exp) + abs($expsign)*16 + abs($sgn)*32);
    return $mant;
  }

  # at this point, we can convert exp to its full decimal value
  $exp = $expsign*hex($exp);

  # split into 2 pieces, hex each piece
  $mant=~s/^(.{7})(.{7})$//;
  my($p1,$p2) = ($1,$2);
  my($val) = $sgn*(hex($p1)*16**($exp-7) + hex($p2)*16**($exp-14));
  return $val;
}


=item jd2proleptic_julian_ymdhms($jd)

Given a Julian date, returns the proleptic Julian year/month/day etc.

Proleptic Julian = assumes the Julian calendar (1 leap year every 4
years w/ no variance) is always used

See jd2mixed_ymdhms() for caveats

=cut

sub jd2proleptic_julian_ymdhms {
  my($jd) = @_;

  # The Julian calendar repeats every 4*365+1 = 1461 days
  # using 2000-2003 as "reference date"
  # [2000 1 1 = JD 2451544.500000 = Unix 946684800, so 2451543.500000 = day 0]
  # how many "chunks" of 1461 days ago is/was this?
  # 14 to compensate for Gregorian reformation
  my($yrs) = ($jd-2451543.500000-14.);
  # how many days into this chunk?
  my($chunks,$days) = (floor($yrs/1461),fmodp($yrs,1461));
  my(@gm) = gmtime(946684800+$days*86400);
  # adjust the year (gmtime returns years-1900, thus the adjustment below)
  $gm[5] += 1900+4*$chunks;
  # gmtime returns month-1, so...
  $gm[4]++;
  return(reverse(@gm[0..5]));
}

=item jd2proleptic_gregorian_ymdhms($jd)

Given a Julian date, returns the proleptic Gregorian year/month/day etc.

Proleptic Gregorian = assumes the Gregorian calendar (1 leap year every 4
years except every 100 years except every 400 years) is always used

See jd2mixed_ymdhms() for caveats

=cut

sub jd2proleptic_gregorian_ymdhms {

  my($jd) = @_;

  # "reduce" this date to 2000-2399, by adding/subtracting 400 year periods
  # JD 2451543.5 = 1999-12-31 00:00:00, day 0 of year 2000
  my($yrs) =$jd-2451543.500000;

  # The Gregorian calendar repeats every 400 years = 146097 days
  my($chunks,$days) = (floor($yrs/146097),fmodp($yrs,146097));
  # compute for newjd (add to days to bring back into 2000-2399 era)
  my($date) = Astro::Nova::get_date($days+2451543.5);
  my(@date) = ($date->get_years(), $date->get_months(),
	     $date->get_days(), $date->get_hours(), $date->get_minutes,
	      $date->get_seconds);
  # adjust
  $date[0] += 400*$chunks;
  return @date;
}

=item jd2mixed_ymdhms($jd)

Returns either the Gregorian year/month/date/etc or the Julian one,
depending on whether is it before or after the Reformation:

TODO: allow user to choose Reformation date, one below is per NASA:

http://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/req/time.html#Calendars

Julian 1582 Oct 5 = Gregorian 1582 Oct 15 = JD 2299160.500000

Caveats: following the astronomical convention that 1BC is year 0, 2BC
is year -1, and so on, since Im mostly doing this for Stellarium dates:

http://www.stellarium.org/wiki/index.php/FAQ#.22There_is_no_year_0.22.2C_or\
_.22BC_dates_are_a_year_out.22

=cut

sub jd2mixed_ymdhms {
  my($jd) = @_;

  if ($jd<2299160.5) {return jd2proleptic_julian_ymdhms($jd);}
  return jd2proleptic_gregorian_ymdhms($jd);
}

=item mysqlhashlist($query,$db,$user)

Run $query (should be a SELECT statement) on $db as $user, and return
list of hashes, one for each row

NOTE: return array first index is 1, not 0

TODO: above can be confusing, fix it

TODO: add error checking

=cut

sub mysqlhashlist {
  my($query,$db,$user) = @_;
  unless ($user) {$user="''";}
  my(@res,$row);
  chdir(tmpdir());

  write_file($query,"query");

  # TODO: this is a terrible way to get a temp file name
  my($temp) = `date +%N`;
  chomp($temp);
  debug("TEMP: $temp");
  # TODO: for large resultsets, loading entire output may be bad
  my($out,$err,$res) = cache_command2("mysql -w -u $user -E $db < query","salt=$query&cachefile=/tmp/cache.$temp");

  # go through results
  for $i (split(/\n/,$out)) {

    # new row
    if ($i=~/^\*+\s*(\d+)\. row\s*\*+$/) {$row = $1; $res[$row]={}; next;}
    unless ($i=~/^\s*(.*?):\s*(.*)/) {debug("IGNORING: $_"); next;}
    $res[$row]->{$1}=$2;
  }
  return @res;
}


=item parse_date_list($string)

Given a $string like "2013-04-17-2013-04-19, 2013-04-22, 2013-04-23,
2013-04-30, 2013-05-01, 2013-05-06-2013-05-08, 2013-05-13-2013-05-15,
2013-05-20-2013-05-22, 2013-05-24, 2013-05-29", return a list of dates where:

"2013-05-06-2013-05-08" is treated as a range of dates and commas
separate as they would in normal list

=cut

sub parse_date_list {
  my($datelist) = @_;
  my(@ret);

  for $i (split(/\,/,$datelist)) {
    # if datelist is date range (2002-06-03-2002-06-07), parse further
    if ($i=~/^(\d{4}-\d{2}-\d{2})\-(\d{4}-\d{2}-\d{2})$/) {
      for $j (str2time($1)/86400..str2time($2)/86400) {
	push(@ret, strftime("%Y-%m-%d", gmtime($j*86400)));
      }
    } else {
      push(@ret, $i);
    }
  }
  return @ret;
}

# cleanup files created by my_tmpfile (unless --keeptemp set)
sub END {
  debug("END: CLEANING UP TMP FILES");
  local $?;

  # if --xmessage set, alert user + write to bg image
  if ($globopts{xmessage}) {xmessage("Program has ended",1);}

  # if --bgend, write to background image
  if ($globopts{bgend}) {
    append_file("$0 has ended\n", "$ENV{HOME}/ERR/ended_programs.err");
  }

  if ($globopts{keeptemp}) {return;}

  for $i (sort keys %is_tempfile) {
    # I sometimes wrongly use tempfile.[ext], so handle that too
    # TODO: change this to .* ?
    for $j ("", ".res", ".out", ".err", ".kml", ".kmz", ".bin.aux.xml", ".clr", ".hdr", ".prj", ".bin") {
      debug("DELETING: $i$j");
      system("rm -f $i$j");
    }
  }

  for $i (keys %istmpdir) {
    debug("RM -R: $i");
    system("rm -r $i");
  }

  debug("END ENDS");
}

# parse_form = alias for str2hash (but some of my code uses it)
sub parse_form {return str2hash(@_);}

# suck = alias for read_file (I was young and foolish...)
sub suck {return read_file(@_);}

# var_dump for dump_var
sub var_dump {return dump_var(@_);}

# automatically call parse_options (don't expect calling prog to do this)
&parse_options;

# after parsing options, if --help called, print out "help" on the
# program instead of running it-- by looking at comments prior to code

# TODO: should probably subroutinize this

if ($globopts{help}) {

  # open the code file...
  local(*A);

  open(A,$0)||die("Can't open $0: $!");

  # first line should have Perl interpreter somewhere

  unless (<A>=~/perl/i) {die "Script doesn't start with Perl interpreter";}

  # print lines until first code line (nonblank/noncomment line)

  while (<A>) {

    if (/^\#/) {print $_; next;}
    if (/^\s*$/) {next;}
    last;
  }

  # global options supported by library
  print "\nLibrary options:\n\n";
  print $bclib{options_supported};

  # when using --help don't run code
  exit(0);

}

1;
