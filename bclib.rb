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

class Array
  # keep originals around where they exist
  alias minus -

  # TODO: distinguish between dividing/etc by number or array

  # allow division by number
  def /(n) self.collect{|i| i/n} end

  # allow subtraction by array
  def -(a) (0..self.length-1).collect{|i| self[i]-a[i]} end


end
