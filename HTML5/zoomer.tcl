# This is the TCL/TK program I wrote in 1992 that I am converting to HTML5

set _PAD(ZU) 10
set _PAD(ZFO,0) [expr 1+.002*$_PAD(ZU)]
set _PAD(ZFO,1) [expr 1+.01*$_PAD(ZU)]
set _PAD(ZF) $_PAD(ZFO,0)

#Make a square pad
proc makepad {path dim args} {
    global _PAD
    eval canvas $path -height $dim -width $dim $args; pack $path
    set _PAD(Z) [set _PAD(Y) [set _PAD(X) [set _PAD(SF) [expr $dim/2.]]]]
}

#PTSC: Pad to screen coordinates
proc ptsc {x y} {
    global _PAD;
    return "[expr $x*$_PAD(Z)+$_PAD(X)] [expr -$y*$_PAD(Z)+$_PAD(Y)]"
}

#STPC: screen to Pad coords
proc stpc {x y} {
    global _PAD;
    return "[expr ($x-$_PAD(X))/$_PAD(Z)] [expr ($_PAD(Y)-$y)/$_PAD(Z)]"
}

#Zoom: perform a zoom around padpoint (x,y) with a zoom factor of z
proc zoom {path x y z} {
    global _PAD
    set temp [ptsc $x $y]; set x [lindex $temp 0]; set y [lindex $temp 1]
    $path scale all $x $y $z $z; set _PAD(Z) [expr $_PAD(Z)*$z]
    set _PAD(X) [expr $x+$z*($_PAD(X)-$x)]
    set _PAD(Y) [expr $y+$z*($_PAD(Y)-$y)]
}

#Move: move (x,y)
proc move {x y path} {
    global _PAD
    $path move all [expr $x*($_PAD(Z)/$_PAD(SF))] \
	[expr $y*($_PAD(Z)/$_PAD(SF))]
    set _PAD(X) [expr $_PAD(X)+1.*$x*$_PAD(Z)/$_PAD(SF)]
    set _PAD(Y) [expr $_PAD(Y)+1.*$y*$_PAD(Z)/$_PAD(SF)]
}

proc holdzoom {zf path} {
    global _PAD zx zy
    if {$zx} {
        eval zoom $path [stpc $zx $zy] $zf;update;
        after $_PAD(ZU) "holdzoom $zf $path"
    }
}

proc holdmove {x y path} {
    global _PAD oldx oldy
    move [expr ($_PAD(SF)/$_PAD(Z))*($x-$oldx)] \
	[expr ($_PAD(SF)/$_PAD(Z))*($y-$oldy)] $path
    set oldx $x; set oldy $y
}

proc makerect {path x0 y0 x1 y1 args} {
    eval $path create rectangle [ptsc $x0 $y0] [ptsc $x1 $y1] $args
}

proc bindpad {path} {
global _PAD
    bind $path <ButtonPress-2> "set zx %x; set zy %y; holdzoom $_PAD(ZF) $path"
bind $path <ButtonPress-3> \
    "set zx %x; set zy %y; holdzoom [expr 1./$_PAD(ZF)] $path"
    bind $path <ButtonRelease-2> {set zx 0}
    bind $path <ButtonRelease-3> {set zx 0}
    bind $path <B2-Motion> {set zx %x; set zy %y}
    bind $path <B3-Motion> {set zx %x; set zy %y}
bind $path <B1-Motion> "holdmove %X %Y $path"
    bind $path <ButtonPress-1> {set oldx %X; set oldy %Y}

#Alternate bindings for Macs/etc
bind $path <Shift-ButtonPress-1> \
    "set zx %x; set zy %y; holdzoom {$_PAD(ZF)} $path"
bind $path <Control-ButtonPress-1> \
    "set zx %x; set zy %y; holdzoom {$_PAD(ZF)} $path"
    bind $path <ButtonRelease-1> {set z 0}
}
