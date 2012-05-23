#!/usr/bin/perl

# as of 23 May 2012, does DNS for f96.info and nothing else
# -nodetach: remain in foreground

use Net::DNS::Nameserver;
use MIME::Base64;

# TODO: get rid of this hack
require "/usr/local/lib/bclib.pl";

# log queries
open(A,">>/var/tmp/dns.log");

# background myself
unless ($globopts{nodetach}) {if (fork()) {exit;}}

# I have no idea why I have to do this, but I do
# 23 May 2012: maybe I don't
# open(STDIN,"/dev/null");
# open(STDOUT,"/dev/null");
# open(STDERR,"/dev/null");

# the ttl for normal, IN NS, and A queries for nameservers
@ttl = (120, 86400, 86400);

# kill off any existing procs (incl tinydns)
system("/usr/bin/pkill -f tinydns");
system("/usr/bin/pkill -f teenydns");

# rename myself to teenydns AFTER doing above
$0 = "teenydns";

# create a nameserver instance running in localhost at port 53
# try repeatedly

do {
  $ns = Net::DNS::Nameserver->new(ReplyHandler => \&reply_handler);
  sleep(1);

} until $ns;

# test DNS is working
# in theory, we could force specific return value, but this server isn't
# accurate for external domains anyway, so no point
$res = system("check_dig -l yahoo.com -H 127.0.0.1");
# horrible way to "fix" (if check_dig fails, restart)
if ($res) {exec($0);}

$ns->main_loop;

sub reply_handler {
  my ($qname, $qclass, $qtype, $peerhost,$query) = @_;
  debug("REPLY_HANDLER($qname, $qclass, $qtype, $peerhost,$query)  CALLED");
  print A "$qname $qclass $qtype $peerhost $query\n";
  warn "TESTING"; return;
  my ($rcode, $ttl, $rdata, @ans, @auth, @add);
  my (@trail);

  # figure out the "domain trail" for $qname
  # (removed for effiicency until I need it)
#  my($qname2) = $qname;
#  do {unshift(@trail,$qname2);} while ($qname2=~s/^.*?\.//);

  # the auth/add records will always be the same
  for $i (randomize(keys %auth)) {
    push(@auth, Net::DNS::RR->new("$qname $ttl2 IN NS $i"));
    push(@add, Net::DNS::RR->new("$i $ttl3 IN A $auth{$i}"));
  }

  # if bcinfo(n), return CNAME to dns(n)
  if ($qname=~/^bcinfo(\d+)\./) {
    @ans = (Net::DNS::RR->new("$qname $ttl1 IN CNAME ns$1.barrycarter.info"));
    return ("NOERROR", \@ans, \@auth, \@add, {aa=>1, ra=>0});
  }

  # very special case for ns.barrycarter.info (no number)
  if ($qtype eq "A" && $qname=~/^ns\.barrycarter\.info$/) {
    my(@ns) = randomize(keys %auth);
    @ans = Net::DNS::RR->new("$qname $ttl3 IN A $auth{$ns[0]}");
    return ("NOERROR", \@ans, \@auth, \@add, {aa=>1, ra=>0});
  }

  # special case for ns*.barrycarter.info
  if ($qtype eq "A" && $qname=~/^ns\d+\.barrycarter\.info$/) {
    debug("NS* case: $qname -> $auth{$qname}");
    if ($auth{$qname}) {
      # if ns* exists, return it
      @ans = (Net::DNS::RR->new("$qname $ttl1 IN A $auth{$qname}"));
    } else {
      # if not, CNAME it to ns
      @ans = (Net::DNS::RR->new("$qname $ttl1 IN CNAME ns.barrycarter.info"));
    }
    return ("NOERROR", \@ans, \@auth, \@add, {aa => 1, ra =>0});
  }

  # case for db.conquerclub.barrycarter.info (keeping on one server
  # since realtime request db mirroring is painful)
  if ($qtype eq "A" && $qname=~/(^|\.)db\./) {
    @ans = (Net::DNS::RR->new("$qname $ttl1 IN CNAME ns1.barrycarter.info"));
    return ("NOERROR", \@ans, \@auth, \@add, {aa=>1, ra=>0});
}

  # default A record
  for $i (randomize(values %auth)) {
    push(@ans, Net::DNS::RR->new("$qname $ttl1 IN A $i"));
  }
  return ("NOERROR", \@ans, \@auth, \@add, {aa=>1, ra=>0});
}

sub randomize {
  my(@l) = @_;
  foreach $pos (1..$#l) {
    my($rand) = int(rand($pos+1));
    @l[$pos, $rand] = @l[$rand, $pos];
  }
  return @l;
}

