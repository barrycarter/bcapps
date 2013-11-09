#!/usr/local/bin/ruby

# script to create state diagram for tennis game

require '/home/barrycarter/BCGIT/bclib.rb'

# scores:
# 0 = 0
# 1 = 15
# 2 = 30
# 3 = deuce w disadvantage
# 4 = 40 (or deuce)
# 5 = deuce w advantage
# 6 = 60 (victory)

# GameState is a list; entry n = player n score (n=0|1)

class GameState
 def initialize(l) @l=l end

 # TODO: genericize this
 def l() @l end

 def inspect() return @l end

 # the next state if nth player scores
 def nextstate(n)
   # store current state in array
   t = @l.dup;

   # one player has won? nothing more to do, but return empty game
   if (@l[0]==6 || @l[1]==6) then return self end

   # player with 0 or 15 or deuce advantage scores
   if @l[n]<=1 || @l[n]==5 then
     t[n]+=1;
     return GameState.new(t) 
   end

   # player with 40 scores, other player has 30 or less
   if @l[n]==4 && @l[1-n]<=2 then
     t[n] = 6;
     return GameState.new(t)
   end

   # player with 30 scores
   if @l[n]==2 then
     t[n] = 4;
     return GameState.new(t)
   end

   # player with deuce disadvantage scores (yields deuce)
   if @l[n]==3 then return GameState.new([4,4]) end

   # during deuce, one player scores
   if @l[n]==4 && @l[1-n]==4 then
     t[n] = 5;
     t[1-n] = 3;
     return GameState.new(t)
   end

   self.td("NO NEXT STATE?")

 end
end

# start with an array containing new game
$DEBUG=1;
games = [GameState.new([0,0])]
hash = Hash.new
seen = Hash.new

while i=games.shift do
  if i==0 then next end
  # have we seen this game (ie, this pair of scores)
  if seen[i.l] then next else seen[i.l]=1 end
  td("NEXT STATES: #{i.l} -> #{i.nextstate(0).l}, #{i.nextstate(1).l}")
  hash[i] = Hash.new
  hash[i][0] = i.nextstate(0)
  hash[i][1] = i.nextstate(1)
  games.push(i.nextstate(0))
  games.push(i.nextstate(1))
#  games.inspect.td("GAMES")
end

# print hash.keys.each{|i| print "#{i}, #{hash[i][0]}, #{hash[i][1]}\n"}

# print GameState.new([4,2]).nextstate(1).inspect
# hash = Hash.new(Hash.new)








