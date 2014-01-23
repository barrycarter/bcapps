#!/bin/perl

# Runs a nagios test; if a plugin exists, use it; otherwise, use
# subroutines defined here

# this is hideous; pass args to the program using NAGIOS_ARG2
@ARGV = split(/\s+/, $ENV{NAGIOS_ARG2});

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# for testing only!
$globopts{debug}=1;

debug("ARGV",@ARGV);

# what are we being asked to run?
my($cmd) = $ENV{NAGIOS_ARG1};
debug("CMD: $cmd");

# split into command and arguments (removing quotes first)
$cmd=~s/\"//isg;
$cmd=~/^\s*(.*?)\s+(.*)$/;
my($bin,$arg) = ($1,$2);

debug("BIN/ARG: $bin/$arg");

# if the "binary" starts with "bc_", I want to run a local function
if ($bin=~/^bc_/) {
  # this is dangerous, but I control my nagios files
  $res = eval($cmd);
  debug("$cmd returns: $res");
  # below just for testing
  exit($res);
}

# >>8 converts Perl exit value to program exit value (kind of)
$res = system("$bin $arg")>>8;

# run function on result before returning?
# no need to do this on functions I write myself, above
if ($globopts{func}) {$res = func($globopts{func}, $res);}

# does the function tell what subroutine to call to fix itself
# (assuming its broken)?
if ($res && $globopts{fix}) {
  eval($globopts{fix});
}

# this is ugly, but works (spits out stuff to console)
# TODO: redirect output of nagios to file that should remain empty
# debug("FUNC: $globopts{func}, RES: $res");

exit($res);

=item func($func, $val)

Applies $func to $val, where func is a very simple function.

Used primarily to turn return values of 1 to 0 when needed

=cut

sub func {
  my($func,$val) = @_;

  # when I want grep to fail, 1 is good, other values are bad
  # (values like 2 indicate other problems that I do need to be aware of
  if ($func eq "1is0") {
    if ($val==1) {return 0;}
    if ($val==0) {return 2;}
    return $val;
  }

  # some scripts return '1' to mean bad, but I want to return 2
  if ($func eq "1is2") {
    if ($val==1) {return 2;}
    return $val;
  }
}

=item bc_check_url_sha1($url, $sha1)

Confirm that the sha1 of the content of $url is $sha1 (useful to test
binary files where searching for a string is impratical)

=cut

sub bc_check_url_sha1 {
  my($url, $sha1) = @_;
  # TODO: shorten this cache time
  my($out,$err,$res) = cache_command2("curl '$url'","age=300");
  # check for errors
  if ($res) {
    print "Error retrieving URL $url: $err\n";
    return 2;
  }
  # empty (even without error)
  unless ($out) {
    print "URL is empty: $url\n";
    return 2;
  }

  # and the check
  my($sha) = sha1_hex($out);

  unless ($sha eq $sha1) {
    print "SHA($url) $sha does not match $sha1\n";
    return 2;
  }

  print "SHA($url) matches: $sha\n";
  return 0;
}

=item bc_check_files_age($files,$age)

Given multiple files (as a file spec that ls can handle), check that
all of them (and thus the oldest one) is younger than $age seconds

=cut

sub bc_check_files_age {
  my($files,$age) = @_;
  my($out,$err,$res) = cache_command("ls -1tr $files | head -1 | xargs stat -c '%Y'");

  if ($res) {
    print "Command returned error $res: $err\n";
    return 2;
  }

  my($fileage) = time()-$out;
  if ($fileage <= $age) {
    print "$files all less than $age seconds old\n";
    return 0;
  }

  print "$files older than $age (max age: $fileage) seconds\n";
  return 2;
}

=item bc_head_size($url,$size)

Does a HEAD request to $url and confirms content-length is $size
(useful for checking size consistency without doing full pull for
large files)

<h>My actual head size is: too big</h>

=cut

sub bc_head_size {
  my($url,$size) = @_;
  my($out,$err,$res) = cache_command("curl --head $url | grep Content-Length: | cut -d ' ' -f 2", "age=60");

  if ($res) {
    print "Command returned error $res: $err\n";
    return 2;
  }
  
  # below gets rid of \r as well as \n
  $out=~s/\s*$//isg;
  if ($out eq $size) {
    print "$url is $out bytes\n";
    return 0;
  }

  print "$url is $out bytes != $size bytes\n";
  return 2;
}

=item bc_404($file)

Confirms that $file does not exist (not even as a directory, symlink, etc)

=cut

sub bc_404 {
  my($file) = @_;
  if (-e $file) {
    print "$file exists, which is bad\n";
    return 2;
  }
  print "No such file/directory: $file, which is good\n";
  return 0;
}

=item bc_info_log($file)

Confirms that the last entry in $file lighttpd log file (which I rsync
over regularly) is relatively recent (could also use check_file_age,
but this is slightly more reliable).

TODO: make MUCH more generic

=cut

sub bc_info_log {
  my($file) = @_;
  # last line of access log
  my($lastline) = `tail -1 $file`;
  # find timestamp
  $lastline=~/\[(.*?)\]/;
  # convert to unix time and check diff
  my($diff) = abs(time()-str2time($1));
  # note: too far in future is also bad
  if ($diff > 86400) {
    print "$file rsync too old! ($diff seconds)\n";
    return 2;
  }

  print "$file fine: $diff seconds\n";
  return 0;
}

=item bc_hwclock_test()

Confirms the hardware clock is within 1 hour of the computer clock

EDITED: it turns out the value of the hwclock isnt super-relevant

TODO: allow 3600s to be a parameter

=cut

sub bc_hwclock_test {
  my($hwclock) = `sudo hwclock --show`;
  my($now) = time();

  # split hwclock into time, seconds delta
  unless ($hwclock=~/^(.*?)\s+(\-?\d+\.\d+)\s+seconds$/) {
    print "HWCLOCK not parseable: $hwclock\n";
    return 2;
  }

  my($hwtime,$delta) = ($1,$2);
  my($diff) = abs(str2time($hwtime)+$delta-$now);

  if ($diff<3600) {
    print "HWCLOCK delta: $diff < 3600\n";
    return 0;
  }

  print "HWCLOCK delta: $diff >= 3600\n";
  return 2;
}

=item bc_hostname_test()

Confirms hostname is correct

=cut

sub bc_hostname_test {
  my($hostname) = `hostname`;
  chomp($hostname);

  if ($hostname eq $bc{hostname}) {
    print "HOSTNAME OK: $bc{hostname}\n";
    return 0;
  }

  # attempt to fix hostname
  # TODO: should this be here?
  system("sudo hostname $bc{hostname}");

  print "BAD HOSTNAME: $hostname != $bc{hostname}\n";
  return 2;
}

=item bc_metformin_test()

This fairly insane and pointless (except to me) test checks if I've
taken the appropriate amount of metformin based on how much I've
eaten: 1 metformin after I've had ANY number of calories, 2 metformin
if I've had 600 or more calories.

Metformin count in /home/barrycarter/TODAY/yyyymmdd.txt (where
yyyymmdd is current date)

=cut

sub bc_metformin_test {
  # read calories consumed (output by bc-food-track)
  # TODO: relying on format of cal.inf is probably bad
  my($cals) = read_file("/home/barrycarter/ERR/cal.inf");
  # only need last number
  $cals=~s/\(.*?\)//isg;
  $cals=~s%.*/%%isg;

  # if no calories consumed, no problem (no need to even check TODAY)

  if ($cals == 0) {
    print "OK: No calories consumed\n";
    return 0;
  }

  # since cals consumed, find file for today and grep
  my($cmd) = strftime("grep -ic metformin /home/barrycarter/TODAY/%Y%m%d.txt",localtime(time()));
  my($res) = `$cmd`;

  # compare metformin dose to calories
  if ($res==0) {
    print "ERR: Consumed $cal calories, no metformin\n";
    return 2;
  }

  # more than 2 metformin = never a problem
  if ($res>=2) {
    print "OK: Consumed $res metformin\n";
    return 0;
  }

  # remaining case: 1 metformin
  if ($cals<600) {
    print "OK: 1 metformin for $cals calories\n";
    return 0;
  }

  print "ERR: Only 1 metformin for $cals > 600 calories\n";

  return 2;
}

=item bc_nagios_file_size($file, $size, $options)

Confirm that $file (which can be a directory) is less than $size bytes

=cut

sub bc_nagios_file_size {
  my($file, $size, $options) = @_;
  my(%opts) = parse_form($options);

  my($cmd) = "stat $file | fgrep Size:";

  # if not localhost, use ssh to get results
  if ($ENV{NAGIOS_HOSTNAME} ne "localhost") {
    $cmd = "ssh -i /home/barrycarter/.ssh/id_rsa.bc root\@$ENV{NAGIOS_HOSTNAME} '$cmd'";
  }

  my($stat,$err,$res) = cache_command($cmd);
  if ($res) {
    print "$cmd failed\n";
    return 2;
  }

  $stat=~/Size:\s+(\d+)\s/;
  $stat=$1;
  debug("SIZE: $stat");
  if ($stat > $size) {return 2;}
  return 0;
}

=item bc_gaim_log_unanswered($options)

Checks GAIM logs for last 3 days to see if there are any conversations
awaiting my input, namely those where:

  - I am not the last speaker AND

  - The other speaker is not someone I'm intentionally ignoring.

I use GAIM's "message notification" plugin, which is much more
immediate, but this is for catching longer-term situations

~/myids.txt should contain a list of ids you use

~/badpeeps.txt should contain a list of people you are OK ignoring

~/imignoredir.txt should contain a list of your ids for which you're OK w/ someone else answering last

$options currently unused

TODO: don't hardcode my homedir (can't use $ENV{HOME}, since test runs
as root, not me)

TODO: should only find most recent file in each directory

=cut

sub bc_gaim_log_unanswered {
  # logs that are very recent probably just mean I haven't had time to
  # answer yet, so add -mmin +1
  my($out, $err, $res) = cache_command("find /home/barrycarter/.purple/logs/ -mtime -3 -mmin +1 -type f | fgrep -vf /home/barrycarter/imignoredir.txt | xargs -n 1 tail -1 | fgrep -vf /home/barrycarter/myids.txt | fgrep -vf /home/barrycarter/badpeeps.txt", "ignoreerror=1");
  if ($err) {
    print "ERR: $err\n";
    return 2;
  }

  if ($out) {
    print "OUT: $out\n";
    return 2;
  }

  return 0;
}

=item bc_stream_twitter_test()

This one off tests that bc-stream-twitter.pl is working properly, and
its child curl process isnt hanging (running, but not receiving data)

=cut

sub bc_stream_twitter_test {
  # is bc-stream-twitter.pl running at all?
  # not sure why running in shell limits to 14 chars?
  my($res) = system("pgrep -f bc-stream-twit");
  # if not, no need to check
  if ($res) {
    print "OK - bc-stream-twitter not running\n";
    return 0;
  }

  # its running, so make sure its output file is recent
  return system("check_file_age /var/tmp/log/twitstream.txt -w 600 -c 1200")>>8;
}

# fixes resolv.conf in a fairly obvious way
sub fix_resolv {
  system("sudo cp -f /etc/resolv.conf.opendns /etc/resolv.conf");
}

=item bc_check_domain_exp()

Checks whether any of my domains are within 60 days of expiration (nagios).

=cut

sub bc_check_domain_exp {
  # TODO: generalize this a bit... but per domain testing would be ugly,
  # since nagios would need 1 test per domain = bad?
  my(@domains) = `egrep -v '^#|^ *\$' /home/barrycarter/mydomains.txt`;
  my($now) = time();
  for $i (@domains) {
    chomp($i);
    # cache long time and sleep to avoid overwhelming servers
    my($out,$err,$res) = cache_command2("whois $i", "age=43200");
    # no expiration date?
    unless ($out=~/^\s*(Expiration Date|Expires on|Domain Expiration Date|Registrar Expiration Date|Registrar Registration Expiration Date|Registry Expiry Date):\s*(.*?)$/m) {
      print "ERR: No expiration date found: $i\n";
      return 2;
    }
    my($date) = $2;
    $date=~s/\s*$//isg;
    my($exp) = (str2time($date)-$now)/86400;
    if ($exp<60) {
      printf("ERR: $i expires in %d < 60 days\n",$exp);
      return 2;
    }
    printf("OK: $i expires in %d > 60 days\n",$exp);
  }

  print "All domains expire > 60 days\n";
  return 0;
}

