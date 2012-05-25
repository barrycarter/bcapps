#!/usr/bin/perl

# as of 23 May 2012, does DNS for f96.info and nothing else
# -nodetach: remain in foreground

#<h>The official purpose of this program is to clutter DNS space; any
#other use is purely incidental</h>

use Net::DNS::Nameserver;
use MIME::Base64;

# TODO: get rid of this hack
require "/usr/local/lib/bclib.pl";

# background myself
unless ($globopts{nodetach}) {if (fork()) {exit;}}

# hardcoding is hideous way to keep my IP (but checkip.dyndns.org
# isn't much better?)
$myip = "204.12.202.206";
# TODO: is this really my IPv6 address?
$myip6 = "2002::cc0c:cace";
# this is a registered nameserver
$myns = "dns.f96.info.";

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
  debug("REPLY_HANDLER($qname, $qclass, $qtype, $peerhost, $query)  CALLED");

  # log queries synchronously, since this programs runs "forever"
  append_file("$qname $qclass $qtype $peerhost $query\n", "/var/log/dns.log");

  # $query contains very technical details about the request + I
  # probably won't use it

  my ($rcode, $ttl, $rdata, @ans, @auth, @add);

  # the auth/add records will always be the same
  push(@auth, Net::DNS::RR->new("$qname $ttl[0] IN NS $myns"));
  push(@add, Net::DNS::RR->new("$myns $ttl[1] IN A $myip"));

  # all 'A' records return $myip, at least for now
  if ($qtype eq "A") {
    @ans = (Net::DNS::RR->new("$qname $ttl[0] IN A $myip"));
  }

  # and AAAA records
  if ($qtype eq "AAAA") {
    @ans = (Net::DNS::RR->new("$qname $ttl[0] IN AAAA $myip6"));
  }

  return ("NOERROR", \@ans, \@auth, \@add, {aa=>1, ra=>0});
}
