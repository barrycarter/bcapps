
=item voronoi_map(\@hashlist, $options)

Given @hashlist, a list of hashrefs, return a KML map (KMZ file)
representing the voronoi diagram. Each hash must have at least these
keys: id, x, y, label, color (KML-style); id must be unique

Primarily intended for latitude/longitude "google style" maps

The KMZ file should be copied, not used directly

$options currently unused

TODO: this seems to leave off one (or more?) points, not sure why

TODO: option for placemarks at the points themselves

=cut

sub voronoi_map {
  my($hashlistref, $options) = @_;
  my(@hashlist) = @{$hashlistref};
  my($tmpfile) = my_tmpfile("voronoi");
  local *A;
  open(A,">$tmpfile.kml");

  # header/footer
  my($header) = read_file("/usr/local/lib/kmlhead.txt");
  my($footer) = read_file("/usr/local/lib/kmlfoot.txt");
  print A "$header\n";

  # the Voronoi diagram
  my(@vor);
  for $i (@hashlist) {
    debug("I: $i");
    push(@vor, $$i{x}, $$i{y});
  }
  my(@tess) = voronoi(\@vor);

  debug("TESS",@tess,"ENDTESS");

  # the chunk for each polygon
  for $i (0..$#tess) {
    # not each point pair has a polygon
    unless ($tess[$i]) {next;}
    my(@points);
    # hash in @hashlist corresponding to this polygon
    my(%hash) = %{$hashlist[$i]};
    debug("I: $tess[$i], II: %hash");
    # polygon header
    my($body) = << "MARK";
<Placemark><styleUrl>#$hash{id}</styleUrl>
<description>$hash{label}</description>
<Polygon><outerBoundaryIs><LinearRing><coordinates>
MARK
;
    # style URL
    my($style) = << "MARK";
<Style id="$hash{id}">
<PolyStyle><color>$hash{color}</color>
<fill>1</fill><outline>0</outline></PolyStyle></Style>
MARK
;

    # the points for this polygon (pointless polygons OK w/ google)
    for $j (@{$tess[$i]}) {
    $j=~s/ /,/;
    push(@points, $j);
  }
    my($tail) = "</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>";

    print A "$body\n",join("\n",@points),"\n","\n$tail\n",$style,"\n";
  }

  print A $footer;
  close(A);
  system("zip $tmpfile.kmz $tmpfile.kml");
  return "$tmpfile.kmz";
}

1;
