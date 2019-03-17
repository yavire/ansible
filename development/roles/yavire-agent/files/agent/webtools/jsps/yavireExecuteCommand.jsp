<%@ page language="java" import="java.io.*,java.util.*,java.lang.*,java.sql.*,javax.servlet.*" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" isThreadSafe="false"%>

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
	       pwInput.write("ERROR_YAV=\n");
	    }
	    else {
	       pwInput.write("OUTPUT_YAV=\n");
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
  response.setContentType("text/html; charset=UTF-8");
  
  System.out.println("yavire operations 2.2.0.2_6");
  
  
  if (request.getMethod().equals("POST") && request.getHeader("User-Agent").equals("yavireConsole"))
  {
    
    
    
     String szIdOperacion = request.getParameter("operacionId");
     String szNombreOperacion = request.getParameter("operationName");
     String szInstanceName = request.getParameter("instanceName");
     String szCommandHex = request.getParameter("command");
     String szCommand = convertHexToString(szCommandHex);
  
     System.out.println("yavire operations 2.2.0.2_6");
     System.out.println("operation ID: :" + szIdOperacion);
     System.out.println("Operation Command: " + szCommand);
     System.out.println("Operation Name: " + szNombreOperacion);
     System.out.println("Instance Name: " + szInstanceName);
     
     
     String szFileNameError = "";
     String szFileNameOutput = "";
     String szFileNameLog = "";
     
     String nameOS = System.getProperty("os.name");
  
     if (nameOS.toLowerCase().contains("windows")) {
        szFileNameError = "C:\\krb\\yavire\\agent\\webtools\\operations\\commands\\" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameOutput = "C:\\krb\\yavire\\agent\\webtools\\operations\\commands\\" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameLog = "C:\\krb\\yavire\\agent\\log\\operations\\" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        
     }
     else
     {
        szFileNameError = "/opt/krb/yavire/agent/webtools/operations/commands/" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameOutput = "/opt/krb/yavire/agent/webtools/operations/commands/" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameLog = "/opt/krb/yavire/agent/log/operations/" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
      
     }
	 
     System.out.println("Output File : " + szFileNameOutput);
	 System.out.println("Error File : " + szFileNameError);
	 System.out.println("Log File : " + szFileNameLog);
     
     PrintWriter writer = new PrintWriter(szFileNameLog, "UTF-8");
     writer.println("Fichero Log: " + szFileNameLog);
   
     HttpSession session = null;

     String szGetServerInfo =  application.getServerInfo();
     String szOUTPUT = "";
     String szERROR = "";
     String szSalida = "";
     session = request.getSession(true);
     System.out.println("Sesion: " + session.getId());
     Runtime r = null;

     r = Runtime.getRuntime();
     try
     {
        Process p=null;
        if ( nameOS.equals("AIX") || nameOS.equals("Linux") || nameOS.equals("Solaris"))
        {

           String comando[]={"sh","-c", szCommand};
           
           Runtime rt = Runtime.getRuntime();
           Process proc = rt.exec(comando);

           //  Hay mensaje de error?
           StreamGobbler errorGobbler = new StreamGobbler(proc.getErrorStream(), szFileNameError,"ERROR");

           //  Devuelve salida ?
           StreamGobbler outputGobbler = new StreamGobbler(proc.getInputStream(), szFileNameOutput,"OUTPUT"); 

           //Arrancamos los threads de salidas
           errorGobbler.start();
           szERROR = errorGobbler.getSalida();

           outputGobbler.start();
           szOUTPUT = outputGobbler.getSalida();

           // Hay errores?
           int exitVal = proc.waitFor();
           writer.println("ExitValue: " + exitVal);


           szOUTPUT = outputGobbler.getSalida();
           szERROR = errorGobbler.getSalida();

           //System.out.println("salida: OUTPUT " + szOUTPUT);
           //System.out.println("salida ERROR: " + szERROR);

           //System.out.println("Datos vuelta: " + szSalida);
           %><%=szSalida%><%

        }
        else
        {

           String comando = szCommand;
           Runtime rt = Runtime.getRuntime();
           Process proc = rt.exec(comando);
           
           //  Hay mensaje de error?
           StreamGobbler errorGobbler = new StreamGobbler(proc.getErrorStream(), szFileNameError,"ERROR");

           //  Devuelve salida ?
           StreamGobbler outputGobbler = new StreamGobbler(proc.getInputStream(), szFileNameOutput,"OUTPUT"); 

           //Arrancamos los threads de salidas
           errorGobbler.start();
           szERROR = errorGobbler.getSalida();

           outputGobbler.start();
           szOUTPUT = outputGobbler.getSalida();

           // Hay errores?
           int exitVal = proc.waitFor();
           writer.println("ExitValue: " + exitVal);
           

           szOUTPUT = outputGobbler.getSalida();
           szERROR = errorGobbler.getSalida();

           %><%=szSalida%><%

        }
     }
     catch (Exception e)
     {
        // Excepciones si hay problema al arrancar el ejecutable o al leer su salida.
        
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        e.printStackTrace(pw);
        String cadena_error=sw.toString();
        writer.println(cadena_error);
        writer.println("The second line");
        int indice=cadena_error.indexOf("at ");
        cadena_error="ERROR: "+cadena_error.substring(0,indice);
        %><%=cadena_error%><%
        sw.close();
        pw.close();

     }
     
     writer.close();     
     
  }
  else {
     out.println("yavError in  executeCommand: This JSP can only be run from the console yavire 2.2.0.2\n");
  }
   
%>
