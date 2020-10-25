#!/bin/perl

# Given a CSV file of Vanguard transactions, add them to my
# bankstatments db (which may be a bad idea actually)

require "/usr/local/lib/bclib.pl";

my($cont, $fname) = cmdfile();

my(@trans) = split(/\n/, $cont);

map($_ = [csv($_)], @trans);

debug($trans[0][1]);

# debug(var_dump(@trans));

my($transref, $null) = arraywheaders2hashlist(\@trans);

my(@hashlist);

for $i (@$transref) {

  # convert date to MySQL fmt

  unless ($i->{'Settlement date'}=~s/\//\-/g) {die "BAD DATE!";}

  # fixup amount

  # this is Vanguard's weird negative sign

  $i->{Amount}=~s/\xe2\x80\x93/-/;

  debug("BEFORE: $i->{Amount}");
  $i->{Amount}=~s/[^\d\.\-]//g;
  debug("AFTER: $i->{Amount}");

  # create a new hash to insert into bankstatements
  my(%row) = ();

  # fill in what we can

  $row{bank} = "VANGUARD";
  $row{amount} = $i->{Amount};
  $row{type} = $i->{'Transaction type'};
  $row{date} = $i->{'Settlement date'};

  # TODO: this looks ugly when there's no quant or price

  $row{description} = "$i->{Name} ($i->{Quantity}\@$i->{Price})";

  # remove unprintable characters

  $row{description}=~s/[^ -~]//g;

  push(@hashlist, \%row);

  # the real OFX/QFX files have unique_ids, but not the HTML file

#  debug("I: $i->{'Settlement date'}");

#  debug(var_dump(%{$i}));

}

my(@queries) = hashlist2sqlite(\@hashlist, "bankstatements");

# because these are sqlite querys INSERT OR IGNORE becomes INSERT IGNORE

map(s/INSERT OR IGNORE/INSERT IGNORE/, @queries);

print join(";\n", @queries);

=item comments

The headers for vanguard are:

"Settlement date","Trade date",Symbol,Name,"Transaction type",Quantity,Price,"Commissions and fees",Amount

columns for my bankstatements are (some of which aren't relevant here):

oid, bank, amount, type, date, unique_id, description, refnum,
comments, balance, category, taxcategory, taxpercentage, oldhash,
timestamp, recognized



=cut
