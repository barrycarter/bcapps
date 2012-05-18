#!/bin/perl

# This script will handle all nagios notifications (currently empty)

# Important environment variables
# NAGIOS_HOSTADDRESS -> 192.168.0.7
# NAGIOS_HOSTALIAS -> bcpc
# NAGIOS_HOSTSTATE -> UP
# NAGIOS_HOSTSTATEID -> 0

push(@INC,"/usr/local/lib");
require "bclib.pl";

# if host is down, write to ERR
if ($ENV{NAGIOS_HOSTSTATEID}) {
  $fbase = "/home/barrycarter/ERR/nagios.$ENV{NAGIOS_HOSTALIAS}";
  write_file("nagios.$ENV{NAGIOS_HOSTALIAS}.down", "$fbase.new");
  system("mv $fbase.err $fbase.old; mv $fbase.new $fbase.err");
}

$id = time().$$;
open(A,">/tmp/bnht$id.txt");
for $i (sort keys %ENV) {
  print A "$i -> $ENV{$i}\n";
}
close(A);
