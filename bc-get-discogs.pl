#!/bin/perl

# Uses discogs.com API to download data for a given user:

# Pages like http://www.discogs.com/user/[username]/collection do not
# include info on a release's country, genre, style, parent label,
# etc; this program attempts to retrieve those and create a
# user-specific mysql-like file

require "/usr/local/lib/bclib.pl";
dodie("chdir('/usr/local/etc/discogs')");

# hash2rdf([0,1,2,3],"foo");
# debug(var_dump("triplets",\@triplets));
# die "TESTING";

(my($user)=@ARGV)||die("Usage: $0 username");
my($out,$err,$res);

# cache information as much as possible
# TODO: caching here is a bad idea if user adds releases (but OK for testing)
unless (-f "user-$user-p1" && !$globopts{nocache}) {
  ($out,$err,$res) = cache_command2("curl -o user-$user-p1 'http://api.discogs.com/users/$user/collection/folders/0/releases?page=1&per_page=100'");
}

# TODO: slightly inefficient to read (though not load) p1 twice
my($userinfo) = JSON::from_json(read_file("user-$user-p1"));

# get all pages
for $i (2..$userinfo->{pagination}{pages}) {
  unless (-f "user-$user-p$i" && !$globopts{nocache}) {
    ($out,$err,$res) = cache_command2("curl -o user-$user-p$i 'http://api.discogs.com/users/$user/collection/folders/0/releases?page=$i&per_page=100'");
    # avoid hitting API too hard
    sleep(1);
  }
}

# now, go through the pages (including page 1)
for $i (1..$userinfo->{pagination}{pages}) {
  my($json) = JSON::from_json(read_file("user-$user-p$i"));
  hash2rdf($json,$user);
}

# triplets printing (as test)

for $i (@triplets) {
  my(@l) = @{$i};
  print join("\t", @l),"\n";
}

=item hash2rdf($ref,$name)

Given a scalar/array/hash reference named $name, returns RDF triplets
recursively

Pretty much does what unfold() does, only in RDF

=cut

sub hash2rdf {
  my($ref,$name) = @_;
  debug("hash2rdf($ref,$name), ");
  my($type) = ref($ref);
  # name that each reference will give itself
  my($mi);
  debug("TYPE($ref): $type");
  # TODO: making $hash2rdf_count global is bad
  # things to return
  # TODO: making @triplets global is unacceptably bad (but just testing now)
  # may do pass-by-var for both?
  # my(@triplets);

  # if no type at all, just return self
  unless ($type) {return $ref;}

  if ($type eq "ARRAY") {
    debug("ARRAY: $ref");
    # give myself a name
    $mi = "REF".++$hash2rdf_count;
    # interim var
    my(@l) = @{$ref};
    # push triplets for my children
    for $i (0..$#l) {
      debug("ELT: ",$l[$i]);
      push(@triplets, [$mi, $i, hash2rdf($l[$i])]);
    }
    # return the name I gave myself
    return $mi;
  }

  if ($type eq "HASH") {
    debug("HASH: $ref");
    # give myself a name
    $mi = "REF".++$hash2rdf_count;
    # interim var
    my(%h) = %$ref;
    for $i (keys %h) {
      push(@triplets, [$mi, $i, hash2rdf($h{$i})]);
    }
    return $mi;
  }
}

=item schema

; where dump.txt is output of this program
DROP TABLE IF EXISTS rdf;
CREATE TABLE rdf (hash, key, val);
CREATE INDEX i1 ON rdf(hash);
CREATE INDEX i2 ON rdf(key);
CREATE INDEX i3 ON rdf(val);
.separator "\t"
.import dump.txt rdf

; useful queries
SELECT r1.key, r2.key, r3.key, r4.key, r5.key, r6.key, r6.val FROM rdf r1 
JOIN rdf r2 ON (r1.val = r2.hash)
JOIN rdf r3 ON (r2.val = r3.hash)
JOIN rdf r4 ON (r3.val = r4.hash)
JOIN rdf r5 ON (r4.val = r5.hash)
JOIN rdf r6 ON (r5.val = r6.hash)
WHERE r1.hash='REF1' AND r1.key='releases' ORDER BY r2.key+0
;


=cut
