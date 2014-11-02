
$a = Hash.new
# $a[1] = 7
$a[1][2] = 3

exit

a = [1,2,3,4,5,6,7,8,9,10,11,12].each_slice(4).to_a
a = a.map{|i| i.each_slice(2).to_a}
print a.inspect,"\n"
