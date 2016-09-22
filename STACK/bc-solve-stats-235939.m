(*

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
1/730, so you would expect a failure once every 730.125 years or so.

Above, we assumed the failures started exactly on the hour. Now, let's
suppose the failures start any second of the year. There are 8760*3600
seconds in a year, and thus that many possible start times for one of
"A"'s failures. Since 3 hours is 10800 seconds, there are
8760*3600-10800 seconds for "A"'s other failure. Again by symmetry,
there are (8760*3600)*(8760*3600-10800)/2 total pairs of start seconds
for "A"'s failure.

The same is true for "O"'s failure, so let's compute the number of
ways "O" can fail without overlapping "A"'s failure. This is
(8760*3600-10800*2) ways for one failure (excluding 6 hours) and
(8760*3600-10800*3) for the other (excluding "A"'s six hours and "O"'s
failure). Again by symmetry, there are
(8760*3600-10800*2)*(8760*3600-10800*3)/2 total pairs of seconds in
which "O"'s failures can start without overlapping "A"'s.

Taking the ratio
((8760*3600-10800*2)*(8760*3600-10800*3)/2)/((8760*3600)*(8760*3600-10800)/2)
we have 4255903/4261740 times when that doesn't happen, exactly the
same as we got before. Of course, we could do the same computation for
microseconds, but the above demonstrates we'd end up getting the same
answer each time.

Ultimately, we're doing what @jwimberley did, but using
discrete/combinatoric methods.

My comment of once every 243 years was wrong for the following reason:
if you choose a random point in the year, the chances that both
networks are down is indeed 1 in 2,131,600. However, there's no
guarantee the double outage would last the entire hour. In fact, my
guess is almost exactly 3 times too small, suggesting that, if there
is a double outage at a given point in time, it will resolve itself
within 1/3 hour or 20 minutes (however, I haven't done the math on
this last part)

Minutiae: in the Gregorian calendar, there are 8765.82 hours in a
year, excluding leap seconds.

FALSE: Including leap seconds, it's closer to 8765.81 hours. [not
true, since leap seconds are about something else entirely]

