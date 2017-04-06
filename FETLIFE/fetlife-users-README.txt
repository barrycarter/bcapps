<!-- NOTE: You can't actually download from this text file, but I'm
cheating and also using this as an index.html file elsewhere -->

<!-- TODO: make this document more "HTML friendly", ie not just pre tags -->

<center><font size=+2>In a hurry? <a href="fetlife-users-latest.zip">Download here (~300M)</a><p></font></center><p>

<pre>
This is the README file for fetlife-users-[yyyymmdd].csv (where
yyyymmdd represents the *approximate* date of the list), a
comma-separated-value list of FetLife users collected by parallel
deep-crawling https://fetlife.com/places and via other methods.

You can search a database version of the list at:

http://search.fetlife.94y.info/

NOTE: FetLife users are referred to as "kinksters".

Fields:

Field 1: id: The kinkster's id. The kinkster's profile page is
"https://fetlife.com/users/xxx" where "xxx" is the id. The id doesn't
change even if the kinkster changes their screenname.

Field 2: screenname: The kinkster's screenname.

Field 3: age: The kinkster's age. Some kinsters use high numbers here
(frequently 94) if they don't want to use their real age. Since
FetLife automatically increments ages yearly, an age of 95, 96, etc,
also probably indicates the kinkster doesn't wish to give their age.

Field 4: gender: The kinkster's gender. In addition to male (M) and female (F),
Fetlife defines these special genders:

CD/TV: Crossdresser/Transvestite
MtF: Transgender - Male to Female
FtM: Transgender - Female to Male
TG: Transgender
GF: Gender Fluid
GQ: Genderqueer
IS: Intersex
B: Butch
FEM: Femme

Kinksters may also to leave this field blank.

Field 5: role: The kinkster's role in the kink community. One of:

Ageplayer, Big, Bootblack, Bottom, Bull, Daddy, Doll, Dom, Domme,
Evolving, Exhibitionist, Exploring, Fetishist, Furry, Hedonist,
Kinkster, Leather Boi, Leather Daddy, Leather Man, Leather Top,
Leather Woman, Leather bottom, Leather boy, Leather girl, Masochist,
Master, Middle, Mistress, Mommy, Primal, Primal Predator, Primal Prey,
Princess, Rigger, Rope Bottom, Rope Bunny, Rope Top, Sadist,
Sadomasochist, Sensualist, Slut, Spankee, Spanker, Spanko, Swinger,
Switch, Top, Undecided, Vanilla, Voyeur, babyboy, babygirl, brat,
cuckold, cuckquean, kajira, kajirus, kitten, little, pet, pony, pup,
role, sissy, slave, sub

Fields 6-8: city, state, country: The kinkster's city, state, and country. Some
kinksters set their location to "Antarctica" if they don't want people
to know where they live.

Field 9: thumbnail: The URL to the kinkster's profile picture thumbnail. This
URL is not protected and can be viewed even if you're not logged into
FetLife. The thumbnail "avatar_missing_60x60.gif" indicates the kinkster
has no profile picture. Replacing the "_60.jpg" at the end of the URL
with "_200.jpg" yields a larger version of the profile picture.

Field 10: popnum: The rank of this kinkster in their administrative
area/country. I don't know FetLife's ranking method, but lower rank
numbers usually indicate more active kinksters.

Field 11: popnumtotal: The total number of kinksters in this kinkster's
administrative area/country. Combined with popnum, gives a rough idea
of how active the kinkster is. For example a popnum of 5364 and a
popnumtotal of 53289 means the kinkster was ranked 5364 of the 53289
kinksters in their administrative area.

Field 12: source: The source URL for the kinkster's data

Field 13: jloc: used only for technical purposes

Field 14: mtime: The Unix time at which this information was scraped.

NOTE: User orientation is NOT included in this database, since it does
NOT appear on the location pages. For reference, the possible
orientations are:

Straight
Heteroflexible
Bisexual
Homoflexible
Gay
Lesbian
Queer
Pansexual
Fluctuating/Evolving
Asexual
Unsure
Not Applicable

Kinksters may also choose to leave this field blank.

NOTE: The city, state, and country fields did not parse well and may
have errors. For the same reason (and others), the latitude and
longitude fields may also have errors.

NOTE: FetLife permits one person to have multiple profiles.

NOTE: This list is probably not complete, and may contain errors and
duplicates. I've made some effort to remove errors and duplicates, but
some may still exist.

SPECIAL THANKS TO: Mircea Popescu for creating the original FetLife
"meat list" at http://trilema.com/2015/the-fetlife-meatlist-volume-i/
and for publicly publishing a valid FetLife cookie, and to unixssh.com
for providing universal free shell access.

DISCLAIMER: Do not rely on this information. This information was
obtained legally, and falls under the Fair Use doctorine of copyright
law.

More specifically, FetLife search engines are explicitly legal beause
they meet the Fair Use criteria known as "transformative use":

http://en.wikipedia.org/wiki/Transformativeness

because they "provide the public with a benefit not previously
available to it, which would otherwise remain unavailable", and "in a
different manner or for a different purpose".

</pre>
