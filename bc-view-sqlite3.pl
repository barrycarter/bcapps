#!/bin/perl

# View an SQLite3 db using a web interface

# NOTE: I'm usually opposed to 'web programs', but I originally wrote
# this a long time ago, which makes it ok (well, not really)

require "/usr/local/lib/bclib.pl";

print "Content-type: text/html\n\n";

# db is fixed for now (TODO: allow choice)
$db = "/home/barrycarter/ofx.db";

# open(A,">/tmp/test.html");
print  "<table border>\n";
print  join("\n",show_table("ofxstatements"));
print  "</table>\n";
# close(A);

debug(show_table("ofxstatements"));

# shows the table, with options to select columns/sorting; if sort
# set, return sort table, otherwise return coltable

sub show_table {
  my($tabname, $sort) = @_;
  my($check);
  my(%cols) = sqlite3cols($tabname, $db);
  my(@cols) = keys %cols;

  # below lets user choose fewer than $#cols
  push(@cols, "-");

  # column headers (ignoring the '-' column I added above)
  for $i (0..$#cols) {
    # cheating by making i=0 a special case
    if ($i==0) {push(@ret, "<tr><th>*</th>"); next;}
    push(@ret,"<th>$i</th>");
  }
  # end table row for header row
  push(@ret, "</tr>");

  # show column name and position choice
  for $i (0..$#cols) {
    # row header
    push(@ret, "<tr><th>$cols[$i]</th>");

    # excluding last column (the fictional '-' I added above)
    for $j (0..$#cols-1) {

      # if column number matches position of field in @cols, check the
      # radio button (I dislike HTML forms with 'no-button-selected'
      # for radio fields)
      $check = $i==$j?"CHECKED":"";

      # the radio button is on a per-column basis; only one column can be
      # in the 5th position, for example
      # sortcol for sorting, just col for showing
      push(@ret, qq%<td><input type="radio" name="$cols[$j]" value="$j" $check></td>%);
    }
    # end row
    push(@ret,"</tr>");
  }

  return @ret;
}
