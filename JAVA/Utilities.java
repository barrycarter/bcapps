import java.io.*;

public class Utilities extends java.lang.Object {
  public static BufferedReader stobr (String s, String t) {
    BufferedReader f = null;
    try {
      InputStream zis= (Class.forName(t)).getResourceAsStream(s);
      InputStreamReader temp = new InputStreamReader(zis);
      f = new BufferedReader(temp);
    } catch (Exception xx) {
      System.err.println("EXCEPTION: "+xx);
    }
    return(f);
  }
}
