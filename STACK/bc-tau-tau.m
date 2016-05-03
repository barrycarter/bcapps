(*

http://stats.stackexchange.com/questions/210313/how-to-specify-exact-rise-to-peak-and-decay-to-baseline-times-in-an-exponential

This doesn't fully answer your question, but may help.

Since I'm using Mathematica (which dislikes subscripted variable
names), I'll substitute $\sigma$ for $\tau _{\text{off}}$ and $\tau$
for $\tau _{\text{on}}$, so your function becomes:

$f(t,\tau ,\sigma ) = 
A e^{-\frac{t}{\sigma }} \left(1-e^{-\frac{t}{\tau }}\right)$

To find the maximum, we take the derivative (with respect to $t$) and
set it equal to 0:

$
\frac{\partial f(t,\tau ,\sigma )}{\partial t} =
   \frac{A e^{-t \left(\frac{1}{\sigma }+\frac{1}{\tau }\right)} \left(\sigma
    -\tau  e^{t/\tau }+\tau \right)}{\sigma  \tau }=0
$

yielding:

$t\to \tau  \log \left(\frac{\sigma +\tau }{\tau }\right)$

Note that, in your example, the maximum occurs at $3 \log
\left(\frac{13}{3}\right)$, which is about 4.399, not 3.

The value of the function at this $t$ (in other words, the peak value
of the function) is:

$
   f\left(\tau  \log \left(\frac{\sigma +\tau }{\tau }\right),\tau ,\sigma
    \right)=A \sigma  \tau ^{\frac{\tau }{\sigma }} (\sigma +\tau
    )^{-\frac{\sigma +\tau }{\sigma }}
$

If you want the peak to occur at $t=\alpha$ for some value of
$\alpha$, you solve:

$\tau  \log \left(\frac{\sigma +\tau }{\tau }\right)=\alpha$

to get:

$\sigma \to \tau  e^{\alpha /\tau }-\tau$

You can then similarly solve for $\tau$ to get your baseline where you
want it.



sig[tau_,alpha_] = -tau + E^(alpha/tau)*tau

The value of the function at $\sigma +\tau$ is:

$
   f(\tau +\sigma ,\tau ,\sigma )=A e^{-\frac{\sigma +\tau }{\sigma }}
    \left(1-e^{-\frac{\sigma +\tau }{\tau }}\right)
$

Although you didn't specify a baseline, your questions suggests that you want:

$
   \frac{f(\tau +\sigma ,\tau ,\sigma )}{f\left(\tau  \log \left(\frac{\sigma
    +\tau }{\tau }\right),\tau ,\sigma \right)} \approx 0
$

In other words, you want the value at $\sigma +\tau$ to be small
compared to the peak. As a note, I'm not sure you should be looking at
$\sigma +\tau$, but I'll answer the question as given.

Using 1% ($\frac{1}{100}$) of the peak as an arbitrary "baseline", we want:

$
   \frac{f(\tau +\sigma ,\tau ,\sigma )}{f\left(\tau  \log \left(\frac{\sigma
    +\tau }{\tau }\right),\tau ,\sigma \right)}=\frac{1}{100}
$








*)

conds = {tau>sigma, sigma>0, t>0}

f[t_,tau_,sigma_] = A*(1-Exp[-t/tau])*Exp[-t/sigma]

tcrit[tau_,sigma_] = Solve[D[f[t,tau,sigma],t]==0, t][[1,1,2]]

{{t -> ton*Log[(toff + ton)/ton]}}

f[ton*Log[(toff + ton)/ton], ton, toff]

(a*toff*ton^(ton/toff))/(toff + ton)^((toff + ton)/toff)



