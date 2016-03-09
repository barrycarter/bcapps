def get_prime_numbers(size)
  fixnum_max = (2**(0.size * 8 - 2) - 1)
  primes = []
  return [] if size < 1
  (2..fixnum_max).each do |num|
    # want to break it when got all asked primes so it will
    # not go for infinite
    break if primes.size >= size
    # check if num is odd by dividenum and add it
    primes.push(num) if (2..num - 1).all? { |dividenum| num % dividenum > 0 }
  end
  primes
end

# modified Sieve of Eratosthenes
def bc_get_prime_numbers(size)
  n = 2
  primes = []
  notprimes = Hash.new

  until primes.size > size do

    # note my multiples aren't primes (even if I'm not prime myself
    # since I'm limiting to n^2)
    (2..2**size).each{|i| notprimes[i*n] = 1}

    # if I am not not prime, I am prime
    if !notprimes[n] then primes.push(n) end

    print "#{n}\n";

    n+=1;
  end
  primes
end
      
# takes 48.921u 0.006s 0:48.98 99.8%    0+0k 0+136io 0pf+0w
# time ruby ~/BCGIT/STACK/bc-primes.rb > ! oldprimes.txt
# print get_prime_numbers(10000)



# TODO: compare my results

print bc_get_prime_numbers(10000)
