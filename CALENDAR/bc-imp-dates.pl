#!/bin/perl

# Computes well known "important" dates [assuming no major schedule changes]

require "/usr/local/lib/bclib.pl";

# TODO: http://www.un.org/en/events/observances/days.shtml
# TODO: http://www.timeanddate.com/holidays/ (or maybe not)
# TODO: more?
# TODO: children's day

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
	  "" => ""
	  );

delete $fixed{""};

# TODO: Hannukah, equinox/solstices, Easter/Mardi Gras/Ash
# Wednesday/Good Friday, when holidays fall on weekend, Black Friday?,
# Earth Hour??, NBA Championships, World Cup (soccer/cricket), PGA (as
# one offs), All-Star game

for $i (2015..2037) {

  # fixed dates
  for $j (keys %fixed) {print "${i}$fixed{$j} $j\n";}

  # per http://www.unesco.org/new/en/unesco/events/prizes-and-celebrations/celebrations/international-days/
  print weekdayAfterDate("${i}1101",4,2)," Philosophy Day\n";


  print weekdayAfterDate("${i}0501", "6")," Kentucky Derby\n";
  print weekdayAfterDate("${i}0501", "6", 2)," Preakness\n";
  # Always in June
  print weekdayAfterDate("${i}0501", "6", 5)," Belmont Stakes\n";
  print weekdayAfterDate("${i}0201", "0"), " Super Bowl\n";
  print weekdayAfterDate("${i}0101", "1", 2), " MLK Day\n";
  print weekdayAfterDate("${i}1001", "1", 1), " Columbus Day\n";
  $thanks = weekdayAfterDate("${i}1101", "4", 3);
  $black =  weekdayAfterDate($thanks, 5, 0);
  print "$thanks Thanksgiving\n";
  print "$black Black Friday\n";
  print weekdayAfterDate("${i}0501", "0", 1), " Mothers Day\n";
  # same day below
  print weekdayAfterDate("${i}0601", "0", 2), " Fathers Day\n";
  print weekdayAfterDate("${i}0601", "0", 2), " US Open Golf Finals\n";
  print weekdayAfterDate("${i}0301", "0", 1), " DST +1 hour\n";
  print weekdayAfterDate("${i}1101", "0", 0), " DST -1 hour\n";
  # technically washington's birthday...
  print weekdayAfterDate("${i}0201", "1", 2), " President's Day\n";
  # grandparents day = first sunday after labor day
  my($laborday) = weekdayAfterDate("${i}0901", "1", 0);
  my($grandparentday) = weekdayAfterDate($laborday, "0", 0);
  my($pga) = weekdayAfterDate($laborday, "6", -4);
  # PGA is wonky next few years
#  print "$pga PGA Championship\n";
  print "$laborday Labor Day\n";
  print "$grandparentday Grandparent's Day\n";
  # below is last monday of may and previous Sunday
  $memday = weekdayAfterDate("${i}0601", "1", -1);
  $indiana500 = weekdayAfterDate($memday, "0", -1);
  print "$memday Memorial Day\n";
  print "$indiana500 Indianapolis 500\n";
  print weekdayAfterDate("${i}0701", "0", 3), " Parents Day\n";
  print weekdayAfterDate("${i}1001", "6", 2), " Sweetest Day\n";

  # per wikipedia, "Monday falling between 20 and 26 June" but moved
  # back a week, so between 27 Jun and next Monday
  $wimbs = weekdayAfterDate("${i}0627", "1", 0);
  $wimbe = weekdayAfterDate($wimbs, 0, 1);
  print "$wimbs Wimbledon starts\n";
  print "$wimbe Wimbledon ends\n";

  # per http://sports.espn.go.com/espn/columns/story?page=wojciechowski-111018
  # this may change, then again, any of these might
  print weekdayAfterDate("${i}1001", 0, 2), " World Series\n";

  $preelect = weekdayAfterDate("${i}1101", 1, 0);
  print weekdayAfterDate($preelect, 2, 0), " Election Day\n";



  # last Sunday in February (can be the Sunday the 29th, which is why
  # I need the special case below [otherwise would always be the 4th
  # Sunday in February])
#  print weekdayAfterDate("${i}0301", "0", -1), " Daytona 500\n";
  

}

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
