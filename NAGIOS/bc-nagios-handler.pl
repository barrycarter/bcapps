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

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# if host is down, write to ERR
# if we're seeing a recovery, remove error file

$fbase = "/home/barrycarter/ERR/nagios.$ENV{NAGIOS_HOSTALIAS}";
if ($ENV{NAGIOS_HOSTSTATEID}) {
  write_file_new("nagios.$ENV{NAGIOS_HOSTALIAS}.down", "$fbase.err");
} else {
  system("mv $fbase.err $fbase.old");
}

# if there is no NAGIOS_SERVICECHECKCOMMAND, this was a host check and
# we should stop here

unless ($ENV{NAGIOS_SERVICECHECKCOMMAND}) {exit(0);}

# TODO: during testing only
$dbgfile = "/var/tmp/nagios/".`date +%Y%m%d.%H%M%S.%N`;
$dbgfile=~s/\s*$//isg;
open(A,">$dbgfile.$$");
for $i (sort keys %ENV) {
  print A "$i -> $ENV{$i}\n";
}

print A "whoami: `whoami`\n";

# if service is down or recovering
$fbase = "/home/barrycarter/ERR/nagios.$ENV{NAGIOS_HOSTALIAS}.$ENV{NAGIOS_SERVICEDESC}";

# service recovery? remove error file and exit
unless ($ENV{NAGIOS_SERVICESTATEID}) {
  print A "$ENV{NAGIOS_HOSTALIAS}.$ENV{NAGIOS_SERVICEDESC} is now fine\n";
  system("mv $fbase.err $fbase.old");
  exit;
}

print A "$ENV{NAGIOS_HOSTALIAS}.$ENV{NAGIOS_SERVICEDESC} is down\n";

# no point in rewriting file if it already exists (but this shouldnt
# happen since nagios only calls me on statechange?)
unless (-s "$fbase.err") {
  write_file_new("nagios.$ENV{NAGIOS_HOSTALIAS}.$ENV{NAGIOS_SERVICEDESC}.down", "$fbase.err");
}

# TODO: hardcoding here is bad
# fix errors when possible

if ("$ENV{NAGIOS_HOSTALIAS}.$ENV{NAGIOS_SERVICEDESC}" eq "localhost.smtp") {
  print A "Trying to fix...\n";
  # kill off any existing commands with my mtun user
  system("sudo pkill -9 -f $secret{mtun_user}");
  # and reconnect
  system("sudo ssh -L 25:127.0.0.1:25 $secret{mtun_user} -N 1> $dbgfile.out 2> $dbgfile.err &");
}

if ("$ENV{NAGIOS_HOSTALIAS}.$ENV{NAGIOS_SERVICEDESC}" eq "localhost.sshfs2") {
  print A "Trying to fix...\n";

  # kill all bcpc related processes usings its secret name
  system("sudo pkill -9 -f $secret{bcpc_name}; sudo umount /mnt/sshfs2");
  # and restart
  system("sudo -u $secret{bcpc_local_user} sshfs -o allow_other $secret{bcpc_user}\@secret{bcpc_name}:/cygdrive /mnt/sshfs2");
}

