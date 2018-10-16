#!/bin/perl

# Trivial script: given a list of getmail log files, find last time
# mail successfully downloaded (0 message downloads don't count) +
# order by date

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {
  open(A, "tac $i| fgrep -v '0 messages (0 bytes) retrieved, 0 skipped' | fgrep -v 'Initializing SimpleIMAPSSLRetriever'| fgrep -v 'getmailOperationError error'|");

  while (<A>) {
    debug("GOT: $_");
  }
}
