#!/bin/perl

# In rare cases, you can't IMAP/POP down google mail (eg, third party
# provider); this kludge creates an iMacro script that may help (even
# 'downthemall' won't handle google's bizarre linking format)

require "/usr/local/lib/bclib.pl";

# input should be save of gmail inbox page; if multiple pages, must
# call script multiple times

while (<>) {
  while (s/(\[\".*?\")//s) {
    debug("1: $1");
  }
}



