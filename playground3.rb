#!/usr/local/bin/ruby

# inline debugging for all objects
class Object
  def td(s) puts("#{s}:#{self.inspect}"); self end
end

def sequence_search(str,key)
  j = 0
  (0..str.length-1).each{|i| if str[i]==key[j] then j+=1 end}
  return j == key.length
end

puts sequence_search("cta", "cat") # => false
puts sequence_search("caat", "caat") # => true
puts sequence_search("arcata", "cat") # => true
puts sequence_search("c1a2t3", "cat") # => true
puts sequence_search("cact", "cat")
puts sequence_search("ca", "cat")
puts sequence_search("cacccctccaca", "cat")
