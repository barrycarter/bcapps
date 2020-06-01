data = read.csv("/tmp/mars.txt", stringsAsFactors=FALSE, header=FALSE);

f = function(e, n) {return(2*(e-1)/(n-1) - 1);}

t1303 = f(c(1:length(data[,1])), length(data[,1]));

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

fit2 = splinefun(data[,-1]);

fit = lm(data[,1] ~ poly(data["index"][,1], 3));


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


fit = lm(c(4,5,6) ~ poly(c(1,2,3),1, raw=FALSE))



