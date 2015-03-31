#!/bin/perl

# Computes well known "important" dates [assuming no major schedule changes]

require "/usr/local/lib/bclib.pl";

# TODO: http://www.un.org/en/events/observances/days.shtml
# TODO: http://www.timeanddate.com/holidays/ (or maybe not)
# TODO: more?
# TODO: children's day, us tennis open

# TODO: Chinese/Jewish/other New Years, Diwali, Islamic holidays

%fixed = (
	  "New Years Day" => "0101",
	  "Valentine's Day" => "0214",
	  "April Fool's" => "0401",
	  "Independence Day" => "0704",
	  "Veterans Day" => "1111",
	  "Christmas" => "1225",
	  "Christmas Eve" => "1224",
	  "Halloween" => "1031",
	  "St Patrick's Day" => "0317",
	  "Groundhog Day" => "0202",
	  "Tax Day" => "0415",
	  "Earth Day" => "0422",
	  "Cinco de Mayo" => "0505",
	  "Citizenship Day" => "0917",
	  "Rememberence Day" => "0911",
	  "Boss's Day" => "1016",
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
	  "Teachers Day" => "1005",
	  "Statistics Day" => "1020",
	  "Tolerance Day" => "1116",
	  "AIDS Day" => "1201",
	  "Human Rights Day" => "1210",
	  "Nurses Week" => "0506",
	  "Nurses Day" => "0512",
	  "" => ""
	  );

delete $fixed{""};

# TODO: Hannukah, equinox/solstices, Easter/Mardi Gras/Ash
# Wednesday/Good Friday, when holidays fall on weekend, Black Friday?,
# Earth Hour??, NBA Championships, World Cup (soccer/cricket), PGA (as
# one offs), All-Star game

# instead of printing, storing to array so I can put into multiple
# formats (can't be a hash, multiple values for one key in either
# direction)

my(@dates);

for $i (2015..2037) {

  # fixed dates
  for $j (keys %fixed) {push(@dates, "${i}$fixed{$j}", $j);}

  # http://en.wikipedia.org/wiki/National_Day_of_Prayer
  push(@dates, weekdayAfterDate("${i}0501", 4, 0), "Prayer Day");

  # per http://en.wikipedia.org/wiki/Men%27s_major_golf_championships
  push(@dates, datePlusDays(weekdayAfterDate("${i}0401",0,1),-3), "Masters (golf)");
  push(@dates, datePlusDays(weekdayAfterDate("${i}0601",0,2),-3), "US Open (golf)");

  # per http://www.unesco.org/new/en/unesco/events/prizes-and-celebrations/celebrations/international-days/
  push(@dates, weekdayAfterDate("${i}1101",4,2),"Philosophy Day");

  # http://en.wikipedia.org/wiki/Children%27s_Day#United_States_of_America
  push(@dates, weekdayAfterDate("${i}0601",0), "Children's Day");

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
  push(@dates, weekdayAfterDate("${i}0501", "0", 1), "Mothers Day");
  # same day below
  push(@dates, weekdayAfterDate("${i}0601", "0", 2), "Fathers Day");
  push(@dates, weekdayAfterDate("${i}0601", "0", 2), "US Open Golf Finals");
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
  push(@dates, $grandparentday, "Grandparent's Day");
  # below is last monday of may and previous Sunday
  $memday = weekdayAfterDate("${i}0601", "1", -1);
  $indiana500 = weekdayAfterDate($memday, "0", -1);
  push(@dates, $memday, "Memorial Day");
  push(@dates, $indiana500, "Indianapolis 500");
  push(@dates, weekdayAfterDate("${i}0701", "0", 3), "Parents Day");
  push(@dates, weekdayAfterDate("${i}1001", "6", 2), "Sweetest Day");

  # per wikipedia, "Monday falling between 20 and 26 June"but moved
  # back a week, so between 27 Jun and next Monday
  $wimbs = weekdayAfterDate("${i}0627", "1", 0);
  $wimbe = weekdayAfterDate($wimbs, 0, 1);
  push(@dates, $wimbs, "Wimbledon starts");
  push(@dates, $wimbe, "Wimbledon ends");

  # per http://sports.espn.go.com/espn/columns/story?page=wojciechowski-111018
  # this may change, then again, any of these might
  push(@dates, weekdayAfterDate("${i}1001", 0, 2), "World Series");

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

  # this is silly
  my($uid) = sha1_hex("$date $event");

  print B "$date $event\n";

  # ics format
  print A << "MARK";
BEGIN:VEVENT\r
SUMMARY:$event\r
UID:$uid\r
DTSTART:${date}T000000Z\r
DTEND:${date}T235959Z\r
END:VEVENT\r
MARK
;
}

print A "END:VCALENDAR\r\n";

close(A);close(B);

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

