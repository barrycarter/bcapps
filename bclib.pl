# Barry Carter's Perl library (carter.barry@gmail.com)

# largest possible path

$ENV{PATH} = "/sw/bin/:/bin/:/usr/bin/:/usr/local/bin/:/usr/X11R6/bin/:$ENV{HOME}/bin:$ENV{HOME}/PERL";

=item list2hash(@list)

Converts @list to a hash where all elements of @list map to 1

=cut

sub list2hash {
  my(@list) = @_;
  my(%hash);
  for $i (@list) {$hash{$i} = 1;}
  return %hash;
}

1;
