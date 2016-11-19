# these are things I must run manually BEFORE starting X11

# Since I killed NetworkManager (perhaps a bad decision), must run
# dhclient manually

# decided to tolerate NetworkMananger, so this file is currently
# completely unneeded

# sudo dhclient

# for some reason, neither Network Manager or the system default
# routing brings up the lo interface-- it's harmless, but I dislike
# using the Ethernet interface for loopback

# TODO: check that Network Manager actually brings this up
# sudo route add -net 127.0.0.0 netmask 255.0.0.0 lo

# TODO: uncomment below

# this daemon destructively checks all my mail; however, since it's
# destructive (removes mail from the remote servers), I can't run it
# until I completely switch over to brighton

# /home/barrycarter/BCGIT/bc-getmail.pl &

# this starts recollindex, but I'm not quite ready to do that on brighton

# TODO: uncomment below
# sudo recollindex -m -x

