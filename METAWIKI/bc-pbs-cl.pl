#!/bin/perl

# I am using feh's caption feature to rapidly list characters
# appearing in each Pearls Before Swine strip; this script parses
# those caption files and outputs semantic triples to pbs-cl.txt

require "/usr/local/lib/bclib.pl";

# the conversions (capital letters = mention, but no appearance)
%full = ("p" => "[[character::Pig]]",
	 "r" => "[[character::Rat]]",
	 "g" => "[[character::Goat]]",
	 "z" => "[[character::Zebra]]",
	 "P" => "[[character::Pig]]",
	 "pastis" => "[[character::Stephan Pastis]]",
	 "max" => "[[character::Max (lion)]]",
	 "patty" => "[[character::Patty (crocodile)]]",
	 "zach" => "[[character::Zach (lion)]]",
	 "kiki" => "[[character::Kiki (lion)]]",
	 "gigi" => "[[character::Gigi (lion)]]",
	 "tooty" => "[[character::Tooty (gingerbread man)]]",
	 "zze" => "[[character::ZZE]]",
	 "xmas tree girl" => "[[character::Christmas Tree Girl (rat)]]",
	 "bootyworth" => "[[character::Ms. Bootyworth (bottle)]]",
	 "lincoln" => "{{wp|[[character::Abraham Lincoln]]}}",
	 "gomer" => "[[character::Gomer (goldfish)]]",
	 "jeffy" => "[[cameo::Jeffy (Family Circus)]]",
	 "cubby" => "[[character::Cubby (fly)]]",
	 "toby" => "[[character::Toby (turtle)]]",
	 "baby johnson" => "[[character::Baby Johnson (human)]]",
	 "weebear" => "[[character::Wee Bear (bear)]]",
	 "rita rabbit" => "[[character::Rita (rabbit)]]",
	 "tina" => "[[character::Tina (turtle)]]",
	 "timmy" => "[[character::Timmy (turtle)]]",
	 "lucky" => "[[character::Lucky (lion)]]",
	 "garfield" => "[[cameo::Garfield (Garfield)]]",
	 "cathy" => "[[cameo::Cathy (Cathy)]]",
	 "hagar" => "[[cameo::Hagar (Hagar the Horrible)]]",
	 );

# "done" is special case for slash mode meaning "list of chars is
# complete", currently unused
$full{done} = "[[char_list_complete::1]]";

# similar for unnamed/anon
$full{anon} = "[[has_anon_characters::1]]";
$full{unnamed} = "[[has_anon_characters::1]]";
$full{other} = "[[has_additional_characters::1]]";

# the following need to be recognized as full
for $i ("zebra", "pig", "rat", "goat", "larry", "guard duck", "junior",
       "snuffles", "pigita", "abraham lincoln") {
  $uc = $i;
  $uc =~ s/(\w+)/\u$1/g;
  $full{$i} = "[[character::$uc]]";
}

open(A,">/home/barrycarter/BCGIT/METAWIKI/pbs-cl.txt");

# where these special captions are (not in the main PBS directory!)
for $i (glob "/mnt/extdrive/GOCOMICS/pearlsbeforeswine/CHARLIST/*.txt") {
  $all = read_file($i);
  $all = trim($all);

  # text in stars *like this* are my notes to myself
  $all=~s/\*(.*?)\*//g;

  # if entire file is a single character, hack
  if ($full{$all}) {$all="$all/";}

  debug("ALL: $all");

  # if I use "/" anywhere in line, I'm using that as separator
  # characters appearing in this strip
  if ($all=~/\//) {
    @data = split(/\//, $all);
    $slashmode = 1;
  } else {
    @data = split(//,$all);
    $slashmode = 0;
  }

  # convert to full form
  for $j (@data) {
    if ($full{$j}) {
      $j = $full{$j};
    } else {
      # guess at full form
      $nofullform{lc($j)} = 1;
      $j =~ s/(\w+)/\u$1/g;
      $j = "[[character::$j]]";
    }
  }

  # date of this strip
  $i=~/(\d{4}-\d{2}-\d{2})/ || warn("BAD FILE: $i");
  $date = $1;

  # and print
  print A join(" ",$date,@data),"\n";
}

close(A);

if (%nofullform) {
  warn("NOFULLFORM:\n", join("\n", sort keys %nofullform));
}

=item comment

No full forms:

alien
alphonse
angry bob
ataturk
b
baby johnson
bait club
barbara bush
bennie
bert
biff
billy
bippy
blackbeard
bootyworth
bucky
burt
calvin
cartooncritic2544
cathy
catsup
chuckie
cindy
comic police*2
comic strip censor
connie
cookie monster
crocodiles
cubby
danny donket
danny donkey
death
deaths
dickie
dinky
dolly
dolphins
drama cow
e
eddie
elly
elly elephant
ernie
estate agent
fantastic four
fat fred
feral
feral ballerina
freddy
fredo
fredo's wife
frieda
fruit buddies
gandhi
garfield
gloria steinem
gomer
gophers
grover
gus
gw
hagar
hamsters
heebie
helga
henry hippo
hippo
hobbes
holly
hops
hosanna
hyenas
jef
jeffy
jennifer
jenny
jimmy
john
johnson
jojo
joy
katharine hepburn
kiko
larrylion
lemmings
leonard
libby
lincoln
linus
lucky
man on the moon
marshmallows
maura
meerkats
melvin
moe
monopoly tokens
mr pitters
neighbor bob
neighbor fred
newt
newt gingrich
olive
oscar
pepe
petey
phil
pig's brain
pig's dad
pig's mom
pippy
pit
plaid
potus
rita rabbit
roadrunners
roland
safari bob
satan
satchel
signs
skippy
snuffes
stacy
stevie stenographer
sumo squirrels
timmy
tina
toby
toody
tooty
trixie
unnamed human
viking figures
viking fitures
vinnie
wee bear
weebar
weebear
whale
wii
wilhelm
willie mays
xmas tree girl
zze

=cut
