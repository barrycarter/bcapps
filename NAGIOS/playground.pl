#!/bin/perl

require "/usr/local/lib/bclib.pl";

bc_check_file_of_files_age("$bclib{githome}/NAGIOS/recentfiles.txt");

=item bc_check_file_of_files_age($file)

Given a file formatted like recentfiles.txt, check that all files are
sufficiently recent

=cut

sub bc_check_file_of_files_age {
  my($file) = @_;

  my(@tests) = `egrep -v '^#|^\$' $file`;

  for $i (@tests) {
    chomp($i);

    # file glob MUST be quoted
    unless ($i=~s/\"(.*?)\"//) {
      print "$file contains unquoted line: $i\n";
      return 2;
    }

    my($w,$c) = split(/\s+/,$i);
    my($files) = $1;

    my($out,$err,$res) = cache_command("ls -1tr $files | head -1 | xargs stat -c '%Y'");

    if ($res) {
      print "Filespec $i returned error: $err\n";
      return 2;
    }

    my($fileage) = time()-$out;
    if ($fileage > $c) {
      print "Filespec $i critical: $fileage\n";
      return 2;
    }

    if ($fileage > $w) {
      print "Filespec $i warning: $fileage\n";
      return 1;
    }
  }

  # if ALL tests pass...
  return 0;

}



