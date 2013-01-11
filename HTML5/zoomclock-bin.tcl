#!/usr/local/bin/wish

# Sample application that uses zoomer.tcl
source /home/barrycarter/BCGIT/HTML5/zoomer.tcl

eval destroy [winfo children .]
button .b -text "EXIT" -command {exit}
button .re -text "RELOAD" -command {exec zoomclock.tcl &; destroy .}
pack .b .re

set PI [expr 4.*atan(1.0)]
makepad .p 700 -bg grey
bindpad .p

set PI [expr 4*atan(1)]
set cols "red orange yellow green blue blue violet violet violet"
set cir "1 4 16 64 256 1024 4096 16384 65536 262144 1048576"
set size "0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1"
set thick "0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01"

set face [eval .p create oval [ptsc -.9 -.9] [ptsc .9 .9] -fill cyan]

for {set i 1} {$i<13} {incr i} {
    set an [expr $PI/2-$PI/6*$i]
    eval .p create text [ptsc [expr cos($an)] [expr sin($an)]] \
            -text $i -fill red
}

for {set i 0} {$i<[llength $cols]} {incr i} {
    set h($i) [eval .p create line 0 0 0 0 -fill [lindex $cols $i] \
		   -width [expr [lindex $thick $i]*100]]
}

proc renderclock {t} {
    global cols cir size thick h PI face
    for {set i 0} {$i<[llength $cols]} {incr i} {
        set an [expr $PI/2-2*$PI*$t/[lindex $cir $i]]
        eval .p coords $h($i) [ptsc 0 0] [ptsc \
					      [expr [lindex $size $i]*cos($an)] \
					      [expr [lindex $size $i]*sin($an)]]
    }
    set fco [expr int(128-127*cos(2*$PI*$t/86400))]
    .p itemconfigure $face -fill [format "\#%2.2x%2.2x%2.2x" 0 $fco $fco]
    update
    after 1 "renderclock [expr ([clock microseconds]/1000000.+3600)]"
}

renderclock [expr [clock seconds]%86400-3600*6]
