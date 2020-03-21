#!/bin/perl

# I often end up doing one thing and then subtasking into another
# thing. The ~/DOING file will tell me what I am doing at a given
# time, with timestamps. I can manually edit it when items are
# completed or I abandon them

# Usage: doing <thing>
# Add <thing> to ~/DOING with timestamp;
# If <thing> is blank, show undone items in reverse order

require "/usr/local/lib/bclib.pl";

$file = "$bclib{home}/DOING";

my(%ignore) = list2hash("DONE", "NOT", "OK", "FIXED", "NOTED",
"ASKED", "DEFER");


# TODO: this is incorrect-- must check 2nd field only for words below

# "DONE:" indicates item is done and not to be shown, NOT: = abandoned

unless (@ARGV) {

  # read the file backwards, ignore cases where second word is ignorable
  open(A, "tac $file|");

  while (<A>) {

    my(@words) = split(/\s+/, $_);

    # if second word has trailing colon, remove it and ...

    if ($words[1]=~s/:$//) {

      # ignore it or...
      if ($ignore{$words[1]}) {next;}

      warn("SECOND WORD CONTAINS BAD COLON: $_");
      next;
    }

    print $_;
  }

  exit(0);
}

# system("tac $file | egrep -v 'DONE:|NOT:|OK:|FIXED:|NOTED:|ASKED:|DEFER:' | less"); exit(0);}

# <h>time and item are anagrams</h>
my($item) = join(" ",@ARGV);
my($time) = strftime("%Y%m%d.%H%M%S", localtime());
append_file("$time $item\n", $file);
