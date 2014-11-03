# Attempt to create an astronomical library for Ruby that is fairly precise

require '/home/barrycarter/BCGIT/bclib.rb'
require 'date'

module Aquarius

  # TODO: attr_ this
  def self.position() @position end

  # useful constants
  @chunklength = 26873; # length of a chunk in ascp1950.430

  # planets, with starting position of coefficients, number of
  # coefficients per axes, and number of sets of coefficients per
  # 32-day period (we don't actually use the start position)

  # NOTE: this really should be an associative array or something
  @planets = ["mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
	      "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
	      "uranus:387:6:1", "neptune:405:6:1", "pluto:423:6:1",
	      "moongeo:441:13:8", "sun:753:11:2", "nutate:819:10:4"]

  # position of planets, a 2-D hash
  @position = Hash.new{|k,v| k[v] = Hash.new}

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
    coeffs.collect{|i| Math.chebyshevlist(i,t)}
  end

end

# testing

$DEBUG = 1
# Aquarius.getcoeffs(7).td("ALPHA")
# Aquarius.ascp2num("0.3570991140230295D-09").td("alpha")

# test1 = Aquarius.date2chunk(Date.new(2014,11,2)).td("alpha")
# test2 = Aquarius.coeffs2poly(Aquarius.getcoeffs(test1))

# pos = Aquarius.position

# test3 = pos["mercury"][741][0][0]

# Math.chebyshevlist(test3, 0).to_f.td("output")

(1..30).each{|i|
  Aquarius.planetpos("mercury", Date.new(2014,11,i).td("date")).map{|i| i.to_f}.td(i)
}

# Math.chebyshevlist([1,2,3],0.6).td("test")
# (1*Math.chebyshevt(0,0.6)).td("0")
# (2*Math.chebyshevt(1,0.6)).td("1")
# (3*Math.chebyshevt(2,0.6)).td("2")







    
