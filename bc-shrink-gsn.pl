#!/bin/perl

# Shrinks the GSN schedule
# (http://www.gsn.com/cgi/onair/program_schedule_print.html) to print
# on fewer pages

# This is another one off that helps only me, with the slight
# possibility it won't even help me

require "/usr/local/lib/bclib.pl";

# Idea is to create our own array from table, abbreviate, and print that

$all = read_file("/home/barrycarter/BCGIT/db/program_schedule_print.html");

debug($all);
