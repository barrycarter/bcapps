#!/usr/local/bin/ruby

require 'rexml/document'
doc = REXML::Document.new(File.new("/tmp/test1.xml"))
print doc.inspect()




