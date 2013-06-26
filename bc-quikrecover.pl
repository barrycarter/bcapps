#!/bin/perl

# regenerates, in the current working directory all previous versions of a
# single file saved by bc-quikbak.pl [must use xargs for multiple
# files]
# --fake: only print patch commands, don't run them
# --notime: don't set the timestamp for older files
# Usage: $0 /usr/local/etc/quikbak/dirpath/filename

require "/usr/local/lib/bclib.pl";

# quikbak dir must have current copy of file and file.quikbak
$file= $ARGV[0];
unless (-f $file) {die("$file does not exist");}
open(A,"$file.quikbak") || die("Can't open $file.quikbak, $!");

# first line must be "! date (ORIGINAL)"
if (<A> =~ /^\!\s*(.*?)$/) {
  @patches = ($1);
} else {
  die("diff file: bad first line");
}

# just the filename w/ no dirpath
$filename = $file;
$filename=~s!^.*/!!;

while (<A>) {
  # start of new backup? if so, create new patch file
  if (/^!\s*(.*?)$/) {
    close(B);
    open(B,">quikrecover-$1.patch");
    unshift(@patches, $1);
    next;
  }
  if (/^$/) {next;} # ignore empty lines
  # all other cases: print to existing patch file
  print B $_;
}

close(B);
close(A);

# copy the current version of the file locally (we'll apply patches to
# it so it will end up being the oldest/original version)
system("/bin/cp","-f",$file,"quikrecover-$filename-$patches[0]");

# write commands to apply each path 
open(C,"quikrecover-patch.sh");
for $i (0..($#patches-1)) {
  @command = ("patch","-o","quikrecover-$filename-$patches[$i+1]", 
	      "quikrecover-$filename-$patches[$i]", 
	      "quikrecover-$patches[$i].patch");

  # set timestamp (unless --notime or --fake)
  # couldn't get utime to work, had to use touch
  unless ($globopts{notime}||$globopts{fake}) {
    # convert "stardate" into format that 'touch' understands
    # TODO: this is ugly + could be much improved
    $then = scalar gmtime(datestar($patches[$i]));
    system("touch -d '$then' quikrecover-$filename-$patches[$i]");
  }

  # print or run commands, depending on --fake
  if ($globopts{fake}) {
    print join(" ",@command),"\n";
  } else {
    debug("RUNNING:",@command);
    system(@command);
  }
}
