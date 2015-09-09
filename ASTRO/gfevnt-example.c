#include "SpiceUsr.h"
#include "SpiceGF.h"
#include <stdio.h>
#include <signal.h>

int main() {

#define TIMFMT "YYYY-MON-DD HR:MN:SC.###### (TDB) ::TDB ::RND"
#define MAXVAL 10000
#define STRSIZ 41
#define LNSIZE 81
#define MAXPAR 10

  SpiceBoolean bail;
  SpiceBoolean rpt;

  SpiceChar begstr [LNSIZE] = "2001 jan 01 00:00:00.000";
  SpiceChar endstr [LNSIZE] = "2001 dec 31 00:00:00.000";
  SpiceChar event [] = "DISTANCE";
  SpiceChar relate [] = "LOCMAX";

 
  SpiceChar qpnams[SPICE_GFEVNT_MAXPAR][LNSIZE]={"TARGET","OBSERVER","ABCORR"};
  SpiceChar qcpars[SPICE_GFEVNT_MAXPAR][LNSIZE] = {"MOON","EARTH","LT+S"};
  SpiceDouble qdpars[SPICE_GFEVNT_MAXPAR];
  SpiceInt qipars[SPICE_GFEVNT_MAXPAR];
  SpiceBoolean qlpars[SPICE_GFEVNT_MAXPAR];
 

  SPICEDOUBLE_CELL ( cnfine, MAXVAL );
  SPICEDOUBLE_CELL ( result, MAXVAL );

  SpiceDouble begtim,endtim,step,refval,adjust,tol,beg,end;
  SpiceInt lenvals,nintvls,count,qnpars,i;

 furnsh_c ( "standard.tm" );

 str2et_c ( begstr, &begtim );
 str2et_c ( endstr, &endtim );


 wninsd_c ( begtim, endtim, &cnfine );


 count = wncard_c( &cnfine );
 printf( "Found %ld intervals in cnfine\n", count );

 
 step = 0.001 * spd_c();
 gfsstp_c ( step );


 bail = SPICETRUE;
 rpt = SPICETRUE;
 
 lenvals= LNSIZE;
 qnpars = 3;
 tol = SPICE_GF_CNVTOL;
 refval = 0.;
 adjust = 0.;
 nintvls= MAXVAL;

 gfevnt_c ( gfstep_c,
	 gfrefn_c,
	 event,
	 qnpars,
	 lenvals,
	 qpnams,
	 qcpars,
	 qdpars,
	 qipars,
	 qlpars,
	 relate,
	 refval,
	 tol,
	 adjust,
	 rpt,
	 &gfrepi_c,
	 gfrepu_c,
	 gfrepf_c,
	 nintvls,
	 bail,
	 gfbail_c,
	 &cnfine,
	 &result );

 if ( gfbail_c() ) 
 {
 gfclrh_c();

 printf ( "\nSearch was interrupted.\n\nThis message "
	 "was written after an interrupt signal\n"
	 "was trapped. By default, the program "
	 "would have terminated \nbefore this message "
	 "could be written.\n\n" );
 }
 else
	 {
	 count = wncard_c( &result);
	 printf( "Found %ld intervals in result\n", count );

	 for( i=0; i<count; i++ )
 {
		 wnfetd_c( &result, i, &beg, &end );
		 
		 timout_c ( beg, TIMFMT, LNSIZE, begstr );
		 timout_c ( end, TIMFMT, LNSIZE, endstr );
		 
		 printf( "Interval %ld\n", i );
		 printf( "Beginning TDB %s\n", begstr );
		 printf( "Ending TDB %s\n", endstr );
 }
	 }
 return (0);
}
