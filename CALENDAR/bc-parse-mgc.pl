#!/bin/perl

# Parses events at NDBC and MMMC (Albuquerque Multigenerational
# Centers) and adds them to meetup.com (which I'm beginning to think
# may be a bad idea)

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# workdir
chdir("/usr/local/etc/MGC/")||die("Can't chdir, $!");

# events already added

my(%seen);
warn "caching...";
my($out,$err,$res) = cache_command2("curl 'http://api.meetup.com/Albuquerque-Multigenerational-Center-Events-unofficial/upcoming.ical'","age=3600");
write_file($out,"upcoming.ical");

# only unix nls permitted
$out=~s/\r//g;

while ($out=~s/BEGIN:VEVENT(.*?)END:VEVENT//s) {
  my($event) = $1;
  my(%hash);

  # for now, assuming that start/end date + summary (name) are unique
  # the .*? below allows for things like ";TZID=America/Denver"
  while ($event=~s/(SUMMARY|DTSTART|DTEND|UID).*?:(.*?)\n//s) {$hash{$1}=$2;}

  # change \n to ^j (so it won't get killed by next line)
  $hash{SUMMARY}=~s/\\n/\n/sg;

  # remove backslashes from event
  $hash{SUMMARY}=~s/\\//g;

  # string to check

  my($str) = join("|", urlencode($hash{SUMMARY}),str2time($hash{DTSTART}));

  if ($seen{$str}) {
    warn "EXISTING DUPLICATE: $str ($hash{UID})";
  } else {
    $seen{$str} = 1;
  }
}

write_file(join("\n",keys %seen),"seen.txt");

# files to parse: ndbc.txt mmmc.txt manzano.csv (latter in diff format)

for $i (split(/\n/,read_file("$bclib{githome}/CALENDAR/mmmc.txt"))) {

  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  create_event_from_data_list(split(";",$i));
}


sub create_event_from_data_list {
  my(@data) = @_;
  my(%event);

  # first element is always the event title
  $event{title} = shift(@data);

  for $i (@data) {
    debug("I: $i");
  }


}
