#!/bin/perl

# The final final step of the quest to find conjunctions: this takes
# the annmsepsdump dump files and converts them to a MySQL database

require "/usr/local/lib/bclib.pl";

my($date) = Astro::Nova::get_date(-3099716.496516);
my(@date) = ($date->get_years(), $date->get_months(),
	     $date->get_days(), $date->get_hours(),
	     $date->get_minutes(), $date->get_seconds());
debug("$jd ->",join(" ",@date));

die "TESTING";

warn "Ignoring multi-planet conjunctions (for now)";

for $i (glob "/home/barrycarter/SPICE/KERNELS/annmsepsdump*.txt") {
  my($all) = read_file($i);

  while ($all=~s/annminsep\[\{(.*?)\}\]\s*=\s*\{(\{.*?\})\}//s) {

    my($planets,$data) = ($1,$2);
    my(@planets) = split(/\,\s*/s,$planets);

    if (scalar(@planets)>2) {next;}

    while ($data=~s/\{(.*?)\}//s) {
      my($jd, $sep, $sun, $star, $ssep) = split(/\,\s*/s,$1);

      # get calendar date from Julian date
      # MySQL can't handle years < 100 so separate into fields
      $jd=~s/\*\^/e/;
      my($date) = Astro::Nova::get_date($jd);
      my(@date) = ($date->get_years(), $date->get_months(),
		   $date->get_days(), $date->get_hours(),
		   $date->get_minutes(), $date->get_seconds());
      debug("$jd ->",join(" ",@date));

#      $jd=sprintf("%0.6f",$jd);
      # TODO: serious yuck!
  #    my($out,$err,$res) = cache_command2("j2d $jd","age=9999999");
#      chomp($out);
#      debug("OUT: $out");

      debug("$planets/$jd/$sep/$sun/$star/$ssep");

      # TODO: turn this into an INSERT statement
      # TODO: breakup into year, month, day for searching
      # TODO: this won't work if more than 2 planets, fix
      # NOTE: including JD in final result can't use MySQL date, but also
      # doing year/month/day breakdown for ease of use
      print join("\t",@planets,$jd,"xxx",$sep,$sun,$star,$ssep),"\n";

    }
  }
}


