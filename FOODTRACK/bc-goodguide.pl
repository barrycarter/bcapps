#!/bin/perl

# Attempts to pull nutrition data from goodguide.com which appears to
# be a reliable source

require "/usr/local/lib/bclib.pl";

# translates goodguide.com terms to my db terms
%ggtranslates = ("carbohydrate" => "totalcarbohydrate", "fat" => "totalfat");
%hash = get_goodguide("078742323831");
# %hash = get_goodguide("078742120638");

print hashlist2sqlite([{%hash}], "foods");
print ";\n";

=item get_goodguide($upc)

Given a UPC code, find information on code from goodguide.com

Returns a hash of values.

Replicates d4me2db() but for goodguide.com

=cut

sub get_goodguide {
  my($upc) = @_;
  my(%rethash);

  my($out,$err,$res) = cache_command("curl 'http://www.goodguide.com/products?filter=$upc'", "age=3600");

  # find product href
  unless ($out=~m%href='(/products.*?)'%) {
    warn "product not found: $upc";
    return;
  }

  # load product data
  my($url) = $1;
  my($out,$err,$res) = cache_command("curl 'http://www.goodguide.com/$url'", "age=3600");

  # parse product data
  while ($out=~s%<span class="label">(.*?)</span>\s*<span class="data">(.*?)</span>%%s) {
    my($key,$val) = ($1,$2);
    # lower case, no spaces
    $key=~s/\s//isg;
    $key = lc($key);
    if ($ggtranslates{$key}) {$key = $ggtranslates{$key};}
    $rethash{$key} = $val;
  }

  # company
  $out=~m%Company:\s*<span.*?>(.*?)</span>%s;
  my($co) = $1;
  $co=~s/<.*?>//isg;
  $rethash{Manufacturer} = $co;

  # name
  $out=~m%<title>(.*?)</title>%;
  my($item) = $1;
  $item=~s/\s*reviews\s+\&amp\;\s+ratings\s*\|\s*goodguide$//is;
  $rethash{Name} = $item;

  # serving size
  $out=~m%Serving Size\s+(.*?)\n%is;
  my($ssize) = $1;
  $rethash{'serving size'} = $ssize;

  # page does not provide UPC, which is annoying
  $rethash{UPC} = $upc;

  # values we cant use
  for $i ("caloriesfromfat", "folicacid") {
    delete $rethash{$i};
  }

  debug("OUT: $out");

  return %rethash;
}

