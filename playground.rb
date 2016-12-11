#!/usr/local/bin/ruby




def letter_count(str)
  lac = Hash.new(0)
  str.gsub(" ","").split("").each{|letter| lac[letter] += 1}
  lac
end

puts letter_count("cat")

exit

require 'ruby2js'
require '/home/barrycarter/BCGIT/bclib.rb'

puts Ruby2JS.convert(File.read("/home/barrycarter/BCGIT/bclib.rb"))


exit




# require 'ox'
# doc = Ox.load_file("/var/cache/OSM3/13-1671-3241.dat")
# print doc.osm.locate("node").length.inspect,"\n"
# print doc.osm.locate("relation").length.inspect,"\n"
# print doc.osm.locate("way").length.inspect,"\n"
# print doc.osm.nodes.length,"\n"
# print doc.osm.node(65).inspect

# print doc.inspect()




