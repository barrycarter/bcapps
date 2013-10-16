# A Ruby library

# print string to stderr if $DEBUG is set

def debug(s) if $DEBUG then $stderr.print("#{s}\n") end end

# inline debugging for all objects
class Object
  def trde(s) debug("#{s}:#{self.inspect}"); self end
end
