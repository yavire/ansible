<%@ page language="java" import="java.io.*,java.net.*,java.util.*,java.lang.Thread,javax.servlet.*,javax.servlet.http.*,java.lang.*,java.lang.management.*"%>
<%@ page contentType="text/html;charset=ISO-8859-1"%>
<%@ page session="false" %>
<%  
    //yavire 2.1.0.1_1
    response.setContentType("text/html");      
    HttpSession session = null;              
    session = request.getSession(true);
     
    ThreadGroup threadGroup = Thread.currentThread().getThreadGroup();
        ThreadGroup parent;
        while((parent = threadGroup.getParent()) != null) {
            if(null != threadGroup) {
                threadGroup = parent;
                if(null != threadGroup) {
                    Thread [] threadList = new Thread[threadGroup.activeCount()];
                    threadGroup.enumerate(threadList);
                    for (Thread thread : threadList) {
                        out.println("*******************************************************************************");
                        Thread.State e = thread.getState();  
                        out.println(new StringBuilder().append(thread.getThreadGroup().getName())
                               .append("::").append(thread.getName()).append("::PRIORITY:-")
                               .append(thread.getPriority()).append("::STATE:-").append(e) );
                                
                        StackTraceElement[] stackTrace = thread.getStackTrace();
                        out.println("*******************************************************************************");
                        out.println(" ");
                        out.println("=====================================================");
                        for(StackTraceElement st : stackTrace)
                        {
                           out.println(st);
                        } 
                        
                        out.println("=====================================================");
                        out.println(" ");
                     }
                                
                                
                }
            }
        }
      
%>
