<%@ page language="java" import="java.io.*,java.util.*,java.lang.*,java.sql.*,javax.servlet.*" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" session="false" %>

<%

 //Igual que el de ejecución de comandos, pero sin salidas de logs y recibe otros parámetros
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
  response.setContentType("text/html; charset=UTF-8");
  
   
  
  if (request.getMethod().equals("POST") && request.getHeader("User-Agent").equals("yavireConsole"))
  {
    
    
     System.out.println("\n==================================================================================================");
     System.out.println("yavire execute for monitoring 2.2.0.2_1");
          
     String szIdOperacion = request.getParameter("operacionId");
     String szNombreOperacion = request.getParameter("operationName");
     String szInstanceName = request.getParameter("instanceName");
     
     String szCommand = request.getParameter("command");

  
     System.out.println("operation ID: :" + szIdOperacion);
     System.out.println("Operation Command: " + szCommand);
     System.out.println("Operation Name: " + szNombreOperacion);
     System.out.println("Instance Name: " + szInstanceName);
     
          
     szInstanceName = szInstanceName.replaceAll("/", "_");
     System.out.println("Instance Name 2: " + szInstanceName);
          
     String szFileNameError = "";
     String szFileNameOutput = "";
     String szFileNameLog = "";
     
     String nameOS = System.getProperty("os.name");
  
     if (nameOS.toLowerCase().contains("windows")) {
        szFileNameError = "C:\\krb\\yavire\\agent\\log\\events\\"+ szInstanceName + ".err";
        szFileNameOutput = "C:\\krb\\yavire\\agent\\log\\events\\" + szInstanceName + ".out";
        szFileNameLog = "C:\\krb\\yavire\\agent\\log\\events\\" + szInstanceName + ".log";
        
     }
     else
     {
        szFileNameError = "/opt/krb/yavire/agent/log/events/"  + szInstanceName + ".err";
        szFileNameOutput = "/opt/krb/yavire/agent/log/events/" + szInstanceName + ".out";
        szFileNameLog = "/opt/krb/yavire/agent/log/events/" +  szInstanceName + ".log";
      
     }
     
     
      try
      {
         File fileDir = new File("C:\\krb\\yavire\\agent\\log\\events\\test.txt");
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
     
     PrintWriter writer = new PrintWriter(szFileNameLog, "UTF-8");
     writer.println("Fichero Log: " + szFileNameLog);
   
     System.out.println("Paso 1\n");
   
     HttpSession session = null;

     String szGetServerInfo =  application.getServerInfo();
     String szOUTPUT = "";
     String szERROR = "";
     String szDATOSVUELTA = "";
     session = request.getSession(true);
     System.out.println("Sesion: " + session.getId());
     Runtime r = null;

     r = Runtime.getRuntime();
     try
     {
        Process p=null;
        if ( nameOS.equals("AIX") || nameOS.equals("Linux") || nameOS.equals("Solaris"))
        {

           System.out.println("Paso 2\n");
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

           szDATOSVUELTA = szOUTPUT + szERROR;
           
           %><%=szDATOSVUELTA%><%

        }
        else
        {
           

           System.out.println("Paso 3\n");
           String comando=szCommand;
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
           
           szDATOSVUELTA = szOUTPUT + szERROR;
           
           System.out.println("szOUTPUT: " + szOUTPUT + "\n");
           
           %><%=szDATOSVUELTA%><%



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
     out.println("Este JSP solo se puede ejecutar desde la consola yavire\n");
  }
   
%>
