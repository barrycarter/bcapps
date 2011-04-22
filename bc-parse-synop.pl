#!/bin/perl

# -nosql: dont run SQL commands, just print them out

# NOTE: far from ready to use!

require "bclib.pl";
($all, $arg) = cmdfile();
debug("PROCESSING FILE: $arg");

# do this only after we've got the data (in case user used short path)
chdir(tmpdir());

# current time
($ad,$ad,$ad,$DAY,$MON,$YEAR)=gmtime(time());
$YEAR+=1900; $MON++;

# remove DOS newlines
$all=~s/\r//isg;

# newlines preceded by non equal signs are merged into next line
$all=~s/([^\=])\n+/$1 /isg;

# go through each line

for $i (split("\n", $all)) {
  # ignore comments and empty lines
  if ($i=~/^\#|^\s*$/) {next;}

  # ignore useless things like "SMMH01 PKMR 221200"
  if ($i=~/^[a-z]+\d+ [a-z]{4} \d{6}/i) {next;}

  # ignore NIL data
  if ($i=~/^\d{5,}\s+nil\s*\=\s*$/i) {next;}

  %ac=parse_synop($i);

  # create query for db
  @f=();
  @v=();
  for $j (sort keys %ac) {
    push(@f,$j);
    $ac{$j}=~s/[^ -~]//isg; # remove nonprintable chars
    $ac{$j}=~s/\'//isg; # and apostrophes
    push(@v,"'$ac{$j}'");
  }

  $query="REPLACE INTO synop (".join(", ",@f).") VALUES (".join(", ",@v).")";
  push(@query,$query);

}

# delete old data
# TODO: should I use timestamp here? Bad data can have bad 'report dates'
push(@query,"DELETE FROM synop where unix_timestamp(now())-unix_timestamp(time)>86400");

open(A,">queries.txt");
for $i (@query) {print A "$i;\n";}
close(A);

debug(read_file("queries.txt"));

unless ($NOSQL) {
  warn "Do database stuff here";
}

# I realize Perl probably has a module for this, but I prefer my version
sub parse_synop {
  my($aa)=@_;
  my(@ab,%ac,$ad,$ae,$af,$ag,$ah,$ai);
  debug("PARSE_SYNOP($aa)");

  # get rid of equal sign and trailing junk
  $aa=~s/\=.*//;

  # split into fields
  @ab=split(/ /,$aa);

  $ah=shift(@ab);

  # only numerical fields have meaning in SYNOP
  unless ($ah=~/^\d+$/) {
    warnlocal("Ignoring: $ah");
    $ah = shift(@ab);
  }

  # first legit field is weather station number
  $ac{wmostat}=$ah;


#  if ($ah==0) {
#    warn("BAD SYNOP (wmostat: 0): $aa");
#    return();
#  }

  # next field
  $ai=shift(@ab);

  # if next field is station id again, ignore
 if ($ai eq $ah) {$ai=shift(@ab);}

  # next field is
  # http://weather.unisys.com/wxp/Appendices/Formats/SYNOP.html#Nddff

  # Nddff = cloud cover, winddirection, windspeed
  if (shift(@ab)=~/^([\d\/])([\d\/]{2})([\d\/]{2})$/) {
    $ac{cloud}=$1; # in eighths
    $ac{winddir}=$2*10;
    $ac{windspeed}=$3; # knots
  } else {
    warn("BAD SYNOP: $aa");
    return();
  }

  # Valid SYNOP, so set time (see bc-parse-metar.pl for details)
  $ac{synop}=$aa;
  if ($day<=$DAY) {
    $ac{time}="$YEAR/$MON/$day $hour:00";
  } else {
    $af=$MON-1;
    if ($af==0) {$af=12; $ag=$YEAR-1;} else {$ag=$YEAR;}
    $ac{time}="$ag/$af/$day $hour:00";
  }

  # the remaining fields in any order, identified by first letter in field
  while ($ad=shift(@ab)) {

    # if field starts with xxx (eg, 333), it means following data is
    # in given group; $ae holds that group

    if ($ad=~/^(\d)\1\1$/) {$ae=$1; next;}

    # most data we want is in the 000 group (NOAA's SYNOP is special)
    # parse_synop_helper handles data outside the 000 group
    if ($ae) {
      ($key,$val)=parse_synop_helper($ad,$ae,%ac);
      $ac{$key}=$val;
      next;
    }

    # handle temperature and dewpoint reading
    if ($ad=~/^(1|2)(0|1)(\d{3})$/) {
      $ac{($1==1?"temperature":"dewpoint")}=$3/10*(0.5<=>$2);
      next;
    }

    # pressure, including unnormalized station pressure
    if ($ad=~/^(3|4)(\d{4})$/) {
      $ac{($1==3?"stationpressure":"pressure")}=$2/10+($2<5000)*1000;
      next;
    }

    # pressure delta (over 3 hrs here, over 24 hrs if in group 5)
    if ($ad=~/^5([0-8])(\d{3})/) {$ac{pressuredelta}=(4<=>$1)*$2; next;}

    # data I don't care about (rainfall amt/cloud type)
    if ($ad=~/^(6|8)([\d\/]{4})$/) {next;}

    # current weather
    if ($ad=~/^7(\d{2})(\d{2})$/) {$ac{weather}=$1; next;}

    warnlocal("NOT PARSED: $ad");
  }

  # other checks (like temp >= dp if both defined) could go here
  return(%ac);
}

# parse_synop_helper(item,group,hashref): parse for groups other than 000

sub parse_synop_helper {

  my($aa,$ab)=@_;

  # group 3 parsing
  if ($ab==3) {

    # High and low for last 24 hours
    if ($aa=~/^(1|2)(0|1)(\d{3})$/) {
      return($1==1?"high":"low",$3/10*(0.5<=>$2));
    }

    # pressure delta (over 3 hrs in main, over 24 hrs here) (???)
    if ($aa=~/^5([0-8])(\d{3})/) {return("pressuredelta",(4<=>$1)*$2);}

    # stuff I don't care about (4=snowcover, 6=precip 3h, 7=precip 24h)
    if ($aa=~/^(3|4|6|7|8)(\d{4})$/) {return;}

    # gusty winds
    if ($aa=~/^91([1-4])(\d{2})$/) {
      if ($1<=2) {return("windgust",$2);}
      return;
    }

    # leftovers
    warnlocal("NOT PARSED (GROUP 3): $aa");
    return;
  }

  # group 5 parsing
  if ($ab==5) {

    # I don't care about anything in this section
    if ($aa=~/^(1|2)([\d\/]{4})$/) {return;}

    # leftovers
    warnlocal("NOT PARSED (GROUP 5): $aa");
    return;
  }

  warnlocal("GROUP NOT UNDERSTOOD: $ab");
  return;
}
