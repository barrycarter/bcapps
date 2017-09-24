# this runs (automagically) whenever I start X11

# my screen size is 1024x768

# TODO: find a way to customize this without having to run xrandr,
# although
# http://askubuntu.com/questions/74808/how-do-i-force-a-resolution-of-1024x768
# suggests it's nontrivial

# TODO: make sure this is the right rate
xrandr --size 1024x768 --rate 60

# bg image won't render properly unless I do this
/home/user/BCGIT/CALENDAR/bc-calendar.pl

# CentOS defaults to emulate 3button off for some weird reason; this fixes it
# TODO: this seems kludgey, especially if I change mouses/trackballs
xinput set-prop "Logitech USB Trackball" "Evdev Middle Button Emulation" 1

# and might as well do this too (but only after fixing screen size)
/home/user/BCGIT/bc-bg2.pl

# TODO: I shouldnt have to do this at all since /etc/X11/Xresources
# already says "Xft.dpi: 96", but it turns out I do

# turning this off 21 Sep 2017, seems to harm saopaulo
# xrandr --dpi 64

# TODO: there really really must be a better way to do this

xrdb ~/.Xresources

# these can be set in xorg.conf but it's easier to do it this way
xset -dpms
xset r rate 250 25

# per
# http://unix.stackexchange.com/questions/39518/turn-off-beep-of-xorg
# there may not actually be an option for this in xorg.conf, so doing
# it here

xset b off

# not sure if the below should really be here or if I should start
# them manually...

# firefox
firefox&

# stickly digital xclock in lower right hand corner
# TODO: nanoseconds (%N doesn't work after -strftime)

xclock -norender -font -misc-fixed-bold-r-normal--14-130-75-75-c-70-iso8859-1 -padding 0 -digital -update 1 -strftime '%a %d %b %Y %H:%M:%S' -geometry 170x19+854+749 &

# pidgin
gaim -n &

# I run screen multiply (using "screen -m") and this brings up two
# xterms to run those screens in

# TODO: back when I ran rxvt instead, "-font x" yields an error but
# brings up the right font whereas not using "-font" brings up the
# "wrong" (for me font); figure out how to do this properly

xterm -geometry 80x53 +sb -bg gray45 -bd gray45 -T SCREEN -n SCREEN &
xterm -geometry 80x53 +sb -bg gray45 -bd gray45 -T "SCREEN II" -n "SCREEN II" &

# runs elinks in an extra wide rxvt to the right of the main fvwm screen

rxvt -geometry 165x52+1024+26 -T ELINKS -n ELINKS -tn vt100 -e elinks &

# it's useful to have an extra wide screen just above the main fvwm screen
rxvt -geometry 165x52+0+2339 -T WIDESCREEN -n WIDESCREEN &

# TODO: this should NOT be necessary
sudo chmod -R 777 /dev/snd/

# vidalia, like Generalisimo Francisco Franco, is still dead :(

# The exec below replaces the xinit process (which is no longer
# necessary after the above) with the fvwm2 window manager-- I think

exec fvwm2
