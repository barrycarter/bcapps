#!/bin/perl

# Computes well known "important" dates

require "/usr/local/lib/bclib.pl";

weekdayAfterDate("20150227","0",3);

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
