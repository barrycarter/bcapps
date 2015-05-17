#!/bin/perl

# Displays different page depending on IP address (ie, google sees one
# thing, the rest of the world sees something else)

require "/usr/local/lib/bclib.pl";

# if this is a legit user, find the file we actually want to display
# TODO: handle case where request is for index (ie, just the virtual dir then?)
