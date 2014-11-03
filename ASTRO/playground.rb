module Math

  # Compute the nth ChebyshevT polynomial evaluated at t
  def self.chebyshevt(n,t)
    if n==0 then return 1 end
    if n==1 then return t end
    2*t*chebyshevt(n-1,t)-chebyshevt(n-2,t)
  end

  # Given a list of ChebyshevT coefficients (0th one first), evaluate at t
  def self.chebyshevlist(list,t)
    [0..list.length].each{|i| tot+=chebyshevt[i,t]*list[i]}
    tot
  end

end

Math.chebyshevt(1,1)

exit

$a = Hash.new
# $a[1] = 7
$a[1][2] = 3

exit

a = [1,2,3,4,5,6,7,8,9,10,11,12].each_slice(4).to_a
a = a.map{|i| i.each_slice(2).to_a}
print a.inspect,"\n"
