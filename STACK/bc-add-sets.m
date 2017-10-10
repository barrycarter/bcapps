(*

https://stackoverflow.com/questions/46629934/given-a-pair-of-integers-minimum-of-operations-performed-to-reach-target-n

Given a set {A,B} we can go to {A+B, B} or {A, A+B} start with {1,1} get to A=N or B=N

f[{a_,b_}] = DeleteDuplicates[{{a+b,b},{a,a+b}}]

s[0] = {{1,1}}

s[n_] := Flatten[Map[f,s[n-1]],1]

f[{a_,b_}] = Flatten[{{a+b,b},{a,a+b}}]

f[list_]:={{list[[1]]+list[[2]], list[[1]]}, {list[[1]], list[[1]]+list[[2]]}}


