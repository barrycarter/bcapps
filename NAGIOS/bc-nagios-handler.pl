#!/bin/perl

# This script will handle all nagios notifications (currently empty)

# Important environment variables

# hosts
# NAGIOS_HOSTADDRESS -> 192.168.0.7
# NAGIOS_HOSTALIAS -> bcpc
# NAGIOS_HOSTSTATE -> UP
# NAGIOS_HOSTSTATEID -> 0

# services
# NAGIOS_SERVICEDESC -> check_disk
# NAGIOS_SERVICESTATE -> CRITICAL
# NAGIOS_SERVICESTATEID -> 2

push(@INC,"/usr/local/lib");
require "bclib.pl";

# if host is down, write to ERR
# if we're seeing a recovery, remove error file

$fbase = "/home/barrycarter/ERR/nagios.$ENV{NAGIOS_HOSTALIAS}";
if ($ENV{NAGIOS_HOSTSTATEID}) {
  write_file("nagios.$ENV{NAGIOS_HOSTALIAS}.down", "$fbase.new");
  system("mv $fbase.err $fbase.old; mv $fbase.new $fbase.err");
} else {
  system("mv $fbase.err $fbase.old");
}

# if there is no NAGIOS_SERVICECHECKCOMMAND, this was a host check and
# we should stop here

unless ($ENV{NAGIOS_SERVICECHECKCOMMAND}) {exit(0);}

# if service is down or recovering
$fbase = "/home/barrycarter/ERR/nagios.$ENV{NAGIOS_HOSTALIAS}.$ENV{NAGIOS_SERVICEDESC}";

if ($ENV{NAGIOS_SERVICESTATEID}) {
  write_file("nagios.$ENV{NAGIOS_HOSTALIAS}.$ENV{NAGIOS_SERVICEDESC}.down", "$fbase.new");
  system("mv $fbase.err $fbase.old; mv $fbase.new $fbase.err");
} else {
  system("mv $fbase.err $fbase.old");
}
