#!/usr/local/bin/ruby

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
  (1..Math.sqrt(n)).td("A").select{|i| n%i==0}.td("B").each{|i| fact[i] = 1};
  print(fact.keys)
end

$DEBUG=1;
divisors2(55)

