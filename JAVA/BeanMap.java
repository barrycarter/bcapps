import java.awt.*;
import java.util.*;
import java.io.*;
import java.awt.event.*;

class Space extends java.lang.Object {
  Vector rrs= new Vector();
  Vector rls= new Vector();

  Spacerect makerect(double x0, double y0, double z0, double size) {
    Spacerect r= new Spacerect(x0,y0,z0,size);
    rrs.addElement(r);
    return(r);
  }

  Spacerect makerect(double x0, double y0, double z0, double size, String label) {
    Spacerect r= new Spacerect(x0,y0,z0,size,label);
    rrs.addElement(r);
    return(r);
  }

  void rotx (double theta) {rot(theta,0);}
  void roty (double theta) {rot(theta,1);}
  void rotz (double theta) {rot(theta,2);}
  
  void rot (double theta, int axis) {
    double cotheta=Math.cos(theta);
    double sitheta=Math.sin(theta);
    Spacerect r;
    Spaceline li;

    for (Enumeration l=rrs.elements(); l.hasMoreElements(); ) {
      r=(Spacerect)l.nextElement();
      r.rot(axis,sitheta,cotheta);
    }
    
    for (Enumeration l=rls.elements(); l.hasMoreElements(); ) {
      li=(Spaceline)l.nextElement();
      li.rot(axis,sitheta,cotheta);
    }
  }
}

class Spacerect extends java.lang.Object {
  double x,y,z,size,r,az,el,origx,origy,origz;
  Color color=Color.white;
  String label="";
  boolean showlabel = false;

  Spacerect(double x,double y,double z,double size) {
    origx=x;origy=y;origz=z;
    this.x=x;this.y=y;this.z=z;this.size=size;
    updatepolarfromrect();
  }
  
  Spacerect(double x,double y,double z,double size, String label) {
    origx=x;origy=y;origz=z;
    this.x=x;this.y=y;this.z=z;this.size=size;this.label=label;
    updatepolarfromrect();
  }
  
  void updatepolarfromrect () {
    az=-Math.atan2(y,x);
    el=Math.atan2(z,Math.sqrt(x*x+y*y));
  }
  
  void rot (int axis, double sitheta, double cotheta) {
    double newx=0.,newy=0.,newz=0.;
    if (axis==0) {
      newx=x;
      newy=y*cotheta+z*sitheta;
      newz=z*cotheta-y*sitheta;
    }
    if (axis==1) {
      newx=x*cotheta+z*sitheta;
      newy=y;
      newz=-x*sitheta+z*cotheta;
    }
    if (axis==2) {
      newx=x*cotheta+y*sitheta;
      newy=-x*sitheta+y*cotheta;
      newz=z;
    }
    x=newx;
    y=newy;
    z=newz;
    updatepolarfromrect();
  }
}

class Spaceline extends java.lang.Object {
  Spacerect a,b;
  Spaceline(double x0,double y0, double z0, double x1,double y1, double z1) {
    a = new Spacerect(x0,y0,z0,1);
    b = new Spacerect(x1,y1,z1,1);
  }
  Spaceline(Spacerect a, Spacerect b) {
    this.a=new Spacerect(a.x,a.y,a.z,1);
    this.b=new Spacerect(b.x,b.y,b.z,1);
  }
  void rot (int axis, double sitheta, double cotheta) {
    a.rot(axis,sitheta,cotheta);
    b.rot(axis,sitheta,cotheta);
  }
}

public class BeanMap extends java.awt.Canvas implements Serializable, KeyListener, MouseListener {
  int width;
  int height;
  double view=Math.PI/2.;
  Space sp= new Space();
  private Image offScreenImage;
  private Dimension offScreenSize,d;
  private Graphics offScreenGraphics;

  public BeanMap() {
    width=320;
    height=200;
    addKeyListener(this);
    addMouseListener(this);
  }

  public void mouseClicked(MouseEvent e) {

    int q=findrect((e.getX()*2./width-1)*view,((e.getY()*2./height-1)*-view));
    System.err.println("You've found : "+q);
    q--;
    Spacerect x=(Spacerect)(sp.rrs.elementAt(q));
    System.err.println("X: "+x);
    System.err.println("X quants: "+x.label);
  }

  public void mouseEntered(MouseEvent e) {}
  public void mouseExited(MouseEvent e) {}
  public void mousePressed(MouseEvent e) {}
  public void mouseReleased(MouseEvent e) {}

  public void keyTyped(KeyEvent evt) {}
  public void keyReleased(KeyEvent evt) {}

  public void keyPressed(KeyEvent e) {
    int ch=e.getKeyCode();
    double rot=view/25.;
    
    if (ch == KeyEvent.VK_DOWN) {roty(-rot);}
    if (ch == KeyEvent.VK_UP) {roty(rot);}
    if (ch == KeyEvent.VK_LEFT) {rotz(rot);}
    if (ch == KeyEvent.VK_RIGHT) {rotz(-rot);}
    if (ch == KeyEvent.VK_F7) {zoomview(1.1);}
    if (ch == KeyEvent.VK_F8) {zoomview(1/1.1);}
    if (ch == KeyEvent.VK_PAGE_UP) {rotx(-rot);}
    if (ch == KeyEvent.VK_PAGE_DOWN) {rotx(rot);}
  }

  public void rotx (double theta) {sp.rot(theta,0);repaint();}
  public void roty (double theta) {sp.rot(theta,1);repaint();}
  public void rotz (double theta) {sp.rot(theta,2);repaint();}
  public void zoomview (double factor) {view=view/factor;repaint();}

  int findrect (double az, double el) {
    double di;
    double min=1e+10;
    int i=0,j=0;
    Spacerect mr=null,r;
    
    for (Enumeration l=sp.rrs.elements(); l.hasMoreElements(); ) {
      i++;
      r=(Spacerect)l.nextElement();
      di=(r.az-az)*(r.az-az)+(r.el-el)*(r.el-el);
      if (di<min) {
	j=i;
	min=di;
	mr=r;
      }
    }
    mr.showlabel=!mr.showlabel;
    repaint();
    return(j);
  }

  public Spacerect makerect(double x, double y, double z, double s) {
    Spacerect r= new Spacerect(x,y,z,s);
    sp.rrs.addElement(r);
    return(r);
  }

  public Spacerect makerect(double x, double y, double z, double s, String label) {
    Spacerect r= new Spacerect(x,y,z,s,label);
    sp.rrs.addElement(r);
    return(r);
  }

  public void makeline(double x0, double y0, double z0, double x1, double y1, double z1) {
    sp.rls.addElement(new Spaceline(x0,y0,z0,x1,y1,z1));
  }

  void makeline(Spacerect a, Spacerect b) {
    sp.rls.addElement(new Spaceline(a,b));
  }

  public Point ptsc (Spacerect r) {
    int tx,ty;
    tx=(int)(width/2.*(1+r.az/view));
    ty=(int)(height/2.*(1-r.el/view));
    return(new Point(tx,ty));
  }

  public final synchronized void update (Graphics g) {
    d = getSize();
    if((offScreenImage == null) || (d.width != offScreenSize.width) ||  (d.height !=offScreenSize.height)) {
      offScreenImage = createImage(d.width, d.height);
      offScreenSize = d;
      offScreenGraphics = offScreenImage.getGraphics();
    }
    paint(offScreenGraphics);
    g.drawImage(offScreenImage, 0, 0, null);
  }

  public void paint (Graphics g) {
    width=getSize().width;
    height=getSize().height;
    g.setColor(Color.black);
    g.fillRect(0,0,width,height);
    g.clipRect(0,0,width,height);
    g.setColor(Color.white);
    Spacerect r;
    Spaceline li;
    Point p,q;
    
    g.setColor(Color.blue);
    for (Enumeration l=sp.rls.elements(); l.hasMoreElements(); ) {
      li=(Spaceline)l.nextElement();
      p=ptsc(li.a);
      if (p.x<0 || p.x>width || p.y<0 || p.y>height) {continue;}
      q=ptsc(li.b);
      if (q.x<0 || q.x>width || q.y<0 || q.y>height) {continue;}
	g.drawLine(p.x,p.y,q.x,q.y);
    }

    g.setColor(Color.white);
    for (Enumeration l=sp.rrs.elements(); l.hasMoreElements(); ) {
      r=(Spacerect)l.nextElement();
      p=ptsc(r);
      if (p.x>0 && p.x<width && p.y>0 && p.y<height && r.size>=1) {
	g.setColor(r.color);
	if (r.showlabel) {g.drawString(r.label,p.x,p.y);}
        g.fillRect(p.x,p.y,(int)r.size,(int)r.size);
      }
    }
  }
}
