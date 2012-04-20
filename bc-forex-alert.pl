#!/bin/perl

# Trivial wrapper around forex_quote(), intended to run from cron
# every 1m (even though it looks back 5m). Options:
# --until=yyyymmdd.hhmmss: don't run until yyyymmdd.hhmmss (lets me
# turn off alerts temporarily)
# --altquote = use an alternate quoting method, in case main method fails

require "/home/barrycarter/BCGIT/bclib.pl";
$now = stardate(time());

# TODO: fix this to still log stuff even if --until=
if ($globopts{until} && $now < $globopts{until}) {exit(0);}

# my private email address (public one: barry at barrycarter dot info)
$email = read_file("/home/barrycarter/bc-email.txt");
chomp($email);

# obtain from args (parity format: USD/CAD)
($parity, $low, $high) = @ARGV;

# when forex_quote() not working properly, try forex_quotes()
if ($globopts{altquote}) {
  %quotes = forex_quotes();
  $myparity = $parity;
  $myparity=~s%/%%isg;
  %bidask = %{$quotes{$myparity}};
  # HACK: formatting this so it can be unformatted later is ugly!
  push(@x, "<bid>$bidask{bid}</bid>\n<offer>$bidask{ask}</offer>\n");
  debug("PAR: $parity");
  debug(unfold(%quotes));
} else {
  @x=forex_quote($parity,time(),"list=true");
}

for $i (@x) {
  %hash = ();
  while ($i=~s%<(.*?)>(.*?)</\1>%%) {
    $hash{lc($1)} = $2;
  }

  debug("HASH",unfold(%hash));
  debug("$hash{bid} - $hash{offer}");

  # remove slash for err file
  $pfile = $parity;
  $pfile=~s/\///isg;

  # bad bid/offer?
  unless ($hash{bid} && $hash{offer}) {
    # my error tracking system (this err not serious enough to send to phone)
    write_file("$parity: no quote", "/home/barrycarter/ERR/$pfile.err.new");
    system("mv /home/barrycarter/ERR/$pfile.err /home/barrycarter/ERR/$pfile.err.old; mv /home/barrycarter/ERR/$pfile.err.new /home/barrycarter/ERR/$pfile.err");
    die "BAD BID/ASK";
  }

  # if not dead, fix err file
  write_file("", "/home/barrycarter/ERR/$pfile.err.new");
  system("mv /home/barrycarter/ERR/$pfile.err /home/barrycarter/ERR/$pfile.err.old; mv /home/barrycarter/ERR/$pfile.err.new /home/barrycarter/ERR/$pfile.err");

  # theoretically possible for both to be true, but not worth testing

  # my phone treats identical messages as a single msg, so being
  # careful below to ensure message is same for given high/low

  # TODO: separate out phone, regular email, and xmessage messages

  if ($hash{bid} < $low) {
    $msg = "BC FOREX ALERT: $parity < $low";
  } elsif ($hash{offer} > $high) {
    $msg = "BC FOREX ALERT: $parity > $high";
  } else {
    $msg = "";
  }

  # if there is a msg, display it + kill old messages to avoid clutter
  if ($msg) {
    system("pkill -f 'BC FOREX ALERT: $parity'");
    system("xmessage -geometry 1024 -nearmouse '$msg' &");
    sendmail("alert\@barrycarter.info", $email, "", $msg);
  }

  $midpt = 1.*($hash{bid}+$hash{offer})/2.;

  # this prints it to my bg image (changed for bc-bg.pl)
  $parity=~s%/%%isg;
  write_file_new("$midpt ($parity) [$low - $high]", "/home/barrycarter/ERR/$parity.inf");

  # and log
  $nowu = time();
  append_file("$nowu $hash{bid} $hash{offer}\n", "/home/barrycarter/$parity.log");

}



