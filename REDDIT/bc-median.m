(*

* Let the five scores in order be {a,b,c,d,e}.

* Since x is the median, it must be that c=x, giving us {a,b,x,d,e}

* Since the mode is larger than the median, it must be either d or e.

* If it's a true mode (not just one of many modes), it must appear at least twice in the list. The only way this can happen is if d = e.

* Thus, our list is now {a,b,x,d,d}

* Since we know the mode (which is d) is one greater than the median, we have {a,b,x,x+1,x+1}

* The mean of our list is a+b+x+(x+1)+(x+1)/5, or (a+b+3x+2)/5

* We also know the mean is one less than the median, so we have (a+b+3x+2)/5=x-1

* Solving this for a+b gives us a+b=2x-7

* We now consider cases. Since x an element of the list, it must be an integer (it can't be 6.5 for example). Since we're given x<7, the first case we try is x=6

* If x=6, we have a+b=5. Since we know a<=b, the choices for a and b are {1,4} and {2,3}

* Since I don't want to spoil the problem completely, I'll let you do the other cases. Note that we can't have a=b, because b would then be another mode (appears twice). So, ignore any cases where a=b.



Sincde 

{a,b,x,x+1,x+1}

(a+b+3x+2)/5 +1 = x

Solve[(a+b+3x+2)/5 +1 == x]

a -> -7 - b + 2 x

a + b -> 2x-7

x < 7

x also integer

{2, 3, 6, 7, 7}





*)
