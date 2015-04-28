#!/bin/perl

# parsing fetlife user data into subroutine

require "/usr/local/lib/bclib.pl";

# fields from location sucking
# id,screenname,thumbnail,age,gender,role,loc1,loc2,page_number,scrape_time

my(%res) = fetlife_user_data(join("",`bzcat /usr/local/etc/FETLIFE/user4608502.bz2`));

debug(unfold(\%res));

=item fetlife_user_data($data)

Given a string that represents a FetLife users profile data, return a
hash of specific data

=cut

sub fetlife_user_data {
  my($all) = @_;
  my(%data);
  # TODO: decide if %meta is useful to me in some way
  my(%meta);

  # inactive profile
  if ($all=~s%You are being <a href="https://fetlife.com/home">redirected</a>.</body></html>%%) {
    $data{latestactivity} = "inactive";
    return %data;
  }

  # thumbnail URL (correct 200 to 60 for consistency)
  # TODO: check this degrades nicely if no thumb/blank thumb
  $all=~s%(https://fl.*?_200\.jpg)%%;
  $data{thumbnail} = $1;

  # get rid of footer
  $all=~s/<em>going up\?<\/em>.*$//s;

  # title (= username)
  $all=~s%<title>(.*?) - Kinksters - FetLife</title>%%s||warn("BAD TITLE: $all");
  $data{name} = $1;

  # number
  $all=~s%"/conversations/new\?with=(\d+)"%%;
  $data{num} = $1;

  # after getting title, get rid of header
  $all=~s%^.*</head>%%s;

  # latest activity (could get all activity on front page, but no)
  $all=~s%<span class="quiet small">(.*? ago)</span>%%;
  # leaving this in "fetlife format", like "3 hours ago"
  $data{latestactivity} = $1;

  # after getting latest activity, nuke the activity feed, it interferes
  $all=~s%<ul id="mini_feed">(.*?)</ul>%%s;

  # now grab events (but not those in activity feed)
  while ($all=~s%<a href="/events/(\d+)">(.*?)<%%s) {
    $data{event}{$2} = 1;
    $meta{event}{$2}{number} = $1;
  }

  # number of pics (may have commas)
  if ($all=~s/view pics.*?\(([\,\d]+)\)//) {
    $data{npics} = $1;
    $data{npics}=~s/,//g;
  }

  # and vids
  if ($all=~s/view vids.*?\(([\,\d]+)\)//) {
    $data{nvids} = $1;
    $data{nvids}=~s/,//g;
  }

  # number of friends (may have commas)
  if ($all=~s%Friends <span class="smaller">\(([\d\,]+)\)</span>%%s) {
    $data{nfriends} = $1;
    $data{nfriends}=~s/,//g;
  }

  # age, and orientation/gender
  $all=~s%<h2 class="bottom">$data{name}\s*<span class="small quiet">(\d+)(.*)\s+(.*?)</span></h2>%%||warn("NO EXTRA DATA($i): $all");
  ($data{age}, $data{gender}, $data{role}) = ($1, $2, $3);

  # city if first /cities link in page
  # TODO: get state/etc
  while ($all=~s%<a href="/(cities|administrative_areas|countries)/(\d+)">(.*?)</a>%%) {
    $data{$1} = $3;
    $meta{$1}{$3}{number} = $2;
  }

  # "realify" quotes (needed for csv below)
  $all=~s/\&quot\;/\"/sg;

  # get groups
  # TODO: exclude activity feed!
  while ($all=~s/<li><a href="\/groups\/(\d+)">(.*?)<\/a><\/li>//s) {
    $data{groups}{$2} = $1;
  }

  # get fetishes in better way
  while ($all=~s/(Into|Curious about):(.*)$//m) {
    my($type, $fetishes) = ($1, $2);

    # look for ones with role attached first
    while ($fetishes=~s%<a href="/fetishes/(\d+)">([^<>]*?)</a>\s*<span class="quiet smaller">\((.*?)\)</span>%%) {
      $data{fetish}{$type}{$2} = $3;
      $meta{fetish}{$2}{number} = $1;
    }

    # ones without a role
    while ($fetishes=~s%<a href="/fetishes/(\d+)">([^<>]*?)</a>%%) {
      $data{fetish}{$type}{$2} = 1;
      $meta{fetish}{$2}{number} = $1;
    }

    # make sure we got them all
    $fetishes=~s/<.*?>//g;
    $fetishes=~s/[\,\s\.]//g;
    if ($fetishes) {warn "LEFTOVER FETISHES: $fetishes";}
  }

  # table fields with headers/colons
  # TODO: "looking for" is multivalued
  # TODO: "relationships in" is multivalued (but may not be of interest,
  # except for 6 degrees stuff?, which wouldn't include "friends" in general?)
  while ($all=~s%<tr>\s*<th[^>]*>(.*?)</th>\s*<td>(.*?)</td>\s*</tr>%%is) {
    ($key, $val) = (lc($1),$2);
    $key=~s/:\s*$//isg;
    $key=~s/[\/\s]//isg;
    $val=~s/\'//isg;
    $data{$key} = $val;
  }

  # parse out relationshipstatus + dsrelationshipstatus
  for $j ("relationshipstatus", "dsrelationshipstatus") {
    while ($data{$j}=~s%<li>(.*?)</li>%%) {
      my($rel) = $1;
      # need underscore below to avoid overwriting variable we're reading from
      if ($rel=~s%^(.*?)\s*<a href="/users/(\d+)">.*?</a>%%m) {
	$data{"_$j"}{$1}{$2} = 1;
      } else {
	$data{"_$j"}{$rel}{0} = 1;
      }
    }
    # fix the hash (hopefully)
    $data{$j} = $data{"_$j"};
    delete $data{"_$j"};
  }

  # and islookingfor
  for $j (split("<br/>", $data{islookingfor})) {
    $data{"_islookingfor"}{$j} = 1;
  }
  # and fix
  $data{islookingfor} = $data{"_islookingfor"};
  delete $data{"_islookingfor"};

  return %data;
}
