#!/bin/perl

# parses data.* files in Wordnet(tm)
# for now, just counting how many "words" there are
# from http://wordnet.princeton.edu/man/wndb.5WN.html
#  synset_offset  lex_filenum  ss_type  w_cnt  word  lex_id  [word  lex_id...]  p_cnt  [ptr...]  [frames...]  |   gloss 


require "/usr/local/lib/bclib.pl";

for $i (glob "/mnt/sshfs/WORDNET/dict/data.*") {
  open(A,$i);
  while (<A>) {
    # split into "words" part, "weird junk" part, and "definition" part
    # word part ends with two numericals?
    unless (s/^\d+\s+\d\d\s+[nvasr]\s+[0-f][0-f]\s+(.*?)\s+\d\d\d.*?\|\s*(.*?)$//) {
      warn "NOT PARSED: $_";
      next;
    }

    my($words,$gloss) = ($1,$2);
    # nuke numbers + split
    $words=~s/\s+[0-f]\s*/ /isg;
    debug("WORDS: $words");
    @words = split(/\s+/,$words);
    debug("WORDS[a]",@words);

    print join("\n",@words),"\n";
#    debug("WORDS:",@words);
#    debug("GLOSS: $gloss");
  }
  print "\n";
}

print "\n";

