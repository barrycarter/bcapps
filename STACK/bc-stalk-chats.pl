#!/bin/perl

# Stalks given chat rooms per http://meta.stackexchange.com/questions/218343/how-do-the-stack-exchange-websockets-work-what-are-all-the-options-you-can-send/218443#218443

require "/usr/local/lib/bclib.pl";

# TODO: don't hardcode these rooms AND allow changes while program is
# running (perhaps as a mini-IRC server)

@rooms = (118, 198, 21, 30332, 35, 18, 36, 8595, 30985);

# "1" below is just for convenience, we can get fkey in any room
my($out,$err,$res) = cache_command2("curl -L http://chat.stackexchange.com/rooms/1","age=3600");
unless ($out=~s%<input id="fkey" name="fkey" type="hidden" value="(.*?)" />%%s) {die "NO FKEY";}
my($fkey) = $1;
# ugly that you have to keep track of hwm separately, Perl vars die outside for
my($hwm) = -1;

for (;;) {

  my(%msgs) = get_chats(\@rooms, $fkey, $hwm+1);

  for $i (sort {$a <=> $b} keys %msgs) {
    my(%hash) = %{$msgs{$i}};
    my($ts) = strftime("%H%M%S", localtime($hash{time_stamp}));
    print "$ts $hash{room_name} $hash{user_name} $hash{content}\n";
    $hwm = $i;
  }

  sleep 5;
};

=item get_chats(\@rooms, $fkey, $id)

Given a list of rooms (as numeric ids), an fkey, and a starting $id,
return all chat messages (as a hash of hashes) in @rooms with
ids >= $id

This is a program specific subroutine.

=cut

sub get_chats {
  my($rref,$fkey,$id) = @_;
  my(@room) = @$rref;

  my($rstr) = join("&",map("r$_=$id",@rooms));
  # cruft the command
  my($cmd) = "curl -d 'fkey=$fkey&$rstr' http://chat.stackexchange.com/events";
  # TODO: don't cache in production, although $id should be different each time
  # (actually, no, because if it gets nothing, it stays nothing forever)
  my($out,$err,$res) = cache_command2($cmd);

  debug("OUT: $out");

  my(%hash) = %{JSON::from_json($out)};
  my(%msgs);
  for $i (keys %hash) {
    for $j (keys %{$hash{$i}}) {
      # the d and t values are probably important, but not to me at the moment
      for $k (@{$hash{$i}{$j}}) {
	$msgs{$k->{id}} = $k;
      }
    }
  }

  return %msgs;
}



