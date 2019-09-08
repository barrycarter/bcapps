#!/bin/perl

# parses OSM data to place into a NON-GIS mysql db just to see if I
# can get a smaller import that's useful to me, instead of the larger
# pgsql import, which is more general

# TODO: multiply lat/lon by 2**32 for consistency
# TODO: toss useless tags
# TODO: treat node w/ no useful tags as empty nodes (implicit?)

require "/usr/local/lib/bclib.pl";

# convert nodes to lat/lon
my(%nodes);

# hash to tempory hold values
my(%temphash);

# keep track of current node or way + which node in way

my($curitem, $nodecounter);

while (<>) {

  # ignore empty lines

  if (s%^\s*$%%) {next;}

  # for self-closing nodes, just record lat/lon

  if (s%<node(.*?)/>%$1%) {

    %temphash = ();

    while (s/(\w+)\=\"(.*?)\"//) {$temphash{$1} = $2;}

    # TODO: storing node lng/lat in memory won't work for larger files
    $nodes{$temphash{id}} = "$temphash{lon} $temphash{lat}";

    next;

  }

  # node that does not self close

  if (s%<node(.*?)>%$1%) {

    # TODO: remove redundant code

    # also extract lng/lat

    %temphash = ();

    while (s/(\w+)\=\"(.*?)\"//) {$temphash{$1} = $2;}

    # TODO: storing node lng/lat in memory won't work for larger files
    $nodes{$temphash{id}} = "$temphash{lon} $temphash{lat}";

    # and set cur node (we do not use node ids)
    $curitem = "node $temphash{lon} $temphash{lat}";

  }

  # if end of node or way, unset cur item
  # TODO: confirm that null 0 never appears in output

  if (s%\s*</(node|way)>\s*%%) {$curitem = "null 0"; next;}

  # handle tag by printing it out for db import
  # TODO: print to filehandle not stdout

  if (s%<tag k="(.*?)" v="(.*?)"\s*/>%%) {print "$curitem $1 $2\n"; next;}

  # if this is a way tag, set the current way and set node counter to 0

  if (s%<way(.*?)>%$1%) {


    # <h>todo: remove redundant comment about redundant code</h>
    # TODO: remove redundant code

    %temphash = ();
    while (s/(\w+)\=\"(.*?)\"//) {$temphash{$1} = $2;}

    $curitem = "way $temphash{id}";
    $nodecounter = 0;

    next;

  }

  # if nd ref, add node's lat lon to way by printing (we will not
  # store node ids in general

  if (s%<nd ref="(\d+)"/>%%) {

    my($node) = $1;

    print "way $nodes{$node} $node\n";

    $nodecounter++;

    next;

  }

  # don't debug lines that are now empty
  unless (m%^\s*$%) {debug($_);}

}
