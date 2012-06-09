#!/bin/perl

# View an SQLite3 db using a web interface

# TODO: allow multi-edit

# NOTE: I'm usually opposed to 'web programs', but I originally wrote
# this a long time ago, which makes it ok (well, not really)

# NOTE: this used to be a PHP script, as is perhaps obvious in some places

require "/usr/local/lib/bclib.pl";

# text/plain just for debugging
print "Content-type: text/plain\n\n";

# obtain and dehtmlify the STDIN
$stdin = <STDIN>;
$stdin=~s/%(..)/chr(hex($1))/iseg;

print "STDIN IS: $stdin\n";

# split and parse
for $i (split(/\&/, $stdin)) {
  # cols
  if ($i=~m/^col\[(\d+)\]\=([a-z0-9]+)$/) {
    $cols[$1] = $2;
  } elsif ($i=~m/sortcol\[(\d+)\]\=([a-z0-9]+)$/i) {
    $sortcols[$1] = $2;
  } else {
    print "Ignoring $i\n";
  }
}

$cols = join(", ", @cols);
$sortcols = join(", ", @sortcols);


print "SORT",@sortcols;
print "COLS",@cols;

# db is fixed for now (TODO: allow choice)
$db = "/home/barrycarter/ofx.db";

print "<form method='POST'>\n";
print "<table border><tr><th>Show Columns</th><th>Sort Columns</th></tr>\n";

print  "<tr><td><table border>\n";
print  join("\n",show_table("ofxstatements"));
print  "</table></td>\n";

print  "<td><table border>\n";
print  join("\n",show_table("ofxstatements",1));
print  "</table></td></tr>\n";

print "<tr><th colspan=2><input type='submit'></th></tr>";
print "</table>\n";



# close(A);

debug(show_table("ofxstatements"));

# shows the table, with options to select columns/sorting; if $sort
# set, return sort table, otherwise return coltable

sub show_table {
  my($tabname, $sort) = @_;
  my($check);
  my(%cols) = sqlite3cols($tabname, $db);
  my(@cols) = keys %cols;
  my(@ret);

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
      if ($sort) {$sort="sort";}
      debug("SORT: $sort");
      push(@ret, qq%<td><input type="radio" name="${sort}col[$j]" value="$cols[$i]" $check></td>%);
    }
    # end row
    push(@ret,"</tr>");
  }

  return @ret;
}
