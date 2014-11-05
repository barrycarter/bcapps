#!/usr/local/bin/ruby

require "/home/barrycarter/BCGIT/bclib.rb"
require 'matrix'

$DEBUG = 1;

v = Vector.elements([54225,49593,51402])

w = v.to_polar()
u = w.to_rect()

td("#{v}\n#{w}\n#{u}\n")

exit

$a = Hash.new
# $a[1] = 7
$a[1][2] = 3

exit

a = [1,2,3,4,5,6,7,8,9,10,11,12].each_slice(4).to_a
a = a.map{|i| i.each_slice(2).to_a}
print a.inspect,"\n"
