<%@ page language="java" import="java.io.*,java.util.*,java.lang.*,java.sql.*,javax.servlet.*" contentType="text/html;charset=ISO8859-15" pageEncoding="ISO8859-15" session="false" %>

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

  request.setCharacterEncoding("ISO8859-15");
  response.setContentType("text/html; charset=ISO8859-15");
  
  
  if (request.getMethod().equals("POST") && request.getHeader("User-Agent").equals("openWeb Monitor"))
  {
    
     String szIdOperacion = request.getParameter("operacionId");
     String szNombreOperacion = request.getParameter("operacionName");
     String szInstanceName = request.getParameter("instanceName");
     String dato = request.getParameter("comando");
  
     System.out.println("yavire operations 2.1.0.0_1");
     System.out.println("Id. Operacion: :" + szIdOperacion);
     
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
        szFileNameError = "/opt/krb/yavire/agent/webtools/operaciones/comandos/" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameOutput = "/opt/krb/yavire/agent/webtools/operaciones/comandos/" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
        szFileNameLog = "/opt/krb/yavire/agent/log/operaciones/" + szIdOperacion + "_" + szInstanceName + "_" + szNombreOperacion;
      
     }
     
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

           String comando[]={"sh","-c",dato};
           
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
           

           String comando=dato;
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
     out.println("Este JSP solo se puede ejecutar desde la consola yavire\n");
  }

  
  


   
%>
