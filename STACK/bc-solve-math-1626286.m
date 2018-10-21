(*

This problem seems to have a lot of redundant information.

Let's choose t=0 as the time when the point is at the origin, so that:

x[0] == 0
y[0] == 0

Note that t<0 when the problem starts.

Since the acceleration is directed towards the focus, we have:

direction of x''[t] == -x[t]
direction of y''[t] == 1/4-y[t]

Let's compute the unit vector here. This would be the direction
divided by the magnitude or:

x''[t] == (-x[t])/Norm[{-x[t], 1/4-y[t]}]
y''[t] == (1/4-y[t])/Norm[{-x[t], 1/4-y[t]}]

The magnitude of the acceleration varies inversely with the square of
the distance to the focus point, so we have:

mag[t] == k/(x[t]^2+(y[t]-1/4)^2)

Plugging in t=0, we have

mag[0] == k/(0^2+(-1/4)^2) == 16*k

Since we also know the acceleration at t=0 is <0,1> and thus has
magnitude 1, k=1/16.

Thus, our acceleration vector is:

x''[t] == (-x[t])/Norm[{-x[t], 1/4-y[t]}]/16
y''[t] == (-y[t])/Norm[{-x[t], 1/4-y[t]}]/16

Since we know the particle's speed at the origin, we have

Norm[{x'[t],y'[t]}] == 2

*)

DSolve[{
 x[0] == 0, y[t] == x[t]^2, x'[0] == 2, 
x''[t] == (-x[t])/Norm[{-x[t], 1/4-y[t]}]/16
}, {x[t],y[t]}, t]

test = NDSolve[{
 x[0] == 0, y[t] == x[t]^2, x'[0] == 2, 
x''[t] == (-x[t])/Norm[{-x[t], 1/4-y[t]}]/16
}, {x[t],y[t]}, {t,-1,1}]

 
