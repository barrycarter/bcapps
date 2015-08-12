# compute distance from ecliptic of visible stars (with goal of
# finding closest ones)

# perl -anle 'use POSIX;chomp; if ($F[2]<=5.50) {print 23.4*sin($F[1]/3*atan(1))-$F[0]," $_"}' bright-star-catalog.txt | sort -k1n

# TODO: this is not exact, it measures declination distance only;
# measuring perpendicular would be more accurate (and give smaller
# distances)

perl -anle 'use POSIX;chomp; if ($F[2]<=3.50) {print 23.4*sin($F[1]/3*atan(1))-$F[0]," $_"}' bright-star-catalog.txt | sort -k1n

# perl -anle 'use POSIX;chomp; print $_," ",23.4*sin($F[0]/3*atan(1))-$F[1]' radecmag.asc | sort -k4n

exit;
