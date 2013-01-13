# Finally breaking up my libraries slightly

# Much of this lib was copied from my older work and is thus NOT
# well-commented/documented

our($DEGRAD)=$PI/180; # degrees to radians
our($RADDEG)=180/$PI; # radians to degrees
our($HOURRAD)=$PI/12; # hours to radians
our($RADHOUR)=12/$PI; # radians to hours
our($DEGHOUR)=1/15; # degrees to hours
our($HOURDEG)=15; # hours to degrees
our($SIDERIAL_DAY)=86400-.9856002585*240; # number of seconds in siderial day

=item radecazel2($ra, $dec, $lat, $lon, $time)

Return the azimuth and elevation of an object with right ascension $ra
and declination $dec, at latitude $lat and longitude $lon at Unix time
$time

=cut

sub radecazel2 {
  my($ra,$dec,$lat,$lon,$t)=@_;
  $ra*=$HOURRAD;
  $dec*=$DEGRAD;
  $lat*=$DEGRAD;
  $lon*=$DEGRAD;
  my($lst)=gmst($t)*$HOURRAD+$lon;
  my($ha,$az,$el)=($lst-$ra,,); 
  $az=atan2(-sin($ha)*cos($dec),cos($lat)*sin($dec)-sin($lat)*cos($dec)*cos($ha));
  $el=asin(sin($lat)*sin($dec)+cos($lat)*cos($dec)*cos($ha));
  return($az*$RADDEG,$el*$RADDEG);
}

=item objriseset($obj,$cusp,$lat,$lon,$time)

Returns time at which $obj crosses $cusp (in degrees) at $lat,$lon
near $time

=cut

sub objriseset {
  my($obj,$cusp,$lat,$lon,$time)=@_;
  my($aa,$ab,$ac,$ad,$ae,$af,$ag,$ah,$ai,$aj,$ak,$al,$am,$an,$ao,$xx);
  ($aa,$ab)=radecplan($time,$obj);
  ($xx,$af)=radecazel2($aa,$ab,$lat,$lon,$time);
  $an=gmst($time)+$lon*$DEGHOUR;

  # find zenith/nadir depending on if object is up
  
  if ($af>$cusp) {
    $ao=mod($aa-$an,$SIDERIAL_DAY/3600);
    $ae=1; # found zenith
  } else {
    $ao=mod($aa-$an-$SIDERIAL_DAY/7200,$SIDERIAL_DAY/3600);
    $ae=-1; # found nadir
  }
  
  # find nearest zenith/nadir
  if ($ao>$SIDERIAL_DAY/7200) {$ao-=$SIDERIAL_DAY/3600;}

  $ah=$time+$ao*$SIDERIAL_DAY/24; # zenith/nadir time
  $ai=$time+$ao*$SIDERIAL_DAY/24-$SIDERIAL_DAY/2; # last nadir/zenith
  $al=$time+$ao*$SIDERIAL_DAY/24+$SIDERIAL_DAY/2; # next nadir/zenith
  
  ($xx,$ad)=radecazel2($aa,$ab,$lat,$lon,$ah);
  ($xx,$ag)=radecazel2($aa,$ab,$lat,$lon,$ai);

  # on the fly function to nullify
  $aj= sub {
    my($ba)=@_;
    my($bd,$be)=radecplan($ba,$obj);
    my($bb,$bc)=radecazel2($bd,$be,$lat,$lon,$ba);
    return($bc-$cusp);
  };

  if ($ad<$cusp && $ag<$cusp) {return(-1,-1,0);} # always down
  if ($ad>$cusp && $ag>$cusp) {return(1,1,1);} # always up
  
  $ak=findroot($aj,$ah,$ai,.005,500);
  $am=findroot($aj,$ah,$al,.005,500);
  if ($ae==1) {
    return($ak,$am,($af>$cusp));
  } else {
    return($am,$ak,($af>$cusp));
  }
}

=item mod($x,$y)

Mod function with remainder

=cut

sub mod {
  my($x,$y)=@_;
  return($x-$y*floor($x/$y));
}

=item radec($N,$i,$w,$a,$e,$M,$rs,$lonsun)

Compute RA/DEC and the ecliptic longitude and latitude given orbital
elements for any planet or moon (but not sun); for moon rs=lonsun=0

N = longitude of the ascending node
i = inclination to the ecliptic (plane of the Earth's orbit)
w = argument of perihelion
a = semi-major axis, or mean distance from Sun
e = eccentricity (0=circle, 0-1=ellipse, 1=parabola)
M = mean anomaly (0 at perihelion; increases uniformly with time)
E = eccentric anomaly

=cut

sub radec {
    my($N,$i,$w,$a,$e,$M,$rs,$lonsun)=@_;
    $E =$M+$e*sin($M)*(1+$e*cos($M));
    # skipping recursive routine to calculate $E more accurately
    $xv=$a*(cos($E)-$e);
    $yv=$a*(sqrt(1-$e*$e)*sin($E));
    $v=atan2($yv,$xv);
    $r=sqrt($xv*$xv+$yv*$yv);

    $xh=$r*(cos($N)*cos($v+$w)-sin($N)*sin($v+$w)*cos($i));
    $yh=$r*(sin($N)*cos($v+$w)+cos($N)*sin($v+$w)*cos($i));
    $zh=$r*(sin($v+$w)*sin($i));
    
    $lonecl=atan2($yh,$xh);
    $latecl=atan2($zh,sqrt($xh*$xh+$yh*$yh));
    
    $xs=$rs*cos($lonsun);
    $ys=$rs*sin($lonsun);

    $xg=$xh+$xs;
    $yg=$yh+$ys;
    $zg=$zh;

    $xe=$xg;
    $ye=$yg*cos($ECL)-$zg*sin($ECL);
    $ze=$yg*sin($ECL)+$zg*cos($ECL);

    $RA=atan2($ye,$xe);
    $DEC=atan2($ze,sqrt($xe*$xe+$ye*$ye));
    
    return(normalize($RA),$DEC,$lonecl,$latecl);
}

=item radecsun($t)

Returns RA/DEC/rs/lonsun for Sun, and GMST, given Unix time t

DO NOT USE, CONTAINS ERRORS

=cut

sub radecsun {
  die("Use position() instead");
    my($t)=@_;
    my($d)=epochdays($t);
    my($N,$i,$w,$a,$e,$M)=(0,0,282.9404*$PI/180,1,.016709,356.0470+.9856002585*$d);
    $M=$M*$PI/180;
    $E =$M+$e*sin($M)*(1+$e*cos($M));

    $xv=$a*(cos($E)-$e);
    $yv=$a*(sqrt(1-$e*$e)*sin($E));
    $v=atan2($yv,$xv);
    $r=sqrt($xv*$xv+$yv*$yv);
    $rs=$r;
    $lonsun=$v+$w;

    $xs=$rs*cos($lonsun);
    $ys=$rs*sin($lonsun);

    $xe=$xs;
    $ye=$ys*cos($ECL);
    $ze=$ys*sin($ECL);

    my($RA)=atan2($ye,$xe);
    my($DEC)=atan2($ze,sqrt($xe*$xe+$ye*$ye));

    my($GMST)=$M+$w+$PI+($t%86400)/43200*$PI;

    return(normalize($RA),$DEC,$rs,$lonsun,$GMST);
    
}

=item epochdays($t)

The number of days since 12/31/1999 0h UT, which is the epoch for most
calculations in this lib

=cut

sub epochdays {
    my($t)=@_;
    return(($t-10956*86400)/86400);
}

=item lst($gmst,$long)

Calculate the local siderial time from GMST and longitude

=cut

sub lst {
  die("BROKEN");
  my($gmst,$long) = @_;
  return $gmst+$long;
}

=item radecazel($ra,$dec,$lst,$lat)

converts RA/DEC->AZ/EL given LST/LAT

=cut

sub radecazel {
    my($ra,$dec,$lst,$lat,$ha,$az,$el)=@_;
    $ha=$lst-$ra;
    $az=atan2(-sin($ha)*cos($dec),cos($lat)*sin($dec)-sin($lat)*cos($dec)*cos($ha));
    $el=asin(sin($lat)*sin($dec)+cos($lat)*cos($dec)*cos($ha));
    return($az,$el);
}


=item asin($x)

The arcsin of x

=cut

sub asin {
  my($x) = @_;
  return atan2($x,sqrt(1-$x*$x));
}

=item acos($x)

The arccos of x

=cut

sub acos {
  my($x) = @_;
  return atan2(sqrt(1-$x*$x),$x);
}

=item orbelts($planet,$time)

Return the orbital elements of $planet for time $time (from the
now-dead http://hotel04.ausys.se/pausch/comp/ppcomp.html)

Return values:

0: mean angular motion (degrees/day)         [JPL: N]
1: mean anomaly at the epoch (degrees)       [JPL: MA]
2: argument of the perihelion (degrees)      [JPL: W]
3: eccentriciy of orbit                      [JPL: EC]
4: length of semimajor axis (AU)             [JPL: A]
5: inclination of orbit (degrees)            [JPL: IN]
6: longitude of the ascending node (degrees) [JPL: OM] 
7: angular diameter at 1 AU (seconds of arc) [NOT YET WORKING]
8: magnitude at 1 AU                         [NOT YET WORKING]
9: Unix timestamp value of the epoch [for element 1]
Note #2 == angular distance between the ascending node + perihelion

=cut

sub orbelts {
    my($planet,$time)=@_;
    debug("orbelt($planet,$time)");
    $planet=lc($planet);
    my(@temp);
    $EPOCHTIME=datestar("19991231");
    my($d)=($time-$EPOCHTIME)/86400;
    
    if ($planet eq "sun") {
	return();
    } elsif ($planet eq "mercury") {
	@temp=(48.3313+3.24587E-5*$d,7.0047+5.00E-8*$d,29.1241+1.01444E-5*$d,0.387098,0.205635+5.59E-10*$d,168.6562,4.0923344368);
    } elsif ($planet eq "venus") {
	@temp=(76.6799+2.46590E-5*$d,3.3946+2.75E-8*$d,54.8910+1.38374E-5*$d,0.723330,0.006773-1.302E-9*$d,48.0052,1.6021302244);
    } elsif ($planet eq "earth") {
	@temp=(0.0,0.0,
	       282.9404+4.70935E-5*$d-180, # -180 corrects for Earth/Sun flip
	       1.000000,0.016709-1.151E-9*$d,356.0470,0.9856002585);
    } elsif ($planet eq "mars") {
	@temp=(49.5574+2.11081E-5*$d,1.8497-1.78E-8*$d,286.5016+2.92961E-5*$d,1.523688,0.093405+2.516E-9*$d,18.6021,0.5240207766);
    } elsif ($planet eq "jupiter") {
	@temp=(100.4542+2.76854E-5*$d,1.3030-1.557E-7*$d,273.8777+1.64505E-5*$d,5.20256,0.048498+4.469E-9*$d,19.8950,0.0830853001);
    } elsif ($planet eq "saturn") {
	@temp=(113.6634+2.38980E-5*$d,2.4886-1.081E-7*$d,339.3939+2.97661E-5*$d,9.55475,0.055546-9.499E-9*$d,316.9670,0.0334442282);
    } elsif ($planet eq "uranus") {
	@temp=(74.0005+1.3978E-5*$d,0.7733+1.9E-8*$d,96.6612+3.0565E-5*$d,19.18171-1.55E-8*$d,0.047318+7.45E-9*$d,142.5905,0.011725806);
    } elsif ($planet eq "neptune") {
	@temp=(131.7806+3.0173E-5*$d,1.7700-2.55E-7*$d,272.8461-6.027E-6*$d,30.05826+3.313E-8*$d,0.008606+2.15E-9*$d,260.2471,0.005995147);
    } elsif ($planet eq "pluto") {
      return "Yes, I am a planet!";
    } else {
	warn("$planet INVALID");
    }
    my(@retval)=(schlytercorrect(@temp),0,0,$EPOCHTIME);
    return(@retval);
}

=item schlytercorrect($N,$i,$w,$a,$e,$M1,$M2)

Given the osculating elements, return them in a more useful (for this
library) format.

=cut

sub schlytercorrect {
    my($N,$i,$w,$a,$e,$M1,$M2)=@_;
    if ($M2==0) {die("Bad elements, M2=0");}
    return($M2,$M1,$w,$e,$a,$i,$N);
}

=item xyzplan($t,$N,$MA,$W,$EC,$A,$IN,$OM,$ig1,$ig2,$epoch)

Given a planets orbital elements, returns its XYZ position ($ig1,$ig2
are passed but ignored). XYZ plane:

Origin = Sun
X-axis = towards first point of Aries
XY-plane: plane of the ecliptic

=cut

sub xyzplan {
    my($time,$N,$MA,$W,$EC,$A,$IN,$OM,$ig1,$ig2,$epoch)=@_;
    $a1=$MA+($time-$epoch)/86400*$N; # current mean anomaly (degrees)
    $a1=normalize($a1);
    $a2=kepler($a1,$EC); # current true anamoly (degrees)
    $a3=$A*(1-$EC*$EC)/(1+$EC*cos($a2*$DEGRAD)); # heliocentric distance
    @a4=sph2xyz($a2,0,$a3,1); # Cartesian coordinates in planets frame
    @a4=promote(@a4);

    @rot1=rotdeg($W,"z"); # rotate perihelion/ascending node
    @rot2=rotdeg(-$IN,"x"); # rotate for inclination
    @rot3=rotdeg($OM,"z"); # rotate for long ascending node
    @res1=matrixmult(\@rot1,\@a4);
    @res2=matrixmult(\@rot2,\@res1);
    @res3=matrixmult(\@rot3,\@res2);
    return(@res3);
}

=item xyzmoon($t)

Return the moon's XYZ coordinates (in the Earth's reference frame) at time $t

=cut

sub xyzmoon {
    my($time)=@_;
    $EPOCHTIME=datestar("19991231");
    my($d)=($time-$EPOCHTIME)/86400;

    my(@temp)= schlytercorrect(125.1228-0.0529538083*$d,5.1454,318.0634+0.1643573223*$d,60.2666,0.054900,115.3654,13.0649929509);

    my($N,$MA,$W,$EC,$A,$IN,$OM,$ig1,$ig2,$epoch)=(@temp,0,0,$EPOCHTIME);

    $a1=$MA+($time-$epoch)/86400*$N; # current mean anomaly (degrees)
    $a2=kepler($a1,$EC); # current true anamoly (degrees)
    $a3=$A*(1-$EC*$EC)/(1+$EC*cos($a2*$DEGRAD)); # geocentric distance
    @a4=sph2xyz($a2,0,$a3,1); # Cartesian coordinates in lunar frame
    @a4=promote(@a4);

    @rot1=rotdeg($W,"z"); # rotate perihelion/ascending node
    @rot2=rotdeg(-$IN,"x"); # rotate for inclination
    @rot3=rotdeg($OM,"z"); # rotate for long ascending node
    @res1=matrixmult(\@rot1,\@a4);
    @res2=matrixmult(\@rot2,\@res1);
    @res3=matrixmult(\@rot3,\@res2);
    return(flatten(@res3));
}

=item xyzplanear($t,$planet)

Returns the XYZ coordinates of $planet wrt Earth at time $t

origin= Earth, x-axis = first point of Aries, xy-plan = ecliptic

=cut

sub xyzplanear {
    my($time,$planet)=@_;
    debug("XYZPLANEAR($time,$planet) called");
    $planet=lc($planet);
    if ($planet eq "moon") {return(xyzmoon($time));}

    my(@plan);

    if ($planet eq "sun") {
	@plan=(0,0,0);
    } else {
      debug("CALLING: orbelts($planet,$time)");
	@plan=flatten(xyzplan($time,orbelts($planet,$time)));
    }

    my(@eart)=flatten(xyzplan($time,orbelts("earth",$time)));
    my(@res)=vecminus(\@plan,\@eart);
    return(@res);
}

=item radecplan($t,$planet)

RA and DEC of $planet at time $t

=cut

sub radecplan {
    my($time,$planet)=@_;
    my(@pos)=xyzplanear($time,$planet);
    my(@eq)=equecl($time);
    @pos=promote(@pos);
    my(@res)=matrixmult(\@eq,\@pos);
    my(@sph)=xyz2sph(flatten(@res),1);
    return($sph[0]/15,$sph[1]);
}

=item promote(@l)

Convert a 1-D list @list to a 2-D list by adding [0] to each element

=cut

sub promote {
    my(@l)=@_;
    my(@ans);
    for $i (0..$#l) {
	$ans[$i][0]=$l[$i];
    }
    return(@ans);
}

=item flatten(@l)

Convert a 2D list @l to 1D by returning the first (0th) element of each list

=cut

sub flatten {
    my(@l)=@_;
    my(@ans);
    for $i (0..$#l) {
	$ans[$i]=$l[$i][0];
    }
    return(@ans);
}

=item vecminus(\@x, \@y)

Perform vector subtraction

=cut

sub vecminus {
    my($x,$y)=@_;
    my(@x)=@$x;
    my(@y)=@$y;
    my(@ans);
    
    for $i (0..$#x) {
	$ans[$i]=$x[$i]-$y[$i];
    }

    return(@ans);
}

=item veclen(@x)

Return the length of vector @x

=cut

sub veclen {
    my(@a)=@_;
    my($res)=0;
    for $i (@a) {$res+=$i*$i;}
    return(sqrt($res));
}

=item equecl($t)

The matrix that converts ecliptic coordinates to equitorial
coordinates at time t

=cut

sub equecl {
    my($t)=@_;
    my($d)=($t-datestar("19991231"))/86400;
    my(@res)=rotdeg(-(23.4393-3.563E-7*$d),"x");
    return(@res);
}

=item angdist($ra1,$dec1,$ra2,$dec2)

The angular distance between a pair of RAs/DECs

=cut

sub angdist {
    my($ra1,$dec1,$ra2,$dec2)=@_;
    my(@a1)=sph2xyz($ra1*15,$dec1,1,1);
    my(@a2)=sph2xyz($ra2*15,$dec2,1,1);
    my(@a3)=vecminus(\@a1,\@a2);
    return(2*asin(veclen(@a3)/2)/$DEGRAD);
}

=item nicera($theta)

Pretty prints the right ascension corresponding to $theta

=cut

sub nicera {
    my($th)=@_;
    $th=normalize($th);
    my($ho)=int($th/$PI*12);
    $th-=$ho*$PI/12;
    my($mi)=int($th/$PI*12*60);
    $th-=$mi*$PI/12/60;
    my($se)=int($th/$PI*12*60*60);
    return(sprintf("%0.2dh%0.2dm%0.2ds",$ho,$mi,$se));
}

=item nicedec($theta)

Pretty prints the declination corresponding to $theta

=cut

sub nicedec {
    my($th)=@_;
    $th=normalize($th);
    if ($th>$PI) {$th-=2*$PI;}
    my($de)=int($th/$PI*180);
    $th-=$de*$PI/180;
    my($mi)=int($th/$PI*180*60);
    $th-=$mi*$PI/180/60;
    my($se)=int($th/$PI*180*60*60);
    return("${de}^${mi}\'${se}\"");
}

=item nicedeg($theta, $supsec)

Pretty prints the degree corresponding to $theta.

If $supsec set, don't include seconds of arc.

=cut

sub nicedeg {
    my($th,$supsec)=@_;
    $th=normalize($th);
    if ($th>$PI) {$th-=2*$PI;}
    if ($supsec) {$th+=$PI/21600;} # round to nearest minute
    my($de)=int($th/$PI*180);
    $th-=$de*$PI/180;
    my($mi)=int($th/$PI*180*60);
    $th-=$mi*$PI/180/60;
    my($se)=int($th/$PI*180*60*60);
    $mi=abs($mi);
    $se=abs($se);
    if ($supsec) {
	return(sprintf("%d\xB0%0.2d\'",$de,$mi));
    } else {
	return(sprintf("%d\xB0%0.2d\'%0.2d\"",$de,$mi,$se));
    }
}

=item niceday($n)

Returns the number of days/hours/minutes/seconds in $n seconds, prettyprint

=cut

sub niceday {
    my($n)=@_;
    my($da)=int($n/86400);
    $n=$n-86400*$da;
    my($ho)=int($n/3600);
    $n=$n-3600*$ho;
    my($mi)=int($n/60);
    $n=$n-60*$mi;
    my($se)=$n;
    return(sprintf("%dd %0.2dh %0.2dm %0.2ds",$da,$ho,$mi,$se));
}

=item normalize($theta)

Returns the angle equal to theta, but between 0 and 2*PI

=cut

sub normalize {
    my($th)=@_;
    $ret=($th/2/$PI-int($th/2/$PI))*2*$PI;
    if ($ret<0) {$ret+=2*$PI;}
    return($ret);
}

=item gmst($t=now)

The Greenwich siderial time at time $t

=cut

sub gmst {
  die "Use bclib.pl version instead";
  my($t)=@_;
  unless ($t) {$t=time();}

  # from http://en.wikipedia.org/wiki/Sidereal_time
#  my($res) = 18.697374558 + 24.06570982441908*($t-$MILLSEC,

  # i have no idea where I got this formula, but it's wrong
  my($aa)=6.59916+.9856002585*($t-$MILLSEC)/86400/15+($t%86400)/3600;
  return(24*($aa/24-int($aa/24)));
}


=item kepler($M,$e)

Given mean anomaly $M in degrees and eccentricity $e, return
correction true anomaly in degrees

=cut

sub kepler {
    my($M,$e)=@_;
    my($coderef)= sub {return($_[0]-$e*sin($_[0])-$M*$DEGRAD)};
    my($sol)=findroot($coderef,0,2*$M*$DEGRAD,1e-6);
    my($retval)=2*atan2(sqrt((1+$e)/(1-$e))*tan($sol/2),1)/$DEGRAD;
    if ($retval<0) {$retval+=360;}
    return($retval);
}

=item sph2xyz($theta,$phi,$r,$deg)

Converts spherical coordinates to xyz; if $deg, coordinates are in degrees

=cut

sub sph2xyz {
    my($th,$ph,$r,$deg)=@_;
    if ($deg) {$th=$th*$DEGRAD; $ph=$ph*$DEGRAD;}
    return($r*cos($ph)*cos($th),$r*cos($ph)*sin($th),$r*sin($ph));
}

1;
