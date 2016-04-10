(* uses the invariance of ds to look over relativity issues *)

position of accel obj in its own frame

norm1Square[t_] = (v0*dt + a*t*dt)^2 - dt^2

norm2Square[tau_] = f[tau]^2*dtau^2 - dtau^2

trueNorm1[t_] = Sqrt[-1 + a^2*t^2 + 2*a*t*v0 + v0^2]

trueLength[t_] = Integrate[trueNorm1[t], t]

(* massive simplify *)

norm1Square[t_] = a*t*dt^2 - dt^2

norm2Square[tau_] = f[tau]^2*dtau^2 - dtau^2

trueNorm1[t_] = Sqrt[-1 + a t]

trueLength1[t_] = Integrate[trueNorm1[t], t]

g[tau_] = Solve[norm1Square[t] == norm2Square[tau], dtau][[1,1,2]]

s = (t, s0 + v0*t + a*t^2/2, 0, 0)

ds = (dt, v0*dt + a*t*dt, 0, 0)

norm[a_,v0_,t_] = Sqrt[Simplify[((v0*dt + a*t*dt)^2 - dt^2)/dt^2]]

length[t_] = ((a*t + v0)*Sqrt[(-1 + a*t + v0)*(1 + a*t + v0)] - 
  Log[a*t + v0 + Sqrt[(-1 + a*t + v0)*(1 + a*t + v0)]])/(2*a)

normAlt[tau_] = Sqrt[Simplify[((f'[tau]*dtau)^2 - dtau^2)/dtau^2]]

Integrate[normAlt[tau], tau]



g[tau_] = Solve[norm2[tau] == norm[a,v0,t,dt], f'[tau]][[1,1,2]]

Integrate[g[tau]*dtau, tau]



obs2 = (tau, f(tau), 0, 0)

ds = (dtau, f'(tau)*d(tau), 0, 0)

norm2 = (f'[tau]*d(tau))^2 - dtau^2

g[tau_] = Solve[norm==norm2, f'[tau]][[2,1,2]]





