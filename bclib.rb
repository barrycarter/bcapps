# A Ruby library

# print string to stderr if $DEBUG is set

def debug(s) if $DEBUG then $stderr.print("#{s}\n") end end

# inline debugging for all objects
class Object
  def td(s) debug("#{s}:#{self.inspect}"); self end
end

# add stuff to Math (should this be Polynomial?)
module Math

  # Compute the nth ChebyshevT polynomial evaluated at t
  def self.chebyshevt(n,t)
    if n==0 then return 1 end
    if n==1 then return t end
    2*t*chebyshevt(n-1,t)-chebyshevt(n-2,t)
  end

  # Given a list of ChebyshevT coefficients (0th one first), evaluate at t
  def self.chebyshevlist(list,t)
    (0..list.length-1).collect{|key| chebyshevt(key,t)*list[key]}.reduce(:+)
  end

end

# polar vectors

class Vector
  
  # TODO: add 2D polar if needed
  def to_polar()
    Vector.elements([self.norm, Math.atan2(self[1],self[0]), Math.asin(self[2]/self.norm)])
  end

  # TODO: add 2D if needed
  def to_rect()
    Vector.elements([self[0]*Math.cos(self[1])*Math.cos(self[2]),
		      self[0]*Math.sin(self[1])*Math.cos(self[2]),
		      self[0]*Math.sin(self[2])])
    end

end

# TODO: this code is poorly written

class Temperature
  attr_reader :f, :c, :k

  def f=(f)
    @f=f;
    @c=(@f-32)/1.8;
    @k=@c+273.15;
  end

  def c=(c)
    self.f=c*1.8+32;
  end
  
  def k=(k)
    self.c=k-273.15;
  end

  alias kelvin= k=;
  alias kelvin k;

  def to_s
    @c.to_s+" deg C == "+@f.to_s+" deg F == "+@k.to_s+" deg K\n";
  end

end
