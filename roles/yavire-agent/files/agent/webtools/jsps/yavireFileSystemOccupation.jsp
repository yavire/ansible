<%@ page language="java" import="java.io.*,java.util.*,java.lang.*,javax.servlet.*" contentType="text/html;charset=ISO8859-15" pageEncoding="ISO8859-15" session="false" %>
<%
   request.setCharacterEncoding("ISO8859-15");
   response.setContentType("text/html; charset=ISO8859-15");
   HttpSession session = null;
   session = request.getSession(true);
   
   
   String szParFileSystem = request.getParameter("fileSystem");
   String szVersionOWM = "owmVersion::3.4.3.1_2 | ";
   
   if (request.getMethod().equals("POST") && request.getHeader("User-Agent").equals("openWeb Monitor"))
   {
      String szGetServerInfo =  application.getServerInfo();
      Runtime r = null;
      Process p = null;

      r = Runtime.getRuntime();

      String nameOS = System.getProperty("os.name");
      String szCommand = "";
      
      if ( nameOS.equals("SunOS"))
      {
         szCommand = "/usr/xpg4/bin/df -kP " + szParFileSystem;
      }
      else
      {
         szCommand = "/bin/df -kP " + szParFileSystem;
      } 
  
      p = r.exec(szCommand);

      p.waitFor();

      BufferedReader in=new BufferedReader(new InputStreamReader(p.getInputStream()));
   
      String szValor = "";
      in.readLine();
     
      while ((szValor = in.readLine())!= null)
      {
         StringTokenizer st = new StringTokenizer(szValor);  
         st.nextToken();
         String szAsign= "fsAssign:: " + st.nextToken() + "| ";
         String szUsed=  "fsUsed::: " + st.nextToken() + "| ";
         String szFree=  "fsAvailable:: " + st.nextToken() + "| ";
         String szPorc=  "fsCapacity:: " + st.nextToken() + "| ";
         szPorc= szPorc.substring(0, szPorc.length()-1);
        
         %>
         <%=szVersionOWM%>
         <%=szAsign%>
         <%=szFree%>
         <%=szPorc%><%
      }
      
   }
   else {
     out.println("Este JSP solo se puede ejecutar desde la consola yavire\n");
   }
   
%>
