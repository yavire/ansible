<%@ page language="java" import="java.io.*,java.net.*,java.util.*,java.lang.Thread,javax.servlet.*,javax.servlet.http.*,java.lang.*,java.lang.management.*"%>
<%@ page contentType="text/html;charset=ISO-8859-1"%>
<%@ page session="false" %>
<% 
    response.setContentType("text/html");      
    HttpSession session = null;              
    session = request.getSession(true);
    RuntimeMXBean bean = ManagementFactory.getRuntimeMXBean();
    ThreadMXBean  beanThread = ManagementFactory.getThreadMXBean();
    MemoryMXBean memBean = ManagementFactory.getMemoryMXBean();
    MemoryUsage heap = memBean.getHeapMemoryUsage();
    MemoryUsage nonHeap = memBean.getNonHeapMemoryUsage();
    
    // Retrieve the four values stored within MemoryUsage:
    // init: Amount of memory in bytes that the JVM initially requests from the OS.
    // used: Amount of memory used.
    // committed: Amount of memory that is committed for the JVM to use.
    // max: Maximum amount of memory that can be used for memory management.
    
    String szOWVersion="3.4.3.1_2";
    String szName = bean.getName();
    String szSpecName = bean.getSpecName();
    String szSpecVendor = bean.getSpecVendor();
    String szSpecVersion = bean.getSpecVersion();
    String classPath = bean.getClassPath();
    String szVMName = bean.getVmName();
    String szVMVendor = bean.getVmVendor();
    String szVMVersion = bean.getVmVersion();
    long upTime = bean.getUptime();
    int threadCount = beanThread.getThreadCount();
    long startTime = bean.getStartTime();
    Date startDate = new Date(startTime); 
    int peakThreadCount = beanThread.getPeakThreadCount();
     
    List<String> inputArguments = ManagementFactory.getRuntimeMXBean().getInputArguments();
    
    out.println("owmVersion= " + szOWVersion + " | ");
    out.println("getName= " + szName + " | ");
    out.println("getSpecName= " + szSpecName + " | ");
    out.println("getSpecVendor= " + szSpecVendor + " | ");
    out.println("getSpecVersion= " + szSpecVersion + " | ");
    out.println("getVmName= " + szVMName + " | ");
    out.println("getVmVendor= " + szVMVendor + " | ");
    out.println("getVmVersion= " + szVMVersion + " | ");
    
    out.println("heapGetInit= " + heap.getInit() + " | ");
    out.println("heapGetUsed= " + heap.getUsed() + " | ");
    out.println("heapGetCommitted= " + heap.getCommitted() + " | ");
    out.println("heapGetMax= " + heap.getMax() + " | ");
    
    out.println("nonHeapGetInit= " + nonHeap.getInit() + " | ");
    out.println("nonHeapGetUsed= " + nonHeap.getUsed() + " | ");
    out.println("nonHeapGetCommitted= " + nonHeap.getCommitted() + " | ");
    out.println("nonHeapGetMax= " + nonHeap.getMax() + " | ");
    
    //out.println(Runtime.getRuntime().totalMemory() + " | ");
    //out.println(Runtime.getRuntime().freeMemory() + " | ");
    //out.println(Runtime.getRuntime().maxMemory() + " | ");
    
    
    out.println("getUptime= " + upTime + " | ");
    out.println("getStartTime= " + startTime + " | ");
    out.println("startDate= " + startDate + " | ");           
    out.println("getThreadCount= " + threadCount + " | ");
    out.println("getPeakThreadCount= " + peakThreadCount + " | ");
    out.println("getClassPath= " + classPath + " | ");
    out.println("getInputArguments= " + inputArguments  + " | ");
    out.println("getTimezone= " + TimeZone.getDefault()  + " | ");
    out.println("availableProcessors= " + Runtime.getRuntime().availableProcessors()  + " | ");
    out.flush();
       
%>
