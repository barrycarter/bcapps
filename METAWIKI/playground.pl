#!/bin/perl

# potentially better way of parsing stuff (ultimately for referata.com)

require "/usr/local/lib/bclib.pl";

dodie('chdir("/home/barrycarter/BCGIT/METAWIKI")');

# below forces creation/recency of pbs-triples.db
system("make");

# the forward and reverse mappings of k

# assuming friendship/cousin is symmetric, possibly not always true
# (for cousins, reverse could be "great uncle" or something weird?)

my(%map) = (
	    "character" => ["has_character", "appears_in"],
	    "storyline" => ["in_storyline", "has_strip"],
	    "deaths" => ["has_death", "dies_on"],
	    "newspaper_mentions" => ["mentions_paper", "mentioned_on"],
	    "aka" => ["alias", "canon"],
	    "profession" => ["has_profession", "has_member"],
	    "neighbor" => ["has_neighbor", "has_neighbor"],
	    "cousin" => ["has_cousin", "has_cousin"],
	    "friend" => ["has_friend", "has_friend"],
	    "species" => ["has_species", "has_member"],
	    "subspecies" => ["has_subspecies", "has_member"],
	    "location" => ["has_location", "has_resident"],
	    # <h>No to gay marriage: it screws up semantic transitivity!</h>
	    "husband" => ["has_husband", "has_wife"],
	    "wife" => ["has_wife", "has_husband"],
	    # no generic term for niece/nephew?
	    "uncle" => ["has_uncle", "uncle_of"],
	    "aunt" => ["has_aunt", "aunt_of"],
	    "date" => ["dates", "dates"],
	    "boss" => ["boss_of", "employee_of"],
	    "brother" => ["has_brother", "has_sibling"],
	    "sister" => ["has_sister", "has_sibling"],
	    "grandmother" => ["has_grandmother", "has_grandchild"],
	    "pet" => ["has_pet", "pet_of"],
	    "mother" => ["has_mother", "has_child"],
	    "father" => ["has_father", "has_child"],
	    "roommate" => ["has_roommate", "has_roommate"],
	    "kills" => ["kills", "killed_by"],
	    "member" => ["member_of", "has_member"],
	    "son" => ["has_son", "has_parent"]
);

# debug($map{character}[0]);

my(%hash);

for $i (sqlite3hashlist("SELECT * FROM triples", "/tmp/pbs-triples.db")) {
  my($source, $k, $v) = ($i->{source}, $i->{k}, $i->{v});

  # skipping source triples (for now)
  # also 
  if ($k eq "source") {next;}

  if ($map{$k}) {
    $hash{$source}{$map{$k}[0]}{$v} = 1;
    $hash{$v}{$map{$k}[1]}{$k} = 1;
    next;
  }

  warn("NOT UNDERSTOOD: $k: $source -> $v");
}

=item comment

k frequency:

3986|character
1907|storyline
765|source
278|notes
167|deaths
165|category
137|newspaper_mentions
122|meta
117|aka
97|cameo
95|profession
57|description
53|neighbor
53|species
33|location
31|cousin
20|crocodile_deaths
20|friend
19|zebra_deaths
18|event
15|subspecies
13|uncle
8|husband

=cut
