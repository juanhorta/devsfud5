/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Marzo 28 de 2013
*  Decripción:          Clase que contiene la lógica del llamado al servicio de Masterdata para obtener el cliente unico y su información
*  @version:            1.0
* ===================================================================================================================================
**/

public with sharing class CAllOUT002_MD_GetClienteUnico
{
     // JAR variables para configuracioan del WS   
     //objetos
     public CALLWS002_MD_GetClienteUnico_Object3.PartyBillingInfo objResponseSF;
     public CALLWS002_MD_GetClienteUnico_Object3.Identification objRequestSF; 
     public CALLWS002_MD_GetClienteUnico.BasicHttpBinding_svc_datamanagement_customer_services_1_0_publicar_services_SearchServiceImpl serviceMD;
     public CALLWS002_MD_GetClienteUnico_Object2.GetInfoBillingPartyByIdentification_element valores_datoMd;
     
    
    private Double numCalls; 
    private String email;
    private String endPoint;
    public String strExceptionMessage; 
    public String strTypeException;
    private Boolean sendEmail;
    private Boolean sendNotify;
    public Boolean enableLog;
    public String strMessage;
    public String strErrorWS;
    public Boolean proces;
    public String erroresRA {get; set;} 
    CL007_Mail_ctr sndMail; 
    
    //informacion del response
    public String address;
    public String billing;
    public String cityAddress;
    public String emailMasterdata;
    public Integer telephoneNumber;
    public Integer uniqueCustomer;
    public String cityOriginId;
    
    public CAllOUT002_MD_GetClienteUnico()
    {
    	CallOutSettings__c wsSettings = CallOutSettings__c.getAll().get('CAllOUT002_MD_GetClienteUnico');
        sndMail=new CL007_Mail_ctr();
        this.numCalls = wsSettings.attempts__c;
        this.sendEmail = wsSettings.Email_Notification__c;
        this.sendNotify = wsSettings.Send_Notification__c;
        this.email = wsSettings.Notify__c;
        ServiceMD = new CALLWS002_MD_GetClienteUnico.BasicHttpBinding_svc_datamanagement_customer_services_1_0_publicar_services_SearchServiceImpl();
        ServiceMD.timeout_x = 120000;
        ServiceMD.endpoint_x = wsSettings.EndPoint__c;
        /*Agregamos el enpoint*/ 
        endPoint= wsSettings.EndPoint__c;
        enableLog = wsSettings.Enable_log__c;
        strErrorWS = ''; 
        
        //Inicializo Clases locales que contienen el Request y Response SF del servicio web 
        //pendiente

       //Inicializo Clase  del servicio web 
       objResponseSF = new CALLWS002_MD_GetClienteUnico_Object3.PartyBillingInfo();
       objRequestSF  = new CALLWS002_MD_GetClienteUnico_Object3.Identification();
       valores_datoMd  = new CALLWS002_MD_GetClienteUnico_Object2.GetInfoBillingPartyByIdentification_element();
    }
    
    public CALLWS002_MD_GetClienteUnico_Object3.Identification fnWrapperIdentificationInfo(String strIdentification,String strdocumentType,String strcountry)
    {
    	objRequestSF = new CALLWS002_MD_GetClienteUnico_Object3.Identification(); 
    	
    	if(strdocumentType == 'CC')
    	{
    	   strdocumentType = 'C' ;
    	}else if(strdocumentType == 'NIT')
    	{
    	   strdocumentType = 'N';
    	}else if(strdocumentType == 'CE')
    	{
    	   strdocumentType = 'E';
    	}
    	
    	System.debug('\n\n---->>>>ENTRO_A_fnWrapperIdentificationInfo + documentType \n\n' + strdocumentType);
    	//Consulto el contenido de la identificacion a enviar 
    	objRequestSF.country 		= strcountry;
    	objRequestSF.documentNumber = strIdentification;
    	objRequestSF.documentType 	= strdocumentType;
    	
    	valores_datoMd.identification = objRequestSF;
    	system.debug('mi_objRequestSF  ==>>' +objRequestSF);
    	
    	return objRequestSF;
    	
    }
   
       
   /*
    * Método para Invocar el servcio para adquirir la información de masterdata  
    * @param  objResquestSF request para la consulta  
    * @return objResponseSF respuesta que da el servicio web 
    **/  
    
    public CALLWS002_MD_GetClienteUnico_Object3.PartyBillingInfo invoke (CALLWS002_MD_GetClienteUnico_Object3.Identification objrequest)
	{
	    System.debug('\n\n****Identificacion que consultara en MD === ' + objrequest);
	    if(!Test.isRunningTest())
        {
            objResponseSF = invokeMasterdata(objRequestSF, 1, numCalls);
            System.debug('\n\n****RESPONSE_DEL_SW '+objResponseSF);
        }else
        {
        	System.debug('\n\n****agregar_si_es_clase_de_prueba ');
             
              //acciones a realizar si es clase de prueba ******************************************************************
              //============================================================================================================
              //declaro los objetos del response
            if (objrequest.documentNumber == '80048578')
             { 
	            this.address			= 'Cll pruebas N 001-01';
		       	this.billing			='2555555';
			    this.cityAddress		='02';
			    this.emailMasterdata	='mispruebas@gmail.com';
			    this.telephoneNumber	= 6566666;
			    this.uniqueCustomer		= 12345678;
			    this.cityOriginId 		= '11001';	
             } 
        }
        
      if(objResponseSF <> null)
       {
     	 //El servicio responde correctamente
       
         System.debug('/n/n *** EL SERVICIO TokenTransactionService RETORNO /n/n ' + objResponseSF +'/n/n' );
 
        
         /****************************************************************************************
         /**********************  SECCION DE MAPEO DEL RESPONSE   **************************
         /***************************************************************************************/
         System.debug('/n/n ***_MAPEO.ServiceLead /n/n ' + objResponseSF + '/n/n *** Solicitud_enviada_Masterdata ' ); 
           
 
		this.address			=objResponseSF.address;
	    this.billing			=objResponseSF.billing;
	    this.cityAddress		=objResponseSF.cityAddress;
	    this.emailMasterdata	=objResponseSF.email;
	    this.telephoneNumber	=objResponseSF.telephoneNumber;
	    this.uniqueCustomer		=objResponseSF.uniqueCustomer;
	    this.cityOriginId		=objResponseSF.cityOriginId;
       }else
       {
       	 System.debug('/n/n *** EL SERVICIO_cliente_unico_masterdata_NO_RETORNO_NINGUN_ELEMENTO /n/n '+ objResponseSF+ '/n/n ');
       }
       
        
     return objResponseSF;   
        	
	}
   
  /************************************************************************************************************************ 
    Función invokeMasterdata: Llama el WS en MASTERDATA  para  solicitar la informacion de cliente unico en masterdata  
  *  Si no se puede llamar, intenta hasta el límite de intentos, si falla se notifica el error vía email.
  *  @param objRequestSF 
  *************************************************************************************************************************/   
    public CALLWS002_MD_GetClienteUnico_Object3.PartyBillingInfo invokeMasterdata (CALLWS002_MD_GetClienteUnico_Object3.Identification objRequestSF,  Integer numattempts, double numaCalls)
    {
    	 System.debug('/n/n *** Entro_a_invokeMasterdata_objRequestSF \n\n ' + objRequestSF +'\n\n \n\n ');
    	 
         //llamado al servicio
          CALLWS002_MD_GetClienteUnico_Object3.PartyBillingInfo RstaMasterdata = new CALLWS002_MD_GetClienteUnico_Object3.PartyBillingInfo();
    try
        {
          
          System.debug('\n\n****antes_del_llamado al_WS_en_MASTERDATA: '+ objRequestSF);   
          RstaMasterdata = ServiceMD.GetInfoBillingPartyByIdentification(objRequestSF); 
          
          System.debug('\n\n****despues_del_llamado al_WS_en_MASTERDATA: ' + RstaMasterdata);  
          //-------------------------------------------------
        }catch (System.exception e)
        {
            System.debug('\n\n****Error en comunicacion con el servicio Cliente único Masterdata: '+ e);
            if(numattempts<numaCalls)
            {
                numattempts++;
                RstaMasterdata = invokeMasterdata(objRequestSF, numattempts, numaCalls); 
                System.debug('\n\n****error_intento de conexion n°: '+ numattempts++);
            }
            else
            {
                strErrorWS = 'Se presento el siguiente error en el servicio Cliente único Masterdata: ==>  ' + e.getMessage(); 
                if(sendEmail)
                {
                   //Llamar a notificacion por email y enviar el error con la excepcion ocurrida
                   sndMail.sendMail(email, sndMail.getTemplateSubject(), sndMail.getTemplateNotifi('Respuesta recibida del servicio de Cliente unico de Masterdata' + e.getMessage()));
                }
                if(sendNotify)
                {        
                    //Llamar Servicio Web de Errores
                    strMessage = 'Datos del Request: ' + objRequestSF;
                                    
                    strExceptionMessage = e.getMessage();
                    strTypeException = e.getTypeName();
                   
                }
            }
        }
    
    System.debug('\n\n****RESPUESTA OBTENIDA POR EL SERVICIO de Cliente unico de Masterdata ==>>> '+ RstaMasterdata + '\n\n errores? ' + strExceptionMessage);    
    return RstaMasterdata; 
    }
    
    public void setMsg(integer typeMsg, String message){
            
        if(typeMsg ==null || typeMsg==0){
            Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.INFO,message);
            Apexpages.addMessage(msg);
        }
        
        if(typeMsg==1){
            Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.CONFIRM,message);
            Apexpages.addMessage(msg);
        }

        if(typeMsg==2){
            Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.ERROR,message);
            Apexpages.addMessage(msg);
        }
        
        return;                
   } 
    
    
}