<%@ page language="java" import="java.io.*,java.net.*,java.util.*,java.lang.Thread,javax.servlet.*,javax.servlet.http.*,java.lang.*,java.lang.management.*"%>
<%@ page contentType="text/html;charset=ISO-8859-1"%>
<%@ page session="false" %>
<%  
    //yavire 2.1.0.0_0
    response.setContentType("text/html");      
    HttpSession session = null;              
    session = request.getSession(true);
    RuntimeMXBean bean = ManagementFactory.getRuntimeMXBean();
    ThreadMXBean  beanThread = ManagementFactory.getThreadMXBean();
    
    //long startTime = bean.getStartTime();
    //Date startDate = new Date(startTime); 
    Calendar rightNow = Calendar.getInstance();
    Date d = rightNow.getTime();
    //String szFecha = rightNow.getTime();
    
    int peakThreadCount = beanThread.getPeakThreadCount();
    int threadCount = beanThread.getThreadCount();
   
    out.println(bean.getName() + "|"); //pid
    out.println(d + "|"); //pid
    out.println(Runtime.getRuntime().maxMemory() + "|");
    out.println(Runtime.getRuntime().totalMemory() + "|");
    out.println(Runtime.getRuntime().freeMemory() + "|");
    out.println(peakThreadCount + "|");
    out.println(threadCount + "|");
    
      
%>
