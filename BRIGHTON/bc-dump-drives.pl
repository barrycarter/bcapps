#!/bin/perl

TODO: this is just egrep -v '^#|^$' BRIGHTON/mounts.txt

corrected:

egrep -v '^#|^$' /home/user/BCGIT/BRIGHTON/mounts.txt | perl -nle 'print "sudo /home/user/BCGIT/BACKUP/bc-unix-dump.pl $_ &"'

above piped to shell

=item comment

# the below does this, no need for this proggie

egrep -v '^#|^$' BRIGHTON/mounts.txt | perl -nle 'print "bc-unix-dump.pl $_ &"'

=cut

# runs bc-unix-dump on all files in mounts.txt

require "/usr/local/lib/bclib.pl";

my(@mounts) = `egrep -v '^#|^\$' $bclib{githome}/BRIGHTON/mounts.txt`;

debug(@mounts);

