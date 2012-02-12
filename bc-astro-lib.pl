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

=item radec2azel($ra, $dec, $lat, $lon, $time)

Given the azimuth and elevation of an object with right ascension $ra
and declination $dec, at latitude $lat and longitude $lon at Unix time
$time

=cut

sub radec2azel {
  my($ra, $dec, $lat, $lon, $time) = @_;
  unless ($time) {$time=time();}

  # convert ra/dec, lat to radians (not lon)
  $ra *= $PI/12;
  $dec *= $PI/180;
  $lat *= $PI/180;

  # determine local siderial time (in hours)
  my($lst) = gmst($time) + $lon/15;

  # determine 'hour angle' (time since last culmination?) in radians
  my($ha) = $lst*$PI/12-$ra;

  # and now azimuth and elevation
  my($az)=atan2(-sin($ha)*cos($dec),cos($lat)*sin($dec)-sin($lat)*cos($dec)*cos($ha));
  my($el)=asin(sin($lat)*sin($dec)+cos($lat)*cos($dec)*cos($ha));

  # convert back to degrees
  return ($az*180/$PI,$el*180/$PI);
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

=cut

sub radecsun {
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

=item orbelts($planet,$t)

Return the orbital elements of $planet for time $t (the orbital
elements of the planets aren't quite fixed)

<h>Does not return orbital elements of Pluto for technical reasons,
but I maintain Pluto is still a planet</h>

=cut

sub orbelts {
    my($planet,$t)=@_;
    my($d)=epochdays($t);
    
    if ($planet eq "MOON") {
	return(fixelts(125.1228-0.0529538083*$d,5.1454,318.0634+0.1643573223*$d,60.2666,.054900,115.3654+13.0649929509*$d));
    }
    
    if ($planet eq "MERCURY") {
	return(fixelts(48.3313,7.0047,29.1241,.387098,.205635,168.6562+4.0923344368*$d));
    }

    if ($planet eq "VENUS") {
	return(fixelts(76.6799,3.3946,54.8910,0.723330,0.006773,48.0052+1.6021302244*$d));
    }

    if ($planet eq "MARS") {
	return(fixelts(49.5574,1.8497,286.5016,1.523688,0.093405,18.6021+0.5240207766*$d));
    }

    if ($planet eq "JUPITER") {
	return(fixelts(100.4542,1.3030,273.8777,5.20256,0.048498,19.8950+0.0830853001*$d));
    }

    if ($planet eq "SATURN") {
	return(fixelts(113.6634,2.4886,339.3939,9.55475,0.055546,316.9670+0.0334442282*$d));
    }

    if ($planet eq "URANUS") {
	return(fixelts(74.0005,0.7733,96.6612,19.18171,0.047318,142.5905+0.011725806*$d));
    }

    if ($planet eq "NEPTUNE") {
	return(fixelts(131.7806,1.7700,272.8461,30.05826,0.008606,260.2471+0.005995147*$d));
    }
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

=item fixelts($N,$i,$w,$a,$e,$M)

Converts orbital elements in degrees to radians (the source I used,
http://hotel04.ausys.se/pausch/comp/ppcomp.html, now gone, had these
in degrees I think)

=cut

sub fixelts {
    my($N,$i,$w,$a,$e,$M)=@_;
    $N*=$PI/180;
    $i*=$PI/180;
    $w*=$PI/180;
    $M*=$PI/180;
    return($N,$i,$w,$a,$e,$M);
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

=item rotrad($th, $ax="x|y|z")

The 3D matrix that rotates $th radians around the $ax axis

=cut

sub rotrad {
    my($th,$ax)=@_;
    my($si,$co)=(sin($th),cos($th));
    if ($ax eq "x") {return(([1,0,0],[0,$co,$si],[0,-$si,$co]));}
    if ($ax eq "y") {return(([$co,0,-$si],[0,1,0],[$si,0,$co]));}
    if ($ax eq "z") {return(([$co,-$si,0],[$si,$co,0],[0,0,1]));}
}

=item rotdeg($th, $ax="x|y|z")

Does exactly what rotrad does, but $theta is given in degrees

=cut

sub rotdeg {
    my($th,$ax)=@_;
    return(rotrad($th*$PI/180,$ax));
}

=item xyz2sph($x,$y,$z,$deg)

Converts $x,$y,$z to spherical coordinates th,phi,r, in radians
(unless $deg set, in which case returns degrees)

=cut

sub xyz2sph {
    my($x,$y,$z,$deg)=@_;
    my(@ret)=(atan2($y,$x),atan2($z,sqrt($x*$x+$y*$y)),sqrt($x*$x+$y*$y+$z*$z));
    if ($ret[0]<0) {$ret[0]+=2*$PI;}
    if ($deg) {$ret[0]/=$DEGRAD; $ret[1]/=$DEGRAD;}
    return(@ret);
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
