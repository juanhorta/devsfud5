/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Enero 26 de 2014
*  Decripción:          Esta clase me permite gestionar el envio de correos electronicos
*  @version:            1.0
* ===================================================================================================================================
**/




public class CL007_Mail_ctr 
{

/** Envia un correo electronico de notificacion a un usuario del sistema
* @param mail  correo electronico 
* @param subject  sujeto del correo electronico
* @param msg  mensaje del correo electronico  
* @return  null. 
**/ 
    Boolean test=false;
    public void sendMail(String mail,String subject,String msg)
    {
     
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { mail});
        email.setSubject(subject);
        email.setPlainTextBody(msg);
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { email });
        if (!results.get(0).isSuccess()) {
            System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
            String errorMessage = results.get(0).getErrors()[0].getMessage();
            System.debug('ERROR '+errorMessage);
        }
        
    }

/** Retorna un mensaje predefinido de notificacion
* @param msgError mensaje de error 
* @return  String . retorna el mensaje de error que se enviara en el correo. 
**/ 
    
    public String getTemplateNotifi(String msgError)
    { 
       String msgNofiticacion =  '';
       msgNofiticacion = msgNofiticacion + ' '+'Buen día; \n\n Alerta!!!  esta es una notificación automatica para Salesforce, \n\nSe presentó un error con el web service:'+' '+msgError;
       
      return msgNofiticacion; 
    }   
    
/** Retorna un mensaje predefinido de notificacion de tarea programada
* @param msgError mensaje de error 
* @return  String . retorna el mensaje de error que se enviara en el correo. 
**/ 
    
    public String getTemplateNotifitask(String msgError)
    { 
       String msgNofiticacion =  '';
       msgNofiticacion = msgNofiticacion + ' '+'Buen día; \n\n Alerta!!!  Esta es una notificación automatica para Salesforce, \n\n La tarea programada ya finalizó: \n\n'+' '+msgError;
       
      return msgNofiticacion; 
    } 
        
    
/** Retorna un  encabezado predefinido del correo
* @param msgError mensaje de error 
* @return  String . retorna el subject del correo. 
**/ 
    public String getTemplateSubject()
    { 
       String Subject =  '';
       Subject = 'Error de conexion con servicio web';
       return Subject; 
      
    } 

/** Retorna un  encabezado predefinido para trabajos programados
* @param msgError mensaje de error 
* @return  String . retorna el subject del correo. 
**/ 
    public String getTemplateSubjectTask()
    { 
       String Subject =  '';
       Subject = 'Resultado de trabajo Programado';
       return Subject; 
      
    }    
    
    
    
    /**
    Esta metodo permite el envio de correo masivos desde uan lsita personalizada
    Ademas de mandar texto plano y HTML.
    **/
    
    public void Activate()
    {
        test=true;
    }
    
    public Boolean sendMail(String[] toAddresses,String bodyhtml,String setReplyTostr,String SenderDisplayName,String strSubject)
    {
        Boolean response=false;
        try
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            System.debug('toAddresses: '+toAddresses);
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setToAddresses(toAddresses);
            // Specify the address used when the recipients reply to the email.
            mail.setReplyTo(setReplyTostr);
            // Specify the name used as the display name.
            mail.setSenderDisplayName(SenderDisplayName);
            // Specify the subject line for your email address.
            mail.setSubject(strSubject);
            // Set to True if you want to BCC yourself on the email.
            mail.setBccSender(false);
            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);
            // Specify the text content of the email.
            mail.setPlainTextBody(bodyhtml);

            mail.setHtmlBody(bodyhtml);
            // Send the email you have created.
            
            if(!test)Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            response=true;
         
        }
        catch(Exception e)
        {
            System.debug('DebugLine 105 : Mail_ctr: Excepcion: '+e.getMessage());
            response=false;
        }
        return response;
    } 
}