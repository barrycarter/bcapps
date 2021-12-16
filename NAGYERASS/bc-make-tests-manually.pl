#!/bin/perl

# creates some tests manually instead of trying to use templates
# (ugly, but easier)

require "/usr/local/lib/bclib.pl";

dodie('chdir("/usr/local/etc/nagyerass")');

# for all drives in mounts.txt, confirm at least 10GB space left,
# write tests to test.d/drivespace.txt

open(A, ">tests.d/drivespace.txt");

for $i (`egrep -v '^#|^\$' $bclib{githome}/BRIGHTON/mounts.txt`) {

  my($mtpt, $name) = split(/\s+/, $i);

  print A << "MARK";

<test>
name=check_disk_space_$name
freq=600
cmd=check_disk -u GB -v -c 10 $mtpt
</test>

MARK
;

}

close(A);

# for domains in mydomains.txt (some of which are private), confirm
# nonexpiration

open(A, ">tests.d/domainexp.txt");

for $i (`egrep -v '^#|^\$' $bclib{home}/BCPRIV/mydomains.txt`) {

  # TODO: need to write domainexp function, the one in
  # ../NAGIOS/bc-nagios-test.pl checks all at once

  print B << "MARK";

<test>
name=check_domain_exp_$i
freq=86400
cmd = bc-call-func.pl domainexp $i
</test>

MARK
;

}
