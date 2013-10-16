#!/usr/local/bin/ruby

# script to create state diagram for tennis game

# scores:
# 0 = 0
# 1 = 15
# 2 = 30
# 3 = duece w disadvantage
# 4 = 40 (or deuce)
# 5 = deuce w advantage
# 6 = 60 (victory)

# if x has x points, y has y points, and n scores (n=0 -> x, n=1 ->y),
# return next score in x,y format

def nextscore(x,y,n)
  # TODO: reference arguments by index? (could reduce these two lines to one)

  # 30 points or less just increases score
  if n==0 && x<=2 then return [x+1,y] end
  if n==1 && y<=2 then return [x,y+1] end

  # if you have advantage and score, you win
  if n==0 && x==5 then return [6,y] end
  if n==1 && y==5 then return [x,6] end

  # if you have disadvantage and score, go to deuce
  if n==0 && x==3 then return [4,4] end
  if n==1 && y==3 then return [4,4] end

end

print [0,1].each{|n| nextscore(0,0,n)}.inspect

# print r.inspect;
print "\n";




