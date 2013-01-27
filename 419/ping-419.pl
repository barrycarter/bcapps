#!/bin/perl

# Ping a list of potential 419 scammers with a generic message;
# however, make the To: address their actual address instead of
# bcc'ing to be more convincing

# TODO: let from be "Name <email>", currently must be pure email addr

# TODO: tag emails somehow to recognize when they come back

# TODO: add sent flag to people Ive emailed to avoid dupes (until they
# are confirmed as scammers)

require "/usr/local/lib/bclib.pl";

# check valid call
$usagestring="$0 --from=from --to=filename --subject=subject message_file";
for $i ("from","to","subject") {unless ($globopts{$i}) {die $usagestring;}}
my($msg,$fname) = cmdfile();
my($tolist) = read_file($globopts{to});
unless ($tolist) {die "$tolist appears to be empty";}

# TODO: keep track of who i sent to in order to avoid duplicates
# TODO: report addresses that bounce
for $i (split(/\n/,$tolist)) {
  debug("I: $i");
  if ($i=~/^\#/) {next;}
  # HACK: during testing, the emails are sent to me FROM the scammer
  debug(sendmail($globopts{from}, $i, $globopts{subject}, $msg));
}







