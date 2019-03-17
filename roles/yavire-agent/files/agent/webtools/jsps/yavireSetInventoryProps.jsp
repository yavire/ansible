<%@ page language="java" import="java.io.*,java.util.*,java.lang.*,java.sql.*,javax.servlet.*" contentType="text/html;charset=ISO8859-15" pageEncoding="ISO8859-15" session="false" %>

<%

  request.setCharacterEncoding("ISO8859-15");
  response.setContentType("text/html; charset=ISO8859-15");
  
  
  if (request.getMethod().equals("POST") && request.getHeader("User-Agent").equals("YavireYAV"))
  {
     
         
     String szTNSName = request.getParameter("strcon");
     String szUser = request.getParameter("User");
     String szPassword = request.getParameter("Password");
     String szDirProperties = request.getParameter("DirConf");
  
     System.out.println("yavire set inventory props 2.2.0.0_2");
     System.out.println("strcon: :" + szTNSName);
     System.out.println("User: :" + szUser);
     //System.out.println("Password: :" + szPassword);
     String nameOS = System.getProperty("os.name");
     
     
     File f = new File(szDirProperties);
     if (f.exists() && f.isDirectory()) {
        System.out.println("Existe: :" + szDirProperties);
        
        //Recreamos el fichero properties.com
        
        try
        {
             
           File file = new File(szDirProperties + "yavire.ini");
           if (file.exists()) {
               file.delete();
           }
           
	    File fileProperties = new File(szDirProperties + "yavire.ini");
	    
	    Writer pwInput = null;
	                
            pwInput = new BufferedWriter(new FileWriter(fileProperties,false));
            
            pwInput.write("[config]\n");
            pwInput.write("strcon=jdbc:oracle:thin:@" + szTNSName + "\n");
            pwInput.write("User=" +szUser + "\n");
            pwInput.write("Password=" +szPassword + "\n");
            pwInput.close();

          }
          catch (IOException ioe)
          {
            ioe.printStackTrace();  
          }
        
        
     }
     else {
        System.out.println("NO Existe: :" + szDirProperties);
        
         if (nameOS.toLowerCase().contains("windows")) {
            out.println("YAV-2000002");
         }
         else {
            out.println("YAV-2000005");
         }   
         out.flush();
     }
     
     
      
  }
  else {
     out.println("This JSP can only be run from the console yavire\n");
  }
 
%>
