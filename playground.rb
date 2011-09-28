#!/usr/local/bin/ruby

$LOAD_PATH << "/usr/lib/ruby/gems/1.8/gems/jnunemaker-crack-0.1.4/lib"
require 'crack'
xml = File.read("/tmp/output2.xml")
foo = Crack::XML.parse(xml)
print foo["data"]["reports"].inspect()



