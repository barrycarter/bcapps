#!/bin/perl

# read/write directly to/from a terminal (not a shell)

require "/usr/local/lib/bclib.pl";

# do i just need IPC w (tc)sh?

use IPC::Open3;
$|=1;

my $pid = open3(\*IN, \*OUT, \*ERR, 'sh');

# fcntl(IN,F_SETFL,O_NONBLOCK);
# fcntl(OUT,F_SETFL,O_NONBLOCK);

my($input,$output);

for (;;) {

  print "Enter something for mr shell\n";
  $input = <STDIN>;
  print IN $input;

  print "Lets see what mr shell says\n";
  $output = <OUT>;
  print "SHELL: $output";

#  while ($output = <OUT>) {
#    print "SHELL: $output";
#  }

}

die "TESTING";



use Expect;

sub myfunc {
  my($glob) = @_;

  debug("MATCH:",$glob->match());

}

my($exp) = Expect->spawn("sh");

# $exp->debug(3);

$exp->send("adventure\n");

$exp->expect(0);

debug("BEFORE", "<start>".$exp->before()."<end>");

# $exp->expect(1, '-re', "/................../s");

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
