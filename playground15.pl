#!/bin/perl

# read/write directly to/from a terminal (not a shell)

require "/usr/local/lib/bclib.pl";

use Expect;

sub myfunc {
  my($glob) = @_;

  debug("MATCH:",$glob->match());

}

my($exp) = Expect->spawn("sh");

$exp->debug(3);

$exp->send("date\n");

$exp->expect(1, '-re', "..................");

debug("MATCH:", $exp->match());

# $exp->expect(1,[qr/.+/s => \&myfunc]);

# $exp->expect(0,
#           [ qr/.+/ => sub { my $exp = shift;
#			    debug("EXP IS: $exp");
#			     debug(var_dump("EXP",$exp));
#                     $exp->send("response\n");
#                     exp_continue; } ]);

# $read = $exp->after();
# print "READ: $read\n";




die "TESTING";

# legacy below, this is not the way to go

use IO::Pty;

$pty = new IO::Pty;

    $slave  = $pty->slave;

foreach $val (1..10) {
        print $pty "$val\n";
        $_ = <$slave>;
        print "$_";
      }

    close($slave);
