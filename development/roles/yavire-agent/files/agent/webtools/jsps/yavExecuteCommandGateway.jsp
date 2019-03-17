<%@ page language="java" import="java.io.*,java.util.*,java.lang.*,java.net.*,java.sql.*,javax.servlet.*" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" %>

<%! 
 public String convertHexToString(String hex){

	  StringBuilder sb = new StringBuilder();
	  StringBuilder temp = new StringBuilder();
	  
	  //49204c6f7665204a617661 split into two characters 49, 20, 4c...
	  for( int i=0; i<hex.length()-1; i+=2 ){
		  
	      //grab the hex in pairs
	      String output = hex.substring(i, (i + 2));
	      //convert hex to decimal
	      int decimal = Integer.parseInt(output, 16);
	      //convert the decimal to character
	      sb.append((char)decimal);
		  
	      temp.append(decimal);
	  }
	  System.out.println("Decimal : " + temp.toString());
	  
	  return sb.toString();
  }
%>

<%

 class StreamGobbler extends Thread
   {
       InputStream is;
       String szFileName;
       String salida = "";
       String type;
    
       StreamGobbler(InputStream is, String szParFileName, String type)
       {
        this.is = is;
        this.szFileName = szParFileName;
        this.type = type;
       }
    
       public void run()
       {
          try
          {
            InputStreamReader isr = new InputStreamReader(is);
            BufferedReader br = new BufferedReader(isr);
            String line=null;
            while ( (line = br.readLine()) != null) {
                //System.out.println(type + ">" + line);
                salida = salida + line + "\n";
            }  
 
	    File fleExample = new File(szFileName);
	    Writer pwInput = null;
	                
            pwInput = new BufferedWriter(new FileWriter(fleExample,true));
            
            if (type.compareTo("ERROR" ) == 0) { 
	       pwInput.write("ERROR_OWM=\n");
	    }
	    else {
	       pwInput.write("OUTPUT_OWM=\n");
	    }
            
            pwInput.write(salida);
            pwInput.close();

          }
          catch (IOException ioe)
          {
            ioe.printStackTrace();  
          }
       }

       public String getSalida()
       {
          return salida;
       }


   }
  
  request.setCharacterEncoding("UTF-8");
  response.setContentType("text/html; UTF-8");
  
  
  if (request.getMethod().equals("POST") && request.getHeader("User-Agent").equals("yavireConsole"))
  {
    
    
     System.out.println("====================================================================================================================================");
     System.out.println("Starting yavire Gateway operations 2.2.0.2_25");
     String szAgentVersion = "2.2.0.2";
     
     String szJSPRequest = request.getParameter("requestJSP");
     System.out.println("JSP Request: " + szJSPRequest);
     
     String szRequestIP = request.getParameter("requestIP");
     String szRequestPort = request.getParameter("requestPort");
     String szRequestTimout = request.getParameter("requestTimeout");
     
     String szCommandHex = request.getParameter("command");
     String szCommand = convertHexToString(szCommandHex);
     
     String szIdOperacion = request.getParameter("operacionId");
     String szNombreOperacion = request.getParameter("operationName");
     String szInstanceName = request.getParameter("instanceName");
     
     String szURL = "http://" + szRequestIP + ":" + szRequestPort + szJSPRequest;
     
     String szError = "";
    
    
     System.out.println("Id. Operacion: " + szIdOperacion);
     System.out.println("Request URL: " + szURL);
     System.out.println("Request Timeout: " + szRequestTimout);
     
     System.out.println("Remote Commnand: " + szCommand);
     
               
     String strNewValue = "&command=" + szCommandHex + "&operacionId=" + szIdOperacion + "&operationName=" + szNombreOperacion + "&instanceName=" + szInstanceName;
    
     System.out.println("Data to Send to final agent: " + strNewValue);
    
      try
      {
         File fileDir = new File("/opt/krb/yavire/agent/webtools/operations/commands/test.txt");
         Writer out2 = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileDir), "UTF8"));
         out2.append(szCommand).append("\r\n");
         out2.append("UTF-8 Demo").append("\r\n");
         out2.append("क्षेत्रफल = लंबाई * चौड़ाई").append("\r\n");
         out2.flush();
         out2.close();
      } catch (UnsupportedEncodingException e)
      {
         System.out.println(e.getMessage());
      } catch (IOException e)
      {
         System.out.println(e.getMessage());
      } catch (Exception e)
      {
         System.out.println(e.getMessage());
      }
    
     
     String szFileNameError = "";
     String szFileNameOutput = "";
     String szFileNameLog = "";
     
     String nameOS = System.getProperty("os.name");
  
     if (nameOS.toLowerCase().contains("windows")) {
        szFileNameError = "C:\\krb\\yavire\\agent\\webtools\\operaciones\\comandos\\" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameOutput = "C:\\krb\\yavire\\agent\\webtools\\operaciones\\comandos\\" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameLog = "C:\\krb\\yavire\\agent\\log\\operaciones\\" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        
     }
     else
     {
        szFileNameError = "/opt/krb/yavire/agent/webtools/operations/commands/" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameOutput = "/opt/krb/yavire/agent/webtools/operations/commands/" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameLog = "/opt/krb/yavire/agent/log/operations/" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
      
     }
     
     
     
     Integer iConnectTimeout = new Integer(szRequestTimout);
     Integer iReadTimeout = new Integer(szRequestTimout);
     
     if (iConnectTimeout < 0) {
        
        iConnectTimeout = 0;
        
     }
     
     if (iReadTimeout < 0) {
        
        iReadTimeout = 0;
        
     }
     
     String szDescription = "";
     int iCodError = 0;
     
     try {
           URL url = new URL(szURL);
           HttpURLConnection conn = (HttpURLConnection) url.openConnection();
           
           conn.setConnectTimeout(iConnectTimeout.intValue());
           conn.setReadTimeout(iReadTimeout.intValue());
           conn.setDoInput(true);
           conn.setDoOutput(true);
           
           //System.out.println("Paso 1");
           
           conn.setRequestMethod("POST");
  	   conn.setRequestProperty("User-Agent", "yavireConsole");
  	   conn.setRequestProperty("CONTENT-TYPE", "application/x-www-form-urlencoded");
  	   conn.setRequestProperty("Content-Length", "" + Integer.toString(strNewValue.getBytes().length));
  	   
  	   
  	   DataOutputStream wr = new DataOutputStream (conn.getOutputStream ());
  	   
           wr.writeBytes (strNewValue);
           wr.flush ();
           wr.close ();
           
           //System.out.println("Paso 2");

           //Según el protocolo HTTP el valor de respuesta 200 es una ejecución correcta
           //No tomamos en cuenta el valor 200 y devolvemos 0 como retorno
           if (conn.getResponseCode() != 200) {
        	System.out.println("********************");
        	System.out.println("Return: " + conn.getResponseCode());
                szDescription = "yavError: Error (" + conn.getResponseCode() +" ) executing " + szURL;
           }
           else {
               BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
               
               String inputLine;
               while ((inputLine = in.readLine()) != null) {
                  System.out.println(inputLine);
                  if (inputLine.indexOf("13200146") != -1) {
                	  System.out.println(inputLine);
                  }
                  szDescription=szDescription + inputLine + "\n";
               }
               in.close();
               
               //out.println(szDescription);
               
               System.out.println("\n Descripcion: " + szDescription + "\n");
           }
           iCodError= conn.getResponseCode();
           System.out.println("Respuesta: " + conn.getResponseCode());
           
       }catch (MalformedURLException e){
          System.out.println ("MalformedException: " + e.getMessage());
       }
       catch (UnknownHostException e) {
            System.out.println("Paso 3.12");
            szDescription = "yavError: Error UnknownHostException (" + e.getLocalizedMessage() +" ) executing " + szURL;
    	    iCodError=11001;
        }
        catch (NoRouteToHostException e) {
            System.out.println("Paso 3.13");
            szDescription = "yavError: Error NoRouteToHostException (" + e.getLocalizedMessage() +" ) executing " + szURL;
    	    iCodError=10060;
    	    
    	    StringWriter szWriter = new StringWriter();
            PrintWriter pWriter = new PrintWriter(szWriter);
            e.printStackTrace(pWriter);
            szError = new String(szWriter.getBuffer());
        }
        catch (ConnectException e) {
            System.out.println("Paso 3.11");
            szDescription = "yavError: Error ConnectException (" + e.getLocalizedMessage() +" ) executing " + szURL;
            iCodError=10061;
            
            StringWriter szWriter = new StringWriter();
            PrintWriter pWriter = new PrintWriter(szWriter);
            e.printStackTrace(pWriter);
            szError = new String(szWriter.getBuffer());
        }
        /*catch (SocketException e) {
            System.out.println("Paso 3.11");
            iCodError=10040;
            szDescription = "yavError: Error (" + e.getLocalizedMessage() +" ) executing " + szURL;
        }*/

       catch (IOException e) {
          
          System.out.println("Paso 3.1");
      	  StringWriter szWriter = new StringWriter();
          PrintWriter pWriter = new PrintWriter(szWriter);
          e.printStackTrace(pWriter);
          szError = new String(szWriter.getBuffer());
          
          //System.out.println("Error: " + szError);
    	
          if (e.getMessage().lastIndexOf("Read timed out")!= -1) {
                  iCodError=10063;
                  szDescription = "yavError: Execution timeout (" + szRequestTimout +" milliseconds in " + szURL;
          }
          if (e.getMessage().lastIndexOf("reset")!= -1) {
                 szDescription = "yavError: Error (" + e.getLocalizedMessage() +" ) executing " + szURL;
                 iCodError=10053;
          }
       }
       catch (Exception e) {
          //System.out.println("Paso 3.2");
          System.out.println ("Exception: " + e.getMessage());
          szDescription = e.getLocalizedMessage();
       }
     
      System.out.println("Paso 3.4");
      System.out.println("\n Descripcion: " + szDescription + "\n");
      
      out.println("agentVersion= " + szAgentVersion + " %% returnCode=" + iCodError + " %% returnData=" + szDescription + " %%");
      
      System.out.println("Ending yavire Gateway operations 2.2.0.2_21");
      System.out.println("====================================================================================================================================");
      
        
     
  }
  else {
     out.println("yavError in executeCommandGateway: This JSP can only be run from the console yavire - 2.2.0.2_21\n");
  }

  
  


   
%>
