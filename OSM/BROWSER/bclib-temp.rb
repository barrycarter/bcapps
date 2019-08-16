include Math

$\="\n"

# this constant converts degrees to radians; for example 10*DEGREE is
# the radian equivalent of 10 degrees

DEGREE = PI/180

# the debug function prints a string to stderr if $DEBUG is set

# debugging is turned on by default for now

$DEBUG = 1

def debug (s) if $DEBUG then $stderr.print(s) end end

# trig functions on degrees for convenience

# TODO: move away from using these and use DEGREE dierctly instead

def sind(x) sin(x*DEGREE) end
def cosd(x) cos(x*DEGREE) end
def tand(x) tan(x*DEGREE) end

# bunch of utility methods that many objects will want

module Util

  # given a string like 'x=1&y=2&z=3', set x=1, y=2, z=3 in this object

  # if string has something like 'x=1,2,3' set x to be the array [1,2,3]

  def setfields (s)
    s=s.to_sf if s.is_a?(Hash)
    s.split("&").collect{|i| i.split("=")}.each{|i,j| send(i+"=",j.split(","))}
  end

  # this can't be an alias to setfields, because initalize w/ no args
  # needs to still work

  def initialize (*arr) arr.each{|i| setfields(i)} end

  # setting non-existant vars is ok, otherwise assume reading variable

  def method_missing (name, *args)

    # TODO: kludge! why do I have to do this?
    args.flatten! 

    # TODO: probably a better way to do below (not working 100% either)
    
    if (name.to_s =~ /^([a-zA-Z_][a-zA-Z_0-9]*)\=$/)
      instance_eval("@#{$1}=args[0]")
    else
      instance_eval("@#{name}")
    end
  
  end

  # defaults does the same thing as setfields, usually used to set defaults

  alias defaults setfields

end

# adding a transparent transdebug(tag) function to object; this debugs
# an object and then returns it, so processing can continue uninteruppted

class Object
  def transdebug(s) debug(s+": "+self); self end
  alias td transdebug
end

# See "Overriding and overloading Ruby functions is bad" in TODO file
# for why the next few dozen lines are bad

class Array

  # to_s should return what inspect does

  alias to_s inspect

  # alias because I'm going to overwrite it

  alias choose []

  # strings converted to ints

  def [] (i) i.is_a?(String)?choose(i.to_i):choose(i) end

end

# improving Hash's to_s function, and creating function so I can pass
# hashes to setfields

class Hash

  alias init initialize

  def to_s() collect{|i,j| i.to_s+" => "+j.to_s}.join("\n") end

  def to_sf() collect{|i,j| i.to_s+"="+j.to_s}.join("&") end

  # allow strings to set key/value pairs, and return (a little ugly) self

  def setfields(s) 
    s.split("&").collect{|k| k.split("=")}.each{|i,j| self[i]=j}; self
  end

end

# Lines below convert strings to numbers: "42" + "57" = "99" in my
# book, not "4257"

# TODO: it would be nice to do this using the module below, but
# neither "extend" nor "include" will override existing methods

# module StringMath
#   def - (s) to_f-s.to_f end
# end

# TODO: it's ugly to override + - etc for Numeric's subclasses,
# but since Numeric's subclasses override + - themselves, it IS
# necessary

# TODO: even class by class, there has to be a better way to do
# this, perhaps using Numeric.coerce?

# I've decided that dividing by 0 gives nil

# I hate non-explicit integer division/multiplication and have overridden it

class Fixnum

  # alias existing operators (and mod, dont want to override % in String)

  alias minus -
  alias plus +
  alias div /
  alias mod %
  alias mult *
  alias gt >
  alias pow **  

  # and re-define (/ lives on as div)

  def - (s) minus(s.to_f) end
  def + (s) plus(s.to_f) end
  def / (s) (s.to_f==0)?nil:div(s.to_f) end
  def * (s) mult(s.to_f) end
  def > (s) gt(s.to_f) end
  def ** (s) pow(s.to_f) end

end

class Bignum

  # alias existing operators

  alias minus -
  alias plus +
  alias div /
  alias mod %
  alias mult *

  # and re-define (/ lives on as div)

  def - (s) minus(s.to_f) end
  def + (s) plus(s.to_f) end
  def / (s) (s.to_f==0)?nil:div(s.to_f) end
  def * (s) mult(s.to_f) end
  
end

class Float

  # alias existing operators

  alias minus -
  alias plus +
  alias div /
  alias mod %
  alias mult *
  alias xto_s to_s
  alias gt >  

  # and re-define

  def - (s) minus(s.to_f) end
  def + (s) plus(s.to_f) end
  def / (s) (s.to_f==0)?nil:div(s.to_f) end
  def * (s) mult(s.to_f) end
  def > (s) gt(s.to_f) end
  
  # these are really just to make ruby-mysql (not mysql-ruby) happy
  # todo: setup method_missing to handle these automatically

  def & (x) to_i.&(x) end
  def >> (x) to_i.>>(x) end
  def | (x) to_i.|(x) end
  

  # kill off trailing 0's, they annoy me

  def to_s() xto_s.gsub(/\.0+$/,'') end

end

# modifying String to handle cases like "7"-4; this CHANGES THE
# RESULT of "7.2"+"2.3" to be 9.5 NOT "7.22.3"

class String

  # String has + * defined, not - /

  alias plus +
  alias mult *
  alias eqeq ==
  alias lt <
  alias gt >

  # am I numeric?

  def numeric? () self=~/^[\+\-]?\d*\.?\d*$/ && self=~/\d/ end

  # re-define + * and newly define - /

  # for the below, invoke floating point functions only if string is numeric

  def + (x)
    (numeric?&&(x.is_a?(Numeric)||x.to_s.numeric?))? to_f+x.to_f : plus(x.to_s)
  end

  # re-define == (yes "1" == 1 as far as I am concerned)

  def == (x)
    (numeric?&&(x.is_a?(Numeric)||x.to_s.numeric?))? to_f==x.to_f: eqeq(x.to_s)
  end

  # redefine < and >

  def < (x)
    (numeric?&&(x.is_a?(Numeric)||x.to_s.numeric?))? to_f<x.to_f: lt(x.to_s)
  end

  def > (x)
    (numeric?&&(x.is_a?(Numeric)||x.to_s.numeric?))? to_f>x.to_f: gt(x.to_s)
  end

  # and related functions

  def <= (x) self<x||self==x end
  def >= (x) self>x||self==x end
  def <=> (x) (self==x)?0:((self<x)?-1:1) end

  # unless I'm non-numeric and x is integer, use floating mult

  def * (x) (!numeric?&&x.is_a?(Integer))?mult(x):to_f*x.to_f end

  def - (x) to_f-x.to_f end
  def / (x) to_f/x.to_f end
  def ** (x) to_f**x.to_f end

  # div and mod do true integer div mod

  def div (x) to_i.div(x.to_i) end
  def mod (x) to_i%x.to_i end

  def floor () to_f.floor end

end

# modifying NilClass to be more useful

class NilClass

  # splitting yields empty array, each yields empty enumeration, etc

  def split (x) Array.new() end
  def each() Array.new().each end
  def match(x) false end
  def select(x) Array.new() end
  def size() 0 end

  # these methods do nothing just nice to define them

  def gsub!(x,y) end

  # mathematically acts like 0

  def + (x) x end

  # acts like empty collection

  def collect() Set.new().collect end
  
  # TODO: It's not possible to change the nil object, so below doesn't work

  # assigning to value yields new hash

  def []= (x,y) Hash.new.[]=(x,y) end

  # adding yields new Set (TODO: not sure about this one)

  def add(x) Set.new().add(x) end

  # pushing a value yields new array

  def push (x) Array.new().push(x) end

end

class Numeric

  alias xbetween? between?

  def between?(x,y) xbetween?(x.to_f,y.to_f) end

  def sgn() if (self>0) then 1 elsif (self<0) then -1 else 0 end end

  alias sign sgn

end

# better File behavior

class File
  def File.delete(f) exist?(f) && unlink(f) end
  def spew(s) write(s); close() end
end
