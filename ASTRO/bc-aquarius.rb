#!/usr/local/bin/ruby

# TODO: remove above after testing: this is a library, not a program

# Attempt to create an astronomical library for Ruby that is fairly precise

require '/home/barrycarter/BCGIT/bclib.rb'
require 'date'
require 'matrix'

module Aquarius

  # position of planets, a 2-D hash
  @position = Hash.new{|k,v| k[v] = Hash.new}

  # TODO: replace with attr_accessor
  def self.position() @position end
  def self.emrat() @emrat end

  # TODO: put this in some sort of "initialize"
  @chunklength = 26873; # length of a chunk in ascp1950.430

  # planets, with starting position of coefficients, number of
  # coefficients per axes, and number of sets of coefficients per
  # 32-day period (we don't actually use the start position)

  # moongeo = Moon's position from Earth
  # earthmoon = Earth/moon barycenter from solar system barycenter
  # NOTE: this really should be an associative array or something
  @planets = ["mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
    "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
    "uranus:387:6:1", "neptune:405:6:1", "pluto:423:6:1",
    "moongeo:441:13:8", "sun:753:11:2", "nutate:819:10:4"]

  # Earth-moon gravitation ratio, used to calculate position of Earth
  # which is stupidly not provided in ascp1950.430
  # TODO: this should not have to be here!
  @emrat = 813005690741906200*10**-16

  # obtain the nth set of Chebyshev coefficients from ascp1950.430 and
  # return it as an array. ascp1950.430 must exist, uncompressed, in
  # /home/barrycarter/SPICE/KERNELS TODO: make /home/barrycarter or
  # the entire path a variable

  # TODO: allow other year ranges as well

  # TODO: is self.methodname the best thing here?

  def self.getcoeffs(n)
    f = File.open("/home/barrycarter/SPICE/KERNELS/ascp1950.430")
    f.seek(@chunklength*(n-1),IO::SEEK_SET)
    f.read(@chunklength).split.map{|i| ascp2num(i)}
  end

  # convert ASCP numbers to rational numbers
  def self.ascp2num(num)
    (mant,exp) = num.split("D")
    # if there is no "D" return number as is
    if exp.nil? then return num end
    # negative?
    if mant.slice!("-") then sign=-1 else sign=1 end
    sign*mant[2..-1].to_i*10**(exp.to_i-16)
  end

  # given Date, return array in ascp1950.430 for Date (include fraction)
  def self.date2chunk(date) ((date.ajd-2433264.5)/32)+1 end

  # given a list of coefficients (returned from ascp2num), store
  # coefficients for planets

  def self.coeffs2poly(coeffs)

    # the chunk number and total number of chunks is useless to us
    coeffs.slice!(0,2)
    # Julian start/end date for this set
    (jdstart, jdend) = coeffs.slice!(0,2)
    # +16 puts it right in the middle of period, avoids roundoff errors
    chunk = date2chunk(Date.jd(jdstart+16)).floor

    @planets.each{|i|
      (name, start, ncoeffs, nperiods) = i.split(":")
      # TODO: this is ugly
      (start, ncoeffs, nperiods) = [start, ncoeffs, nperiods].map{|i| i.to_i}
      # obtain the coefficients for each period for this planet
      # TODO: the "*3" won't work for nutations or librations
      @position[name][chunk] = (coeffs.slice!(0,ncoeffs*nperiods*3).each_slice(ncoeffs*3).to_a).map{|i| i.each_slice(ncoeffs).to_a}
    }

  end

  # Return planet's xyz coordinates (in ICRF) at date
  def self.planetpos(planet, date)
    # special case for earth
    if (planet=="earth") then return planetpos("earthmoon",date)-planetpos("moongeo",date)/@emrat end

    # what chunk does this date fall in and what position
    # TODO: shorten code below
    chunk = date2chunk(date)
    pos = chunk-chunk.floor
    chunk = chunk.floor

    # do we have this data? if not, get it
    unless @position[planet][chunk] then coeffs2poly(getcoeffs(chunk)) end

    # which subarray of above (and find decimal part too, as t member -1,1)
    subarr = pos*@position[planet][chunk].length
    t = (subarr-subarr.floor)*2-1
    subarr = subarr.floor

    # if this data has multiple subarrays, which array do we want
    coeffs = @position[planet][chunk][subarr]
    # evaluate for all 3 coordinates
    Vector.elements(coeffs.collect{|i| Math.chebyshevlist(i,t)}, copy=false)
  end

end

# testing

$DEBUG = 1

(1..30).each{|i|
  date = Date.new(2014,11,i)
  pos = Aquarius.planetpos("sun", date)-Aquarius.planetpos("earth", date)
  pos = pos.to_polar
  print "#{i}: #{pos[1]*12/Math::PI.modulo(24)}, #{pos[2]*180/Math::PI}\n"
#  Aquarius.planetpos("earthmoon", Date.new(2014,11,i)).map{|i| i.to_f}.td(i)
#  Aquarius.planetpos("earth", Date.new(2014,11,i)).map{|i| i.to_f}.td(i)
#  Aquarius.planetpos("moongeo", Date.new(2014,11,i)).map{|i| i.to_f}.td(i)
}

exit

date = DateTime::now
date.td("DATE")
(180/Math::PI*(Aquarius.planetpos("moongeo", date).to_polar)).td("test")

exit

earthmoon = Aquarius.planetpos("earthmoon", date).td("earthmoon")
moongeo = Aquarius.planetpos("moongeo", date).td("moongeo")
(earthmoon-moongeo/Aquarius.emrat).td("earth?")

([1,2,3]-[4,5,6]).td("foo")

([1,2,3]/Aquarius.emrat).td("test")

# what we want for earth:
# {2014, 2456962.500000000, 1.169539108800286*10^+08, 8.425850684626275*10^+07, 3.650516654653425*10^+07},
