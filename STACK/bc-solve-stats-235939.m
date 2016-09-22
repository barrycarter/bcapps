(*

I'm not happy with this answer, but my fingers needed the exercise.

Let's take the problem very literally and assume that both networks
MUST fail EXACTLY 2 times per year. Let's also briefly assume that the
networks fail at the start of a given hour.

There are 8760 ways to choose "A" network's first failure hour and
8757 ways to choose "A" network's second failure (since it can't
overlap the first failure). Since we can choose any pair of failure
times in either order, we divide by two. Thus, there are 8760*8757/2
ways to choose the two failure times for network "A".

There also 8760*8757/2 ways to choose the two failure times for
network "O". Of these ways, how many *don't* overlap the two "A"
failures? There's 8754 start hours for the first failure (avoiding the
6 failure hours taken up by "A"), and 8751 start hours for the second
failure (avoiding the 6 "A" failure hours and the 3 "O" first failure
hours). Again, we can choose these in either order, for a total of
8754*8751/2

Dividing these, we get (8754*8751/2)/(8760*8757/2) = 4255903/4261740
as the chance of non-failure in a given year, and thus
1-4255903/4261740 = 5837/4261740 chance of failure, which is about
0.14%, which agrees with @jwimberley's computation. This is roughly
1/730, so you would expect a failure once every 730.25 years or so.



TODO: my comment wrong





In one year, the "A" network will
fail twice; let's call the start times of these failures t1 and t2,
choosing t1 < t2. The "A" network is down in the intervals (t1,t1+3)
and (t2,t2+3). Note that t2 >= t1+3 since the failures can't overlap.

n*(n-3600*3)/2

((n-3600*6)*(n-3600*9)/2)/(n*(n-3600*3)/2)

8760*8757/2

8754*8751/2


TODO: well-defined
