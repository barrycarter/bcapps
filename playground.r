#!/usr/local/bin/Rscript

saturn <- read.csv("/tmp/math.txt")
saturn$xpos <- as.numeric(as.character(saturn$xpos))

x <- saturn$day
y <- saturn$xpos


