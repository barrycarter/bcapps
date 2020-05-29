#!/usr/local/bin/Rscript

png("/tmp/output.png", height=600, width=800)

saturn <- read.csv("/tmp/math.txt")
saturn$xpos <- as.numeric(as.character(saturn$xpos))

x = saturn$day
y = saturn$xpos

fit = nls(y ~ a+b*cos(c1*x-d), start=list(b=max(abs(y)),a=0,c1=.005,d=0))

fit

# typeof(fit)

# names(fit)

attributes(fit)

plot(x,residuals(fit))

# summary(fit$call)

# saturn$xpos

# summary(fit)

# plot(saturn$day,saturn$xpos)
# cor(saturn$day,saturn$xpos)

# x <- saturn$day
# y <- saturn$xpos

# summary(saturn)

# stripchart(saturn$xpos)
# hist(saturn$xpos)

# dnorm(saturn$day)

# x <- c(1,2,3)
# y <- c(4,5,6)

# fit = nls(y ~ a+b*cos(c1*x-d))

# summary(fit)

# lines(x,predict(fit,x))

# plot(x,y)
