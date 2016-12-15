#!/usr/local/bin/ruby

# https://www.codewars.com/kumite/5807144337a4fd04cc000093?sel=584ff72d019ddf8672000126

require '/home/barrycarter/BCGIT/bclib.rb'

def divisors (n)
    fact = []
    for i in 1.. (Math.sqrt(n)).floor
        if n % i == 0 
            fact << i
            # more rubyish i think
            fact << (n / i) if (n / i) != i
        end
    end
    # no need for "return" in ruby
    fact.sort
end

def divisors2(n)
  fact = Hash.new();
  (1..Math.sqrt(n)).select{|i| n%i==0 && i!=n}.each{|i| fact[i] = fact[n/i] = 1};
  fact.keys.sort
end

$DEBUG=1;
print divisors2(109),"\n"



