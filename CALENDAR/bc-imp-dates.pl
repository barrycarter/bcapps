#!/bin/perl

# Computes well known "important" dates [assuming no major schedule changes]

require "/usr/local/lib/bclib.pl";
my(@dates);

my(@fields) = ("name", "location", "desc", "date", "ncs", "notes");

# Courtesy Emilie C., more info for the vcalendar version
my(@all) = split(/\n/,read_file("$bclib{githome}/CALENDAR/impdates-data.txt"));

for $i (@all) {
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}
  @data = split(/\|/,$i);
  for $j (0..$#fields) {$data{$data[0]}{$fields[$j]} = $data[$j];}
}

# to avoid certain repeats
my(%seen);

# TODO: http://www.un.org/en/events/observances/days.shtml
# TODO: http://www.timeanddate.com/holidays/us/ (or maybe not)

# TODO: http://nationaldaycalendar.com/calendar-at-a-glance/ (maybe,
# also downloaded to /home/barrycarter/20150806 (in the _001 files))

# TONOTDO:
# http://snap.nal.usda.gov/nutrition-through-seasons/holiday-observances
# (too silly, but did create other calendar for this)

# TODO: more?
# TODO: re-add children's day (if I find canonical), us tennis open

# TODO: other New Years?, Diwali, more Islamic holidays

%fixed = (
	  "New Years Day" => "0101",
	  "Valentine's Day" => "0214",
	  "April Fool's" => "0401",
	  "Independence Day" => "0704",
	  "Veterans Day" => "1111",
	  "Christmas" => "1225",
	  "Christmas Eve" => "1224",
	  "Halloween/Reformation" => "1031",
	  "St Patrick's Day" => "0317",
	  "Groundhog Day" => "0202",
	  "Tax Day" => "0415",
	  "Earth Day" => "0422",
	  "Cinco de Mayo" => "0505",
	  "Citizenship Day" => "0917",
	  "Remembrance Day" => "0911",
	  "Bosses' Day" => "1016",
	  "New Year's Eve" => "1231",
	  "Pearl Harbor Day" => "1207",
	  "Susan B Anthony Day" => "0215",
	  "Flag Day" => "0614",
	  "Bastille Day" => "0714",
	  "Poetry Day" => "0321",
	  "Jazz Day" => "0430",
	  "Nelson Mandela Day" => "0718",
	  "Youth Day" => "0812",
	  "Literacy Day" => "0908",
	  "Peace Day" => "0921",
#	  "Teachers Day" => "1005",
	  "Statistics Day" => "1020",
	  "Tolerance Day" => "1116",
	  "AIDS Day" => "1201",
	  "Human Rights Day" => "1210",
	  "Nurses Week" => "0506",
	  "Nurses Day" => "0512",
	  "Boxing Day" => "1226",
	  "All Saints Day" => "1101",
	  "All Souls Day" => "1102",
	  "St Peter/Paul Day" => "0629",
	  "QE II Birthday" => "0421",
#	  "UN Children's Day" => "1120",
	  "JFK Birthday" => "0529",
	  "Guy Fawke's Day" => "1105",
	  "Running of Bulls" => "0707",
	  "Pi Day" => "0314",
	  "Womens = Day" => "0826",
	  "Juneteenth" => "0619",
	  "" => ""
	  );

# dropped teachers and childrens days since there are many of these

# NOTE: some former British colonies bump Boxing Day to the 27th if it
# falls on a Sunday. I don't

delete $fixed{""};

# from gcal's massive list of holidays
# removed childrens day, not canon
my($out,$err,$res) = cache_command2("egrep -i 'cycle 78|zod|islamic|ramadan|purim\/|arbor day us|passover|easter sunday|mardi gras|ash wednesday|passion sunday|good friday|pentecost|whit monday|rosh|palm sunday|yom kippur|Hannukah|kwanzaa|diwali' $bclib{githome}/ASTRO/bc-gcal-filter-out.txt","age=86400");

for $i (split(/\n/,$out)) {

  # stop at the year 2037 (not necessarily sorted, so can't 'last' here)
  $i=~s/^(\d{8})\s+//;
  my($date) = $1;
  if ($date>20379999) {next;}

  # ignore zodiac events not relating to a constellation, fix others
  if ($i=~/Zod$/) {
    # TODO: Capricornus -> Capricorn, Scorpius -> Scorpio, etc?
    # NOTE: XX below because I trim last field later
    unless ($i=~s%^.*/(.*?)\[.*$%Sun -> $1 XX%) {next;}
  }

  # ignore orthodox Easter/Palm Sunday (before we cleanup the last field)
  if ($i=~/(easter sunday|palm sunday|good friday|Pentecost)/i && $i=~/,OxN,/) {next;}

  # ignore non US Children's Day
  if ($i=~/Children\'s Day/ && $i!~/,US_/) {next;}

  # ignore Cyprussian Whit Monday
  if ($i=~/Whit Monday CY/) {next;}

  # the last field is always a comma-separated list of where
  # celebrated, useless to me
  $i=~s/\s+\S+$//;

  # cleanups
  $i=~s%(shrove tuesday|whitsunday|pesach)/%%i;
  $i=~s%/(atonement day|festival of lights|feast of lots)%%i;
  $i=~s%Ramadan%Ramadan starts%i;
  $i=~s%Islamic New Year\'s Day%Islam NY%i;

  # TODO: fix double chinese new year to use 2nd date?
  debug("I: $i");
  if ($i=~s%Cycle 78\/(\d+)\-\d+ .*?/([^/]*?)$%Chinese NY ($2)%i) {
    # already have a CNY for this cycle
    if ($seen{cny}{$1}) {next;}
    $seen{cny}{$1}=1;
  }


  # only the first of two Rosh Hashana
  if ($i=~/Rosh Hashana/i) {
    $i=~s%/New Year\'s Day%%;
    unless ($i=~/\d{4}$/) {next;}
  }

  debug("PUSHING: $date $i");

  push(@dates, $date, $i);
}

# TODO: equinox/solstices (these do appear in another one of my
# calendars), when holidays fall on weekend, Earth Hour??, NBA
# Championships, World Cup (soccer/cricket), All-Star game

# instead of printing, storing to array so I can put into multiple
# formats (can't be a hash, multiple values for one key in either
# direction)

for $i (2015..2037) {

  # fixed dates
  for $j (keys %fixed) {push(@dates, "${i}$fixed{$j}", $j);}

  # Gilroy Garlic Festival (last weekend in July, Sunday must be in July)
  push(@dates, datePlusDays(weekdayAfterDate("${i}0801", 0, -1),-2),
       "Gilroy GarlicFest");

  # http://en.wikipedia.org/wiki/Friendship_Day (first Sunday)
  push(@dates, weekdayAfterDate("${i}0801",0,0), "Friendship Day");

  # http://nationaldaycalendar.com/national-mother-in-law-day-fourth-sunday-in-october/
  push(@dates, weekdayAfterDate("${i}1001",0,3), "Mother-in-Law Day");

  # http://en.wikipedia.org/wiki/Armed_Forces_Day#United_States
  push(@dates, weekdayAfterDate("${i}0501",6,2,), "Armed Forces Day");

  # http://en.wikipedia.org/wiki/National_Day_of_Prayer
  push(@dates, weekdayAfterDate("${i}0501", 4, 0), "Prayer Day");

  # per http://en.wikipedia.org/wiki/Men%27s_major_golf_championships
  push(@dates, datePlusDays(weekdayAfterDate("${i}0401",0,1),-3), "Masters (golf)");
  push(@dates, datePlusDays(weekdayAfterDate("${i}0601",0,2),-3), "US Open (golf)");

  # per http://www.unesco.org/new/en/unesco/events/prizes-and-celebrations/celebrations/international-days/
  push(@dates, weekdayAfterDate("${i}1101",4,2),"Philosophy Day");

  # http://en.wikipedia.org/wiki/Children%27s_Day#United_States_of_America
  # ignoring except as above
  # push(@dates, weekdayAfterDate("${i}0601",0), "Children's Day");

  push(@dates, weekdayAfterDate("${i}0501", "6"),"Kentucky Derby");
  push(@dates, weekdayAfterDate("${i}0501", "6", 2),"Preakness");
  # Always in June
  push(@dates, weekdayAfterDate("${i}0501", "6", 5),"Belmont Stakes");
  push(@dates, weekdayAfterDate("${i}0201", "0"), "Super Bowl");
  push(@dates, weekdayAfterDate("${i}0101", "1", 2), "MLK Day");
  push(@dates, weekdayAfterDate("${i}1001", "1", 1), "Columbus Day");
  $thanks = weekdayAfterDate("${i}1101", "4", 3);
  $black =  weekdayAfterDate($thanks, 5, 0);
  push(@dates, $thanks, "Thanksgiving");
  push(@dates, $black, "Black Friday");
  push(@dates, weekdayAfterDate("${i}0501", "0", 1), "Mothers' Day");
  # same day below
  push(@dates, weekdayAfterDate("${i}0601", "0", 2), "Fathers' Day");
  push(@dates, weekdayAfterDate("${i}0601", "0", 2), "US Open Golf Final");
  push(@dates, weekdayAfterDate("${i}0301", "0", 1), "DST +1 hour");
  push(@dates, weekdayAfterDate("${i}1101", "0", 0), "DST -1 hour");
  # technically washington's birthday...
  push(@dates, weekdayAfterDate("${i}0201", "1", 2), "President's Day");
  # grandparents day = first sunday after labor day
  my($laborday) = weekdayAfterDate("${i}0901", "1", 0);
  my($grandparentday) = weekdayAfterDate($laborday, "0", 0);
  my($pga) = weekdayAfterDate($laborday, "4", -4);
  push(@dates, $pga, "PGA Championship");
  push(@dates, $laborday, "Labor Day");
  push(@dates, $grandparentday, "Grandparents' Day");
  # below is last monday of may and previous Sunday
  $memday = weekdayAfterDate("${i}0601", "1", -1);
  $indiana500 = weekdayAfterDate($memday, "0", -1);
  push(@dates, $memday, "Memorial Day");
  push(@dates, $indiana500, "Indianapolis 500");
  push(@dates, weekdayAfterDate("${i}0701", "0", 3), "Parents' Day");
  push(@dates, weekdayAfterDate("${i}1001", "6", 2), "Sweetest Day");

  # per wikipedia, "Monday falling between 20 and 26 June"but moved
  # back a week, so between 27 Jun and next Monday
  $wimbs = weekdayAfterDate("${i}0627", "1", 0);
  $wimbe = weekdayAfterDate($wimbs, 0, 1);
  push(@dates, $wimbs, "Wimbledon starts");
  push(@dates, $wimbe, "Wimbledon ends");

  # per http://sports.espn.go.com/espn/columns/story?page=wojciechowski-111018
  # this may change, then again, any of these might

  # World Series schedule has gone wonky, no longer automatic
#  push(@dates, weekdayAfterDate("${i}1001", 0, 2), "World Series");

  $preelect = weekdayAfterDate("${i}1101", 1, 0);
  push(@dates, weekdayAfterDate($preelect, 2, 0), "Election Day");

  # last Sunday in February (can be the Sunday the 29th, which is why
  # I need the special case below [otherwise would always be the 4th
  # Sunday in February])
#  print weekdayAfterDate("${i}0301", "0", -1), " Daytona 500\n";

}

open(A,">$bclib{githome}/BCINFO3/sites/data/calendar/bcimpdates.ics");
print A << "MARK";
BEGIN:VCALENDAR\r
VERSION:2.0\r
PRODID: -//barrycarter.info//bc-imp-dates.pl//EN\r
MARK
;

# this is the "flat calendar" version bc-calendar.pl uses
open(B,">/home/barrycarter/calendar.d/flatcal.txt");

while (@dates) {
  my($date,$event) = splice(@dates,0,2);

  if ($event=~/^(.*?)\s*\d*$/) {$data{$event} = $data{$1}; $used{$1}=1;}
  if ($event=~/^DST/) {$data{$event} = $data{DST}; $used{DST}=1;}

  # this is silly
  my($uid) = sha1_hex("$date $event");

  print B "$date $event\n";

  # ics format, local time zone so no "leakage" into other days
  print A << "MARK";
BEGIN:VEVENT\r
SUMMARY:$event\r
UID:$uid\r
DTSTART:${date}T000000\r
DTEND:${date}T235959\r
LOCATION: $data{$event}{location}\r
DESCRIPTION: $data{$event}{desc}\r
COMMENT: $data{$event}{notes}\r
END:VEVENT\r
MARK
;

# this lets me see what events are missing (usually due to typos)
$used{$event}=1;

}

print A "END:VCALENDAR\r\n";

close(A);close(B);

# keys in data not used
for $i (keys %data) {unless ($used{$i}) {warn("UNUSED: $i");}}
# holidays not annotated (not really an error)
for $i (keys %used) {unless ($data{$i}) {warn("UNANNOTATED: $i");}}

# computes the nth "weekday" after or on given date (yyyymmdd format)

sub weekdayAfterDate {
  my($date,$day,$n) = @_;
  my($time) = str2time("$date 12:00:00 UTC");
  # the -3 makes Monday = 1
  my($wday) = ($time/86400-3)%7;
  # add appropriate amount for first weekday after date
  $time += ($day-$wday)%7*86400 + $n*86400*7;
  return strftime("%Y%m%d", gmtime($time));
}

# add days from given yyyymmdd "stardate"

sub datePlusDays {
  my($date,$days) = @_;
  return strftime("%Y%m%d", gmtime(str2time($date)+86400*$days));
}
