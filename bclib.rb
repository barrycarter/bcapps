# A Ruby library

# print string to stderr if $DEBUG is set

def debug(s) if $DEBUG then $stderr.print("#{s}\n") end end

# inline debugging for all objects
class Object
  def td(s) debug("#{s}:#{self.inspect}"); self end
end

# a bunch of utilities

# TODO: organize this better

module Util

  # Compute the nth ChebyshevT polynomial evaluated at t
  def chebyshevt(n,t)
    if n==0 then return 1 end
    if n==1 then return t end
    2*t*chebyshevt(n-1,t)-chebyshevt(n-2,t)
  end

  # Given a list of ChebyshevT coefficients (0th one first), evaluate at t
  def chebyshevlist(list,t)
    [0..list.length].each{|i| tot+=chebyshevt[i,t]*list[i]}
    tot
  end


end
