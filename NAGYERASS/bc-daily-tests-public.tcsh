# tcsh does NOT understand XML, but this file, despite its extension,
# is ready by bc_extras() subroutine in Perl, which does understand
# these fake XMLy comments

<header>

A list of tests I am making public on the off chance they might help
someone

</header>

<password>

My pw.txt holds my passwords and the first field represents where the
password is used (except for empty lines, comments, lines starting
with the marker "OBSOLETE"). It must be one of the following:

  - A domain name ending in an approved prefix (but possibly followed by other nonalphabetic characters, such https://example.com/path)

  - The psuedo domain name .lan for local machines

  - an IP address potentially followed by colon and a port number (for
  MUSHes and MOOs and MUDs and MUCKs and such-- I have passwords
  dating back to the early 90s though I'm not sure how many of them
  still work)

  - a string that starts with a quotation mark or bracket, meaning the password usage location is described in text and not a website

The last part of the pipe confirms there are no results (ie, no non-compliant strings)

</password>

egrep -v '^$|^#|^OBSOLETE:' ~/pw.txt | perl -anle 'unless ($F[0]=~m/\.(com|net|gov|org|tv|io|edu|us|it|de|hu|uk|biz|fm|to|se|ch|im|ca|co|info|lan|club|space)(\W|$)/ || $F[0]=~m/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d{1,5})?/ || $F[0]=~/\"|\[/) {print $_}' | perl -nle 'if (length($_)>=0) {print "STDIN NOT EMPTY"; exit 2;} else {exit 0;}' 

<tcsh>

None of my .tcsh scripts should have "then:" which means "then run the
null command", because I mean simply "then" in these cases; in theory, could create a test like this for .sh files, but some of the ones other people create DO have "then:" correctly AND many of my .sh files are really tcsh files (which is bad for another reason)

The perl -f is necessary because I don't want complaints when files don't exist (and I pipe the stderr to the stdout with |& to catch other errors).

Of course, this script itself (which isn't a tcsh file but ends in .tcsh) is an exception

</tcsh>

bc-rev-search.pl .tcsh | perl -nle 'if (-f $_) {print $_}' | fgrep -v bc-daily-tests-public.tcsh | xargs grep then: |& perl -nle 'if (length($_)>=0) {print "STDIN NOT EMPTY: $_"; exit 2;} else {exit 0;}'

<tello>

I force myself to annotate any bills (not credits) from tello, my cell
phone service provider, but allow myself a one month grace period to
do so

</tello>

check_mysql_query -d test -c 0:0 -q "SELECT COUNT(*) FROM bc_budget_view WHERE description RLIKE 'tello' AND date <= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND LENGTH(IFNULL(comments,'')) < 300 AND amount < 0"

<gmailspace>

TODO: this test may not be working properly

I have a section in THE_FILE that tells me how much space each of my
google accounts is using (noted down manually); this insanely
pointless test confirms these lines all have the same format:

yyyymmdd.hhmmss account_name_possibly_with_@_sign "using" (numerical) GB of 15 GB

and then prints out the "account_name_possibly_with_@_sign" field and compares it to a list of known good gmail accounts from pw.txt

</gmailspace>

egrep '^gmail.com ' ~/pw.txt | perl -anle 'print $F[1]' >! /tmp/allgoogle.txt; bc-section-checklist.pl --stdout --section=gmailspace ~/THE_FILE | egrep -v '^$' | perl -anle 'unless (/^20[0-2][0-9][0-1][0-9][0-3][0-9]\.[0-2][0-9][0-5][0-9][0-5][0-9] ([0-9a-z\.\@]+) using [0-9\.]+ GB of 15 GB\s*$/) {warn "BAD LINE: $_"} else {print "$1"}' |& fgrep -xvf /tmp/allgoogle.txt |& perl -0777 -nle 'unless (/^\s*$/) {print "STDIN NOT EMPTY: $_"; exit 2;} else {exit 0;}'

<pwrepeats>

This will test if I have repeated passwords in pw.txt but isn't working at the moment:

egrep -v '^#|^$|^OBSOLETE: ' ~/pw.txt | perl -anle 'print $F[2]' | sort | uniq -d | fgrep -f - ~/pw.txt | egrep -v '^#|^$|^OBSOLETE' | less

egrep -v '^#|^$|^OBSOLETE: |^\"' ~/pw.txt | perl -anle 'print $F[2]' | sort | uniq -d | egrep -v '^\[|barry' | fgrep -v '[secure' | tee /tmp/output.txt | fgrep -f - ~/pw.txt | egrep -v '^#|^$|^OBSOLETE' | less

TODO: do check lines that start with quotation marks, mark and exclude accounts that no longer appear to work

</pwrepeats>

<checkimages>

When I add a check to bankstatements (which shows in bc_budget_view),
I include an indication of where in /home/user/SCANS/CHECKS/ the check
image appears, sometimes as a wildcard. However, I sometimes move
images around, breaking the reference; the below confirms all the
check images referenced are still there; the "NO SUCH FILE" catches
cases where the check image *isn't* a wildcard; added colon on
12/27/21 because there is an entry that has "image" in comments for an
unrelated reason

</checkimages>

mysql --column-names=FALSE -B test -e "SELECT comments FROM bc_budget_view WHERE comments RLIKE 'image:' \G" | grep image | perl -nle 's/\s+$//; unless (/^Image: (.*)$/) {die("BAD IMAGE: $_")}; @glob = glob("/home/user/SCANS/CHECKS/$1"); if ($#glob < 0) {die "BAD GLOB: $1";} for $i (@glob) {unless (-f $i) {die "NO SUCH FILE: $i"}}'



