import java.awt.*;
import java.io.*;
import java.util.*;

class Starmap extends Object {
  static BeanMap bean;

  public static void main (String argv[]) { 
    Frame f=new Frame("BeanMap");
    bean= new BeanMap();
    f.add(bean);
    bean.setSize(640,480);
    f.pack();
    f.show();
    beaninit();
  }

  static void beaninit() {

    String s,name,spec;
    StringTokenizer st;
    int count=0;
    double ra,dec,mag,x,y,z,r,showsize;
    Vector vx= new Vector();
    Vector vy= new Vector();
    Vector vz= new Vector();

    BufferedReader f = Utilities.stobr("namradecmagspec.txt","Starmap");

    try {
      while ( (s=f.readLine()) != null) {
	st=new StringTokenizer(s);
	name=st.nextToken();
        ra=(new Double(st.nextToken())).doubleValue()/24*2*Math.PI;
        dec=(new Double(st.nextToken())).doubleValue()/180*Math.PI;
        mag=(new Double(st.nextToken())).doubleValue();
	spec=st.nextToken();
	count++;
	String label="("+count+")"+name;
	r=Math.cos(dec);
	z=Math.sqrt(1-r*r);
	if (dec<0) {z=-z;}
	x=r*Math.cos(ra);
	y=r*Math.sin(ra);
	vx.addElement(new Double(x));
	vy.addElement(new Double(y));
	vz.addElement(new Double(z));

	showsize=5;
	if (mag>1.5) {showsize=4;}
	if (mag>2.5) {showsize=3;}
	if (mag>3.5) {showsize=2;}
	if (mag>4.5) {showsize=1;}

	bean.makerect(x,y,z,showsize,label);
      } 
    } 
    catch (Exception xx) {System.err.println("EXCEPTION READING STARLIST: "+xx);}

    f = Utilities.stobr("constellations.dat","Starmap");

     try {
       while ( (s=f.readLine()) != null) {
 	if (s.trim().length() == 0) {continue;}
         if (s.trim().startsWith("#")) {continue;}
         st=new StringTokenizer(s);
         int first=(new Integer(st.nextToken())).intValue();
         int second=(new Integer(st.nextToken())).intValue();
 	first--;second--;
 	bean.makeline(
 		      ((Double)vx.elementAt(first)).doubleValue(),
 		      ((Double)vy.elementAt(first)).doubleValue(),
 		      ((Double)vz.elementAt(first)).doubleValue(),
 		      ((Double)vx.elementAt(second)).doubleValue(),
 		      ((Double)vy.elementAt(second)).doubleValue(),
 		      ((Double)vz.elementAt(second)).doubleValue()
 		      );
       }
     }
     catch (Exception xx) {System.err.println("EXCEPTION WHILE READING CONSTELLATIONS.DAT: "+xx);}
     bean.roty(Math.PI/2);
     bean.zoomview(2);
  }
}
