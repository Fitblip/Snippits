import java.applet.*;
import java.net.*;
import java.util.*;
import java.io.*;
import netscape.javascript.*;

public class evil extends Applet {
  public void init() {
    try {
      URL url = new URL("http://www.ladoctrina.org");
      // URL url = new URL("http://192.168.0.2/java/");            
      String inputLine;
      URLConnection conn = url.openConnection();
      System.out.print("Stuffs:\n");
      BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
      while ((inputLine = in.readLine()) != null) { 
        System.out.println(inputLine);
      }
      in.close();        
    } catch (Exception e) { 
      System.out.println("Error :(");
      System.out.println(e.getMessage());
    }
    JSObject win = (JSObject) JSObject.getWindow(this);
  }
}
