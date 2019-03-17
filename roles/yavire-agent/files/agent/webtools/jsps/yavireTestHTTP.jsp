<%@ page language="java" import="java.io.*,java.util.*,java.net.*,java.lang.*,javax.servlet.*"%>
<%@ page contentType="text/html;charset=ISO-8859-1"%>
<%@ page session="false" %>
<%
   response.setContentType("text/html; charset=ISO8859-15");
   String szURL = request.getParameter("url");
   String szConnectTimeout = request.getParameter("connTimeout");
   String szReadTimeout = request.getParameter("readTimeout");
   
   Integer iConnectTimeout = new Integer(szConnectTimeout);
   Integer iReadTimeout = new Integer(szReadTimeout);
   String szDescription = "";
   int iCodError = 0;
   HttpURLConnection conn = null;

   System.out.println("yavireTestHTTP Proxy Version 2.1.0.0_1");

   try {
           URL url = new URL(szURL);
           conn = (HttpURLConnection) url.openConnection();
           conn.setConnectTimeout(iConnectTimeout.intValue());
           conn.setReadTimeout(iReadTimeout.intValue());
           conn.setDoInput(true);
           conn.setDoOutput(true);

           //Según el protocolo HTTP el valor de respuesta 200 es una ejecución correcta
           //No tomamos en cuenta el valor 200 y devolvemos 0 como retorno
           if (conn.getResponseCode() != 200) {
        	  //System.out.println("********************");
        	  //System.out.println("Respuesta: " + conn.getResponseCode());
               szDescription = "Error (" + conn.getResponseCode() +" ) en la sentencia " + szURL;
           }
           else {
               BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
               System.out.println("Paso1");
               String inputLine;
               while ((inputLine = in.readLine()) != null) {
                  System.out.println(inputLine);
                  if (inputLine.indexOf("13200146") != -1) {
                	  System.out.println(inputLine);
                  }
                  szDescription=szDescription + inputLine;
               }
               in.close();
           }
           iCodError= conn.getResponseCode();
           System.out.println("Respuesta: " + conn.getResponseCode());
       }catch (MalformedURLException e){
          System.out.println ("MalformedException: " + e.getMessage());
       }
       catch (UnknownHostException e) {
            szDescription = "Error (" + e.getLocalizedMessage() +" ) en la sentencia " + szURL;
    	    iCodError=11001;
        }
       catch (SocketException e) {
            iCodError=10061;
            szDescription = "Error (" + e.getLocalizedMessage() +" ) en la sentencia " + szURL;
       }

       catch (IOException e) {
      	  StringWriter szWriter = new StringWriter();
          PrintWriter pWriter = new PrintWriter(szWriter);
          e.printStackTrace(pWriter);
          String szError = new String(szWriter.getBuffer());
          
          System.out.println("Error: " + szError);
    	  
          if (e.getMessage().lastIndexOf("refused")!= -1) {
        	  System.out.println("Error de conexion refused");
                  iCodError=10061;
                  szDescription = e.getLocalizedMessage();
        	  szDescription = "No se ha podido conectar (" + e.getLocalizedMessage() + ") a la sentencia " + szURL;
          }
          if (e.getMessage().lastIndexOf("Read timed out")!= -1) {
        	  System.out.println("Se ha excedido (read timeout) el tiempo de ejecución (" + szReadTimeout +" milisegundos)");
                  iCodError=10063;
                  szDescription = "Se ha excedido (read timeout) el tiempo de ejecución (" + szReadTimeout +" milisegundos) en la sentencia " + szURL;
          }
          if (e.getMessage().lastIndexOf("connect timed out")!= -1) {
                 szDescription = "Se ha excedido (connect timeout) el tiempo de conexión (" + szConnectTimeout +" milisegundos en la sentencia " + szURL;
                 iCodError=10060;
          }
          if (e.getMessage().lastIndexOf("reset")!= -1) {
                 szDescription = "Error (" + e.getLocalizedMessage() +" ) en la sentencia " + szURL;
                 iCodError=10053;
          }
       }
       catch (Exception e) {
          System.out.println ("Exception: " + e.getMessage());
          szDescription = e.getLocalizedMessage();
       }

%><%=iCodError%> <%=szDescription%>
