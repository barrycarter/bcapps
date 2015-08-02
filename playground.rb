#!/usr/local/bin/ruby

require 'ox'
doc = Ox.load_file("/var/cache/OSM3/13-1671-3241.dat")
print doc.osm.locate("node").length.inspect,"\n"
print doc.osm.locate("relation").length.inspect,"\n"
print doc.osm.locate("way").length.inspect,"\n"
print doc.osm.nodes.length,"\n"
# print doc.osm.node(65).inspect

# print doc.inspect()




