<%@ page language="java" import="java.io.*,java.util.*,java.net.*,java.lang.*,javax.servlet.*,javax.mail.Message,javax.mail.Session,javax.mail.Transport,javax.mail.internet.InternetAddress,javax.mail.internet.MimeMessage"%>
<%@ page contentType="text/html;charset=ISO-8859-1"%>
<%@ page session="false" %>
<%
   response.setContentType("text/html; charset=ISO8859-15");
   String szDescription = "";
   int iCodError = 0;
   String smtpServer = request.getParameter("smtpServer");
   String from = request.getParameter("from");
   String to = request.getParameter("to");
   String subject = request.getParameter("titulo");
   String body = request.getParameter("body");
   String szVersion = request.getParameter("version");
   String szEvento = request.getParameter("evento");

   System.out.println("yavireSendMail Version 2.1.0.0_3");
   String szFileName = "/opt/krb/yavire/agent/webtools/operaciones/eventos/";

   if (request.getMethod().equals("POST") && request.getHeader("User-Agent").equals("openWeb Monitor"))
   {
      try
      {
         Properties props = System.getProperties();
         InternetAddress[] address =  InternetAddress.parse(to);
         props.put("mail.smtp.host", smtpServer);
         Session session = Session.getDefaultInstance(props, null);
      	   
         System.out.println("Enviando correo del evento "  + szEvento);
      	 System.out.println("Enviando correo a los siguientes destinatarios:  "  + to);
         System.out.println("Enviando correo con el titulo: "  + subject);
         System.out.println("Enviando correo con el mensaje: "  + body);
         System.out.println("Enviando correo desde yavire mensajes : "  + szVersion);
         


         Message msg = new MimeMessage(session);

         msg.setFrom(new InternetAddress(from));
         msg.setRecipients(Message.RecipientType.TO, address);

         msg.setSubject(subject);
         msg.setContent(body,"text/plain");
         msg.setHeader("PRU", "Administracion Web");
         Transport.send(msg);
         System.out.println("Enviando correo del evento "  + szEvento);
         System.out.println("Enviando correo a los siguientes destinatarios:  "  + to);
       }
       catch (javax.mail.SendFailedException senderr)
       {
          System.out.println("Ejecutando sendmail 1");
      //throw new Exception(senderr.getMessage());
       }
       catch (javax.mail.MessagingException senderr)
       {
          System.out.println("Ejecutando sendmail 2");
          //throw new Exception(senderr.getMessage());
       }
       catch (Exception ex)
       {
          System.out.println("Ejecutando sendmail 3");
          //throw new Exception(ex.getMessage());
       }
     }
     
   %><%=iCodError%> <%=szDescription%>
