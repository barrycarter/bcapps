#!/bin/perl

# Uses XWD to take a screenshot and iwatch-cron (or whatever) to let
# me edit and convert the screenshot

# gives me time to get to the correct screen/window

sleep(2);

system("xwd > ~/SCREENSHOTS/`date +%Y%m%d.%H%M%S.%N`.xwd");

# TODO: set up iwatch to do something with this
