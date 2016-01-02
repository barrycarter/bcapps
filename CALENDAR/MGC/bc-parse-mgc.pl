#!/bin/perl

# Parses events at NDBC and MMMC (Albuquerque Multigenerational
# Centers) and adds them to meetup.com (which I'm beginning to think
# may be a bad idea)

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# workdir
chdir("/usr/local/etc/MGC/")||die("Can't chdir, $!");

# things that are considered locations
my(%locations) = list2hash(split(/\n/,
 read_file("$bclib{githome}/CALENDAR/MGC/locations.txt")));

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

for $i (split(/\n/,read_file("$bclib{githome}/CALENDAR/MGC/mmmc.txt"))) {

  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}

  debug(unfold(create_event_from_data_list(split(";",$i))));
}

# this returns a *list* of hashes (important!)
sub create_event_from_data_list {
  my(@data) = @_;
  my(@events,@times);

  # data that applies to all events, if multiple dates
  my(%metaevent);
  # first element is always the event title
  $metaevent{title} = shift(@data);

  for $i (@data) {
    $i=~s/^\s*//;
    if ($i=~/\"/) {$metaevent{description} = $i; next;}
    if ($locations{$i}) {$metaevent{location} = $i; next;}

    # treat everything else like a date list (and complain if not)
    # TODO: THIS IS HARDCODED TO JAN 2016 FOR NOW
    @times = parseDateString($i,1,2016);
  }

  unless (@times) {die "could not parse: $metaevent{title}";}

  debug("TIMES",@times);

  for ($i=0; $i<=$#times; $i+=2) {
    # create actual events
    my(%event);
    
    # copy data from metaevent
    for $j (keys %metaevent) {$event{$j} = $metaevent{$j};}

    # and set start/end dates
    $event{starttime} = $times[$i*2];
    $event{endtime} = $times[$i*2+1];

    # and push to list of events I will return
    push(@events, \%event);
  }

  return @events;

}


# given one of the date formats above, return a list of Unix time
# pairs of start and end times (with end time being optional), for a
# given month and year (ignoring events that started [TODO: ended?] before now)

sub parseDateString {

  my($str,$mon,$yr) = @_;
  my($stime,$etime,@res);

  # handle "stardate" format
  if ($str=~s/^(\d{8}):(.*)$//) {
    my($sdate,$time) = ($1,$2);
    ($stime,$etime) = split(/\-/,$time);
    # ok to overwrite here, not going thru loop below
    $stime = str2time("$sdate $stime MST7MDT");
    # too early
    if ($stime < time()) {next;}
    $etime = $etime?str2time("$sdate $etime MST7MDT"):"";
    # this is a one-element list whose element is a list of two elements
    return [$stime,$etime];
  }

  # need 2 digit months for matching
  $mon = sprintf("%02d",$mon);

  my(@which,@wdays);

  # TODO: ignoring special case of fixed stardate for now
  # numeric specifier (if any) pre weekday list
  # if no specifier "first 6" of month which is all (+ overkill on 6?)
  if ($str=~s/^([\d]+)//) {@which = split(//,$1)} else {@which=(1,2,3,4,5,6);}

  # now the weekdays
  if ($str=~s/^([xmtwrfs]+)//i) {
    @wdays=split(//,$1);
    # map dates to numbers
    map($_=$wday{lc($_)},@wdays);
  }

  # what's leftover is start and end time (end might be empty)
  my($stime,$etime) = split(/\-/,$str);

  # and loop
  for $i (@which) {
    for $j (@wdays) {

      # compute "stardate" of this event
      my($sdate) = weekdayAfterDate("$yr${mon}01",$j,$i-1);

      # ignore dates not in current month
      unless ($sdate=~/^$yr$mon/) {next;}

      # ignore closure dates
      if ($closed{$sdate}) {next;}

      # TODO: figure out what to do w/ no start time
      unless ($stime) {warn "NO STIME ($str), IGNORING"; next;}
      # unix start and end times
      my($ustime) = str2time("$sdate $stime MST7MDT");
      if ($ustime < time()) {next;}
      # note that end date is ALSO $sdate
      my($uetime) = $etime?str2time("$sdate $etime MST7MDT"):"";
      push(@res,[$ustime,$uetime]);
    }
  }
  debug("RETURNING",@{$res[0]});
  return @res;
}

sub weekdayAfterDate {
  my($date,$day,$n) = @_;
  my($time) = str2time("$date 12:00:00 UTC");
  # the -3 makes Monday = 1
  my($wday) = ($time/86400-3)%7;
  # add appropriate amount for first weekday after date
  $time += ($day-$wday)%7*86400 + $n*86400*7;
  return strftime("%Y%m%d", gmtime($time));
}
