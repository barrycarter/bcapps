NOTE: ignoring x<0 but need to be careful never to use it

pdf[lam_,x_] = lam*Exp[-lam*x]
cdf[lam_,x_] = 1-Exp[-lam*x]

Naomi waits t if lam1 = t, lam2 > t (or vice versa)

pdfNaomiClerk1[lam1_,lam2_,t_] = pdf[lam1,t]*(1-cdf[lam2,t])
pdfNaomiClerk2[lam1_,lam2_,t_] = pdf[lam2,t]*(1-cdf[lam1,t])

pdfNaomiClerk1[lam1,lam2,t]/pdfNaomiClerk2[lam1,lam2,t]

pdfNaomi[lam1_,lam2_,t_] = FullSimplify[
 pdfNaomiClerk1[lam1,lam2,t]+pdfNaomiClerk2[lam1,lam2,t]]

meanWaitNaomi[lam1_,lam2_]=Integrate[t*pdfNaomi[lam1,lam2,t], {t,0,Infinity}]

wait[lam1_,lam2_] = FullSimplify[(1/lam2 + 1/(lam1+lam2))*(lam2/(lam1+lam2)) + 
(1/lam1 + 1/(lam1+lam2))*(lam1/(lam1+lam2))]














