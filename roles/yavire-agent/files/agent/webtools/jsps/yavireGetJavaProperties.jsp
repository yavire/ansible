<%@ page language="java" import="java.io.*,java.net.*,java.util.*,java.lang.Thread,javax.servlet.*,javax.servlet.http.*,java.lang.*,java.lang.management.*"%>
<%@ page contentType="text/html;charset=ISO-8859-1"%>
<%@ page session="false" %>
<%  
    //yavire 2.1.0.0_1
    response.setContentType("text/html");      
    HttpSession session = null;              
    session = request.getSession(true);
    RuntimeMXBean bean = ManagementFactory.getRuntimeMXBean();
      
    Map<String, String> systemProperties = bean.getSystemProperties();
    Set<String> keys = systemProperties.keySet();
    
    for (String key : keys) {
        String value = systemProperties.get(key);
        //System.out.printf("Property[%s] = %s.\n", key, value);
        out.println( key + " = " + value + " | ");
    }
    
%>
