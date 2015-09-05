#include <stdio.h>
#include "SpiceUsr.h"

void main() {

#define        ABCORR        "NONE"
#define        FRAME         "J2000"
#define        SPK           "/home/barrycarter/SPICE/KERNELS/de431_part-2.bsp"
#define        ET0           -43200
#define        STEP          86400.0
#define        MAXITR        365000
#define        OBSERVER      399
#define        TARGET        4
  SpiceInt       i;
  SpiceDouble    et;
  SpiceDouble    lt;
  SpiceDouble    pos [3];
  furnsh_c ( SPK );

  for ( i = 0;  i < MAXITR;  i++ ) {
    et  =  ET0 + i*STEP;
    spkezp_c ( TARGET, et, FRAME, ABCORR, OBSERVER,  pos,  &lt);
    printf( "\net = %20.10f\n\n",                 et     );
    printf( "J2000 x-position (km):   %20.10f\n", pos[0] );
    printf( "J2000 y-position (km):   %20.10f\n", pos[1] );
    printf( "J2000 z-position (km):   %20.10f\n", pos[2] );
  }
}
