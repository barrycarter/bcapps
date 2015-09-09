      #include "SpiceUsr.h"
      #include "SpiceGF.h"
      #include <stdio.h>
      #include <signal.h>

int main()
{

         /.
         Constants
         ./
         #define  TIMFMT  "YYYY-MON-DD HR:MN:SC.###### (TDB) ::TDB ::RND"
         #define  MAXVAL  10000
         #define  STRSIZ  41
         #define  LNSIZE  81
         #define  MAXPAR  10

         /.
         Local variables 
         ./
	   SpiceBoolean            bail;
         SpiceBoolean            rpt;

         /.
         Confining window beginning and ending time strings.
         ./
	   SpiceChar               begstr [LNSIZE] = "2001 jan 01 00:00:00.000";
         SpiceChar               endstr [LNSIZE] = "2001 dec 31 00:00:00.000";
         SpiceChar               event  []       = "DISTANCE";
         SpiceChar               relate []       = "LOCMAX";

         
         /.
         Declare qpnams and qcpars with the same dimensions.
         SPICE_GFEVNT_MAXPAR defined in SpiceGF.h.
         ./
	   SpiceChar  qpnams[SPICE_GFEVNT_MAXPAR][LNSIZE] = { "TARGET",
							      "OBSERVER",
							      "ABCORR" };

         SpiceChar  qcpars[SPICE_GFEVNT_MAXPAR][LNSIZE] = { "MOON", 
                                                            "EARTH", 
                                                            "LT+S" };

         SpiceDouble             qdpars[SPICE_GFEVNT_MAXPAR];
         SpiceInt                qipars[SPICE_GFEVNT_MAXPAR];
         SpiceBoolean            qlpars[SPICE_GFEVNT_MAXPAR];
 

         SPICEDOUBLE_CELL      ( cnfine, MAXVAL );
         SPICEDOUBLE_CELL      ( result, MAXVAL );

         SpiceDouble             begtim;
         SpiceDouble             endtim;
         SpiceDouble             step;
         SpiceDouble             refval;
         SpiceDouble             adjust;
         SpiceDouble             tol;
         SpiceDouble             beg;
         SpiceDouble             end;


         SpiceInt                lenvals;
         SpiceInt                nintvls;
         SpiceInt                count;
         SpiceInt                qnpars;
         SpiceInt                i;


         /.
         Load leapsecond and spk kernels. The name of the 
	   meta kernel file shown here is fictitious; you 
         must supply the name of a file available 
         on your own computer system.
         ./
							furnsh_c ( "standard.tm" );

         /.
         Set a beginning and end time for confining window.
         ./

	   str2et_c ( begstr, &begtim );
         str2et_c ( endstr, &endtim );


         /.
         Add 2 points to the confinement interval window.
         ./
	   wninsd_c ( begtim, endtim, &cnfine );


         /.
         Check the number of intervals in confining window.
         ./
	   count = wncard_c( &cnfine );
         printf( "Found %ld intervals in cnfine\n", count );

      
         /.
         Set the step size to 1/1000 day and convert to seconds.
         One day would be a reasonable stepsize for this
	   search, but the run would not last long enough to issue
         an interrupt.
         ./
	     step = 0.001 * spd_c();
         gfsstp_c ( step );


         /.
         Set interrupt handling and progress reporting.
         ./
	   bail = SPICETRUE;
         rpt  = SPICETRUE;
            
         lenvals= LNSIZE;
         qnpars = 3;
         tol    = SPICE_GF_CNVTOL;
         refval = 0.;
         adjust = 0.;
         nintvls= MAXVAL;

         /.
         Perform the search.
         ./
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
            /.
            Clear the CSPICE interrupt indication. This is
            an essential step for programs that continue
	      running after an interrupt; gfbail_c will
            continue to return SPICETRUE until this step
            has been performed.
            ./
					    gfclrh_c();


            /.
            We've trapped an interrupt signal. In a realistic
            application, the program would continue operation
            from this point. In this simple example, we simply
            display a message and quit.
            ./
            printf ( "\nSearch was interrupted.\n\nThis message "
                     "was written after an interrupt signal\n"
                     "was trapped. By default, the program "
                     "would have terminated \nbefore this message "
                     "could be written.\n\n"                       );
            }
         else
            {
            count = wncard_c( &result);
            printf( "Found %ld intervals in result\n", count );

            /.
            List the beginning and ending points in each interval.
            ./
            for( i=0; i<count; i++ )
               {
               wnfetd_c( &result, i, &beg, &end );
        
               timout_c ( beg, TIMFMT, LNSIZE, begstr );
               timout_c ( end, TIMFMT, LNSIZE, endstr );

               printf( "Interval %ld\n", i );
               printf( "Beginning TDB %s\n", begstr );
               printf( "Ending TDB    %s\n", endstr );
               }

            }

         return ( 0 );
         }
