#!/usr/local/bin/ruby

require 'prime'

def next_prime(num)
  num = num+1 until Prime.prime?(num+1)
  num+1
end

puts next_prime(5)

exit
