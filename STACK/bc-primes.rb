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
  n = 1
  primes = []
  notprime = Hash.new

  until primes.size > size do

    n+=1

    # if I am known not prime, continue
    if notprime[n] then next end

    # check to see if I'm prime (abort instantly on finding divisor)
    (2..Math.sqrt(n)+1).each{|i| print "Checking #{n} vs #{i}\n"; if n%i==0 then notprime[n]=1; print "NOT A PRIME!\n"; next; end}

    # I'm prime, so add me to array + mark my multiples as being not
    # prime, but the fewer primes I need to get, the fewer multiples I
    # mark

    primes.push(n)
    (2..(size-primes.size())).each{|i| notprime[i*n] = 1}
  end
  primes
end
      
# takes 48.048u 0.039s 0:48.30 99.5%    0+0k 8+120io 0pf+0w
# time ruby ~/BCGIT/STACK/bc-primes.rb > ! oldprimes.txt
# print get_prime_numbers(10000).join("\n"),"\n";



# TODO: compare my results

# takes 59.621u 0.834s 1:00.76 99.4%    0+0k 0+120io 0pf+0w
print bc_get_prime_numbers(10000).join("\n"),"\n";

# print [1,2,3].join("\n"),"\n"


