data = read.csv("/tmp/mars.txt", stringsAsFactors=FALSE, header=FALSE);

f = function(e, n) {return(2*(e-1)/(n-1) - 1);}

index = f(c(1:length(data[,1])), length(data[,1]));

fit = lm(data[,1] ~ poly(index, 3, raw=TRUE));

fit2 = lm(data[,1] ~ poly(index, 4, raw=TRUE));

plot(index, data[,1], col="red");

lines(index, fitted(fit), col="green");

lines(index, fitted(fit2), col="purple");


vals = data[,1];

plot(t1303, vals);

fit = lm(vals ~ poly(t1303, 3));

fit = lm(vals ~ poly(t1303, 3));

fit = lm(head(vals,10) ~ poly(head(t1303,10), 3));


fit = lm(c(1,2,3) ~ poly(c(4,5,6), 1));


data["index"] = f(c(1:length(data[,1])), length(data[,1]))

data["fuindex"] = f(c(1:length(data[,1])), length(data[,1]))

fit = lm(c(1,2,3) ~ poly(c(4,5,6), degree=2));

fit = lm(data[,1] ~ poly(data["index"][,1], 1));

fit = lm(data[,1] ~ poly(data["index"][,1], 3));

fit4 = lm(data[,1] ~ poly(data["index"][,1], 4));




plot(fitted(fit))
lines(data["index"][,1], data[,1],col="green")

1 -> -1
n -> +1

2/(n-1)*x + 1/(n-1)

2/(n-1) - 1

1/(n-1) 

(2x+1)/(n-1)

2(x-1)/(n-1) - 1


Subject: How does lm work in R?

<pre><code>

fit = lm(c(4,5,6) ~ c(1,2,3))

# WRONG: fit = lm(c(4,5,6) ~ poly(c(1,2,3),1), raw=TRUE)


fit = lm(c(4,5,6) ~ poly(c(1,2,3),1, raw=TRUE))

# given set of coefficients, return polynomial

arr2func = function(arr) {
  g = function(x) {
    tot = 0;
    for (i in c(1:length(arr))) {tot = tot + arr[i]*x^(i-1);}
    return(tot);
  }
 return(g);
}

arr2func(fit$coefficients);

max(abs(fit$residuals));


> curve(arr2func(fit$coefficients)(x), -1, 1, col = 'purple', add = TRUE);

> plot(function(x){return(x^2)}, -1, 1)

matlab vs r vs julia vs python

