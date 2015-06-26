#!/bin/perl

# Given a list of source/target directories (each line
# "source<TAB>target"), use bc-mirror-server.pl to mirror sources to
# targets, but mirror oldest directories (those that haven't been
# rsync'd for the longest time) first; I sometimes kill the nightly
# process that mirrors some directories to others; this program
# mitigates the damage from that

