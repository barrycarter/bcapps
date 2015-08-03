#!/bin/perl

require "/usr/local/lib/bclib.pl";

bc_check_file_of_files_age("$bclib{githome}/NAGIOS/recentfiles.txt");
