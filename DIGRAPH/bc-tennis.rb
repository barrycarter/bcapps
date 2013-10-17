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

 # the next state if nth player scores
 def nextstate(n)
   # store current state in array
   t = @l.dup;

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
 end

 # fill in given has with all possible future gamestates (using recursion)
 def futurestates(hash)
   # if I am a final state, just return hash
   if @l[0]==6 || @l[1]==6 then return hash end
   # if my hash states are already defined, do nothing
   hash[self].td("ME")
   if (hash[self][0]) then return hash end
   # first for myself
   # TODO: put in loop
   hash[self][0] = self.nextstate(0)
   hash[self][1] = self.nextstate(1)
   hash = hash.merge(self.nextstate(0).futurestates(hash))
   hash = hash.merge(self.nextstate(1).futurestates(hash))
   return hash
 end

end

# print GameState.new([4,2]).nextstate(1).inspect

$DEBUG=1;
hash = Hash.new(Hash.new)
GameState.new([0,0]).futurestates(hash)

hash.td("HASH")






