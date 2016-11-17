# this runs (automagically) whenever I start FVWM

# my screen size is 1024x768

# TODO: find a way to customize this without having to run xrandr,
# although
# http://askubuntu.com/questions/74808/how-do-i-force-a-resolution-of-1024x768
# suggests it's nontrivial

xrandr --size 1024x768

# TODO: once I start using brighton directly, no reason to allow VNC
# so turn this off

/usr/libexec/vino-server & 

# The exec below replaces the xinit process (which is no longer
# necessary after the above) with the fvwm2 window manager-- I think

exec fvwm2
