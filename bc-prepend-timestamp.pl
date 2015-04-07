#!/bin/perl

# Copies stdin to stdout but prepends the Unix timestamp

# Very similar to annotate-output (and even to nl in some sense)

# no buffering
$|=1; while (<>) {print time()," $_";}
