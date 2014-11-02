# Attempt to create an astronomical library for Ruby that is fairly precise

require '/home/barrycarter/BCGIT/bclib.rb'

class Aquarius

  # useful constants
  @chunklength = 26873; # length of a chunk in ascp1950.430

  # obtain the nth set of Chebyshev coefficients from ascp1950.430 and
  # return it as an array. ascp1950.430 must exist, uncompressed, in
  # /home/barrycarter/SPICE/KERNELS TODO: make /home/barrycarter or
  # the entire path a variable

  # TODO: allow other year ranges as well

  # TODO: is self.methodname the best thing here?

  def self.getcoeffs(n)
    f = File.open("/home/barrycarter/SPICE/KERNELS/ascp1950.430")
    f.seek(@chunklength*n,IO::SEEK_SET)
    f.read(@chunklength).split
  end

  # convert ASCP numbers to rational numbers
  def self.ascp2num(num)
    (mant,exp) = num.split("D")
    mant[2..-1].to_i*10**(exp.to_i-16)
  end

end

# testing

$DEBUG = 1
# Aquarius.getcoeffs(7)

Aquarius.ascp2num("0.3570991140230295D-09").td("alpha")

    
