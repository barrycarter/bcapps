#!/bin/perl

# Stalks given chat rooms per http://meta.stackexchange.com/questions/218343/how-do-the-stack-exchange-websockets-work-what-are-all-the-options-you-can-send/218443#218443

require "/usr/local/lib/bclib.pl";

# TODO: don't hardcode these rooms AND allow changes while program is
# running (perhaps as a mini-IRC server)

@rooms = (118, 198, 21, 30332, 35, 18, 36, 8595, 30985);

# note that this doesn't change @rooms, which is important
my($rstr) = join("&",map("r$_=0",@rooms));

# "1" below is just for convenience, we can get fkey in any room
my($out,$err,$res) = cache_command2("curl -L http://chat.stackexchange.com/rooms/1","age=3600");
unless ($out=~s%<input id="fkey" name="fkey" type="hidden" value="(.*?)" />%%s) {die "NO FKEY";}
my($fkey) = $1;

# cruft the command
my($cmd) = "curl -d 'fkey=$fkey&$rstr' http://chat.stackexchange.com/events";

# cache during testing only

# get recent events
# TODO: this will eventually be a loop

($out,$err,$res) = cache_command2($cmd,"age=3600");

my(%hash) = %{JSON::from_json($out)};

my(%msgs);

for $i (keys %hash) {
  for $j (keys %{$hash{$i}}) {
    # the d and t values are probably important, but not to me at the moment
    for $k (@{$hash{$i}{$j}}) {
      # TODO: ignore non-1 event_type?
      # TODO: this is just a temporary "prettyprint"
#      my(%hash) = %{$k};
      $msgs{$k->{id}} = join("|", $k->{room_name}, $k->{user_name}, $k->{time_stamp}, $k->{content});
    }
  }
}

debug(unfold(\%msgs));

# debug(var_dump("hash",\%hash));

die "TESTING";


# get events

# fixed timestamp for testing
my($ts) = 1449949857-600;

# apprently, first two digits are trimmed (why?)
$ts=~s/^..//;

# testing
$ts = "49014409";

# TODO: normally, dont cache this
# TODO: can I do multiple roomids here, eg r1=foo&r2=foo.. ?
($out,$err,$res) = cache_command2("curl --trace-ascii - -d 'fkey=$fkey&r$rid=$ts' http://chat.stackexchange.com/events", "age=3600");

# debug("FK: $fkey");
debug("OUT: $out","ERR: $err");

