(*

https://www.quora.com/Five-men-and-three-women-are-to-be-seated-around-a-circular-table-What-is-the-probability-that-no-two-women-sit-together

There are 11520 ways to seat these people.

I couldn't find a trivial way to solve this problem: here's a non-trivial way.

For the moment, let's assume the chairs are different, so there are 8 ways to seat the first woman, and 3 choices for who the first woman will be, for a total of 24 choices.

We must now seat a man to her "left" (counterclockwise) and another man to her "right" (clockwise). There are 5*4 ways to choose these men (since order matters).

We now have a total of 24*5*4 = 480 ways to seat the first 3 people.

There are now 3 men and 2 women left. There are 5! = 120 ways to seat them, but some of these seatings will have 2 women sitting next to each other.

Specifically, these four meta-arrangements will have two women sitting together: FFMMM, MFFMM, MMFFM, MMMFF

For the meta-arrangement "FFMMM" (for example), we can choose 2 women for the first spot, the remaining woman for the second spot, 3 men for the 3rd spot, 2 men for the 4th spot, and the remaining man for the 5th spot. That's a total of 2*1*3*2*1 = 24 choices. For all four meta-arrangements that's a total of 96 choices with two women sitting together.

Thus, there are 120-96 = 24 ways of seating the remaining 5 people with no women sitting next to each other.

Thus, the total number of ways with no women sitting together is 480*24 = 11520.

I'm convinced there's an easier way to do this in general (n men, m women), one that doesn't involve the tedious https://en.wikipedia.org/wiki/Inclusion%E2%80%93exclusion_principle: can anyone find such a method and give a better answer?

*)
