#!/bin/perl -0777
# note: above slurps STDIN in one gulp

# Uses sendmail -t to send email, but cleans it up a bit first
require "/usr/local/lib/bclib.pl";

# this is really really really really bad (also, it's bad)
$file = "/var/tmp/mail.".`date +%Y%m%d.%H%M%S.%N`;
chomp($file);

$all = <STDIN>;

# write unaltered stdin to file (for testing)
write_file($all, "$file.pre");

# alterations

# split into head/body
$all=~m/^(.*?)\n\n(.*)$/is;
my($head,$body) = ($1,$2);

# find from address
unless ($head=~/^From: .*?<(.*?)>/img) {
  # TODO: something
  exit();
}

$from = $1;

# tweak wordpress\@wordpress.barrycarter.info (no mail on that domain)
$from=~s/\@wordpress\.barrycarter\.info$/barrycarter.info/;

# add return receipt
$head = "$head\nReturn-Receipt-To: $from";

# write modified to new file
write_file("$head\n\n$body", "$file.post");

# TODO: actually send mail!









