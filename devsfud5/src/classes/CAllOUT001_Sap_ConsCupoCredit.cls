/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Enero 28 de 2013
*  Decripción:          Clase que contiene la lógica del llamado al servicio que genera el chequeo de crédito
*  @version:            1.0
* ===================================================================================================================================
**/

public with sharing class CAllOUT001_Sap_ConsCupoCredit 
{
     // JAR variables para configuracioan del WS    
     
     //objetos
    public CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos objRequestSF {get;set;}
    public CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos objResponseSF {get;set;}
    
    public CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness cwrqSF{get;set;}
    public CL008_Sap_ConsCupoCredit_ObjectsSF.Rating rtSF{get;set;}
    public CL008_Sap_ConsCupoCredit_ObjectsSF.ValidityPeriod vpSF{get;set;}
    public CL008_Sap_ConsCupoCredit_ObjectsSF.RiskClass rcSF{get;set;}
    public CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq rcDP{get;set;}
    public CL008_Sap_ConsCupoCredit_ObjectsSF.CreditorPartyRs rcCP{get;set;}
    public CL008_Sap_ConsCupoCredit_ObjectsSF.SellerPartyRs rcSP{get;set;}
    public CL008_Sap_ConsCupoCredit_ObjectsSF.DTE_CM1_Info_Adicional_CM iaSF{get;set;}
    

    //estructuras request
    public CALLWS001_Sap_ConsCupoCredit_Object1.CreditWorthinessQuery_element valores_datorequ;
    public CALLWS001_Sap_ConsCupoCredit_Object1.DebtorParty_element DatosDebtorParty;
    public CALLWS001_Sap_ConsCupoCredit_Object1.CM1_Info_Adicional_element DatosCM1_Info_Adicional;
    public CALLWS001_Sap_ConsCupoCredit_Object1.DT_CM_Basis DatosDT_CM_Basis;
    public CALLWS001_Sap_ConsCupoCredit_Object1.Productos_element productos; 
    public CALLWS001_Sap_ConsCupoCredit_Object1.Secciones_element Secciones;
    public CALLWS001_Sap_ConsCupoCredit_Object1.CanalRecaudo_element CanalRecaudo;
    public CALLWS001_Sap_ConsCupoCredit_Object1.CanalFacturacion_element CanalFacturacion;
    
    public CALLWS001_Sap_ConsCupoCredit_Object1.Productos_element[] ListaProductos; // pendiente creaar list<>
    public CALLWS001_Sap_ConsCupoCredit_Object1.Secciones_element[] ListaSecciones;
    public CALLWS001_Sap_ConsCupoCredit_Object1.CanalRecaudo_element[] ListaCanalRecaudo;
    public CALLWS001_Sap_ConsCupoCredit_Object1.CanalFacturacion_element[] ListaCanalFacturacion;
    
    
    public CALLWS001_Sap_ConsCupoCredit.BasicHttpBinding_svc_SI_ConsCheq_CupoCredit_Out ServiceSAP;
    public CALLWS001_Sap_ConsCupoCredit_Object1.CreditWorthiness_element response1;
     
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
    
    public CAllOUT001_Sap_ConsCupoCredit()
    {
    
        CallOutSettings__c wsSettings = CallOutSettings__c.getAll().get('CALLWS001_Chequeocredito');
        sndMail=new CL007_Mail_ctr();
        this.numCalls = wsSettings.attempts__c;
        this.sendEmail = wsSettings.Email_Notification__c;
        this.sendNotify = wsSettings.Send_Notification__c;
        this.email = wsSettings.Notify__c;
        ServiceSAP = new CALLWS001_Sap_ConsCupoCredit.BasicHttpBinding_svc_SI_ConsCheq_CupoCredit_Out();
        ServiceSAP.timeout_x = 120000;
        ServiceSAP.endpoint_x = wsSettings.EndPoint__c;
        /*Agregamos el enpoint*/ 
        endPoint= wsSettings.EndPoint__c;
        enableLog = wsSettings.Enable_log__c;
        strErrorWS = ''; 
        
        //Inicializo Clases locales que contienen el Request y Response SF del servicio web 
        //pendiente

       //Inicializo Clase  del servicio web 
       
        valores_datorequ = new CALLWS001_Sap_ConsCupoCredit_Object1.CreditWorthinessQuery_element();
	    DatosDebtorParty = new CALLWS001_Sap_ConsCupoCredit_Object1.DebtorParty_element();
	    DatosCM1_Info_Adicional = new CALLWS001_Sap_ConsCupoCredit_Object1.CM1_Info_Adicional_element();
	    DatosDT_CM_Basis = new CALLWS001_Sap_ConsCupoCredit_Object1.DT_CM_Basis();
	    productos = new CALLWS001_Sap_ConsCupoCredit_Object1.Productos_element(); 
	    Productos = new CALLWS001_Sap_ConsCupoCredit_Object1.Productos_element(); // pendiente creaar list<>
	    Secciones = new CALLWS001_Sap_ConsCupoCredit_Object1.Secciones_element();
	    CanalRecaudo = new CALLWS001_Sap_ConsCupoCredit_Object1.CanalRecaudo_element();
	    CanalFacturacion = new CALLWS001_Sap_ConsCupoCredit_Object1.CanalFacturacion_element();
	    
	    objRequestSF = new  CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos();
    	objResponseSF = new CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos();
        cwrqSF = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness();
    	rtSF = new CL008_Sap_ConsCupoCredit_ObjectsSF.Rating();
    	vpSF = new CL008_Sap_ConsCupoCredit_ObjectsSF.ValidityPeriod();
    	rcSF = new CL008_Sap_ConsCupoCredit_ObjectsSF.RiskClass();
    	rcDP = new CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq();
    	rcCP = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditorPartyRs();
    	rcSP = new CL008_Sap_ConsCupoCredit_ObjectsSF.SellerPartyRs();
	    iaSF = new CL008_Sap_ConsCupoCredit_ObjectsSF.DTE_CM1_Info_Adicional_CM();
	        
   }  

 /*
    * Método para simular  los datos del usuario a Sincronizar con el chequeo de credito  
    * @param CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos request para la consulta  
    * @return ResponseChequearCreditos objResponseSF  respuesta que da el servicio web 
    **/
  public CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos invoke (CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos parRse, Integer numattempts, decimal numaCalls)
	{
		
		CALLWS001_Sap_ConsCupoCredit_Object1.CreditWorthinessQuery_element RqWorthinessSAP  = new CALLWS001_Sap_ConsCupoCredit_Object1.CreditWorthinessQuery_element();
		CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery   worthinessSF = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
	    CALLWS001_Sap_ConsCupoCredit_Object1.CreditWorthiness_element respSap;
		worthinessSF																	=	parRse.parCreditWorthinessQuery;
		system.debug('INICIA EL VOLCADO DEL REQUEST');
		// Volcado del Request de Salesforce al Request de SAP
		if (worthinessSF.creditSegmentInternalID != null){
			RqWorthinessSAP.CreditSegmentInternalID 							= worthinessSF.creditSegmentInternalID;
			system.debug('@@RqWorthinessSAP.CreditSegmentInternalID--> '+RqWorthinessSAP.CreditSegmentInternalID);
		}
		if (worthinessSF.chekedAmount !=null){
			system.debug('worthinessSF.chekedAmount--> '+worthinessSF.chekedAmount);
			RqWorthinessSAP.CheckedAmount 				=   String.valueOf(worthinessSF.chekedAmount.setScale(2));
			RqWorthinessSAP.CurrencyCode 				=	worthinessSF.currencyCode; 
			system.debug('@@RqWorthinessSAP.CheckedAmount--> '+RqWorthinessSAP.CheckedAmount);
			system.debug('@@RqWorthinessSAP.CurrencyCode--> '+RqWorthinessSAP.CurrencyCode);
		}
		
		if (worthinessSF.checkingRuleCode!= null){
			RqWorthinessSAP.CheckingRuleCode									= worthinessSF.checkingRuleCode;
			system.debug('RqWorthinessSAP.CheckingRuleCode--> '+RqWorthinessSAP.CheckingRuleCode);
		}
		
	    if (worthinessSF.checkingSeverityCode!= null){
			system.debug('worthinessSF.checkingSeverityCode--> '+worthinessSF.checkingSeverityCode);
		    RqWorthinessSAP.CheckingSeverityCode	= worthinessSF.checkingSeverityCode;
		   system.debug('@@RqWorthinessSAP.CheckingSeverityCode--> '+RqWorthinessSAP.CheckingSeverityCode);
		}
		
		if (worthinessSF.parCreditAgencyReportRetrievalPermissionIndicator != null){
			try {
				system.debug('parRse.parCreditAgencyReportRetrievalPermissionIndicator--> '+worthinessSF.parCreditAgencyReportRetrievalPermissionIndicator);
				RqWorthinessSAP.CreditAgencyReportRetrievalPermissionIndicator 	= worthinessSF.parCreditAgencyReportRetrievalPermissionIndicator;
			} catch(Exception ex){
					system.debug('parCreditAgencyReportRetrievalPermissionIndicator: ');
					this.setMsg(2,'parCreditAgencyReportRetrievalPermissionIndicator: ');
					return null;			
			}
			system.debug('@@RqWorthinessSAP.CreditAgencyReportRetrievalPermissionIndicator--> '+RqWorthinessSAP.CreditAgencyReportRetrievalPermissionIndicator);
		}
		// armar el DebtorParty
		if (worthinessSF.parDebtorParty.internalId!= null){
			RqWorthinessSAP.DebtorParty  					= new CALLWS001_Sap_ConsCupoCredit_Object1.DebtorParty_element();
			Double valDouble = Double.valueOf(worthinessSF.parDebtorParty.internalId);
			Decimal valDecimal = valDouble;
			RqWorthinessSAP.DebtorParty.InternalID			= String.valueOf(valDecimal.setScale(0));  
			system.debug('@@RqWorthinessSAP.DebtorParty.InternalID--> '+RqWorthinessSAP.DebtorParty.InternalID);
		}
		
		// Volcar CM1_Info_Adicional 
		RqWorthinessSAP.CM1_Info_Adicional					= new CALLWS001_Sap_ConsCupoCredit_Object1.CM1_Info_Adicional_element();
		RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis	    = new CALLWS001_Sap_ConsCupoCredit_Object1.DT_CM_Basis();
	    CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional parRqCM1 		= 	new CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional();
		CL008_Sap_ConsCupoCredit_ObjectsSF.DT_CM_Basis parBasis    			= new CL008_Sap_ConsCupoCredit_ObjectsSF.DT_CM_Basis();
		
		if (worthinessSF.parcm1_Info_Adicional!=null){
			parRqCM1  =	worthinessSF.parcm1_Info_Adicional;
			parBasis  = worthinessSF.parcm1_Info_Adicional.parDT_CM_Basis;
			if (parBasis.organizacionVentas!= null){
				RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.OrganizacionVenta	= 	parBasis.organizacionVentas;
				system.debug('@@RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.OrganizacionVenta--> '+RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.OrganizacionVenta);
			}
		
	    // Hacer el volcado de Productos   
			if (parBasis.productos!=null){
					RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.Productos 	= new List <CALLWS001_Sap_ConsCupoCredit_Object1.Productos_element>();	
					
					List<CL008_Sap_ConsCupoCredit_ObjectsSF.Producto> SFproductos =  parBasis.productos;
					for(CL008_Sap_ConsCupoCredit_ObjectsSF.Producto pr:SFproductos){
					CALLWS001_Sap_ConsCupoCredit_Object1.Productos_element pSapPro = new CALLWS001_Sap_ConsCupoCredit_Object1.Productos_element();
					system.debug('pSapPro.Moneda-->'+pSapPro.Moneda);
					pSapPro.Moneda 						= 	String.valueOf(pr.moneda);
					system.debug('fMaxPrimeraCuota-->'+pSapPro.fMaxPrimeraCuota);
					pSapPro.fMaxPrimeraCuota 			=   String.valueOf(pr.fMaxPrimeraCuota);
					system.debug('fMaxUltimaCuota-->'+pSapPro.fMaxUltimaCuota);
					pSapPro.fMaxUltimaCuota 			=   String.valueOf(pr.fMaxUltimaCuota);
					system.debug('--> pSapPro.Monto'+pSapPro.Monto);
					Decimal valAux=pr.monto;
					pSapPro.Monto						= 	valAux.toPlainString();
					system.debug('$$$$pSapPro.Monto--> '+pSapPro.Monto);
					system.debug('--> pSapPro.Plazo'+pSapPro.Plazo);
					pSapPro.Plazo						= 	String.valueOf(pr.plazo);
					system.debug('--> pSapPro.PorcentajeCuotaInicial'+pSapPro.PorcentajeCuotaInicial);
					pSapPro.PorcentajeCuotaInicial		= 	String.valueOf(pr.porcentajeCuotaInicual);
					system.debug('-->pSapPro.Producto '+pSapPro.Producto);
					pSapPro.Producto					= 	String.valueOf(pr.producto);
					system.debug('pSapPro-->'+pSapPro);
					RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.Productos.add(pSapPro);
				
				}
				system.debug('@@RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.Productos--> '+RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.Productos);
			}
		
			// Hacer el volcado de Secciones
			if (parBasis.secciones!=null){
				RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.Secciones 	= new List <CALLWS001_Sap_ConsCupoCredit_Object1.Secciones_element>();			
				List<CL008_Sap_ConsCupoCredit_ObjectsSF.Seccion> SFsecciones =  parBasis.secciones;
				for(CL008_Sap_ConsCupoCredit_ObjectsSF.Seccion sc:SFsecciones){
					CALLWS001_Sap_ConsCupoCredit_Object1.Secciones_element pSapSecc = new CALLWS001_Sap_ConsCupoCredit_Object1.Secciones_element();
					pSapSecc.IDSeccion = sc.IDSeccion;
					RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.Secciones.add(pSapSecc);
				}
				system.debug('@@RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.Secciones--> '+RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.Secciones);
			}
		
			// Hacer el volcado de Canal Recaudo
			if (parBasis.canalRecaudo!=null){
				RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.CanalRecaudo	   = new List<CALLWS001_Sap_ConsCupoCredit_Object1.CanalRecaudo_element>();
				List<CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo> SFCanRec =  parBasis.canalRecaudo;
				for(CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo cr:SFCanRec){
					CALLWS001_Sap_ConsCupoCredit_Object1.CanalRecaudo_element pSapCanRec = new CALLWS001_Sap_ConsCupoCredit_Object1.CanalRecaudo_element();
					pSapCanRec.IDCanalR = cr.idCanalR;
					RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.CanalRecaudo.add(pSapCanRec);
				}				
		        system.debug('@@RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.CanalRecaudo--> '+RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.CanalRecaudo);
			}   
		
			// Hacer el volcado de Canal Facturación
			if (parBasis.canalFacturacion!=null){
				RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.CanalFacturacion 	= new List<CALLWS001_Sap_ConsCupoCredit_Object1.CanalFacturacion_element>();
				List<CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion> SFCanFac =  parBasis.canalFacturacion;
				for(CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion cf:SFCanFac){
					CALLWS001_Sap_ConsCupoCredit_Object1.CanalFacturacion_element pSapCanFac = new CALLWS001_Sap_ConsCupoCredit_Object1.CanalFacturacion_element();
					pSapCanFac.TipoCanalF = cf.tipoCanalFacturacion;
					RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.CanalFacturacion.add(pSapCanFac);
				}				
		        system.debug('@@RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.CanalFacturacion--> '+RqWorthinessSAP.CM1_Info_Adicional.DT_CM_Basis.CanalFacturacion);
			}
		}
		System.debug('\n\n****INFORMACION ENVIADA AL SERVICIO = \n\n');
        System.debug('\n\n****valores_datof.DateInvoice= ' + parRse);
		System.debug('\n\n****valores_RqWorthinessSAP= ' + '\n\n' + RqWorthinessSAP);
		 
		 if(Test.isRunningTest())
	                      {
	                      	  //clase de prueba
	                      	  system.debug('se_envia_mail_en_clase_de_prueba');
	                      	  this.email = 'joe.ayala@carvajal.com';
	                      
	                      	   sndMail.sendMail(email, sndMail.getTemplateSubject(), sndMail.getTemplateNotifi('error en el servicio web de chequeo de credito: ' ));
		                       strErrorWS = sndMail.getTemplateSubject() + ' ' + 'SAP_CheckAndQuotaCredit ' ;
		                       sndMail.Activate();
	                      }
		
		if(!Test.isRunningTest())
		{
			
	 		try{
	 				system.debug('ENTRE ' + numattempts +  ' VECES A INVOKAR EL SERVICIO');
	 			    system.debug('RqWorthinessSAP--> '+RqWorthinessSAP); 
	 		        respSap = ServiceSAP.OP_ConsCheq_CupoCredit_Out(RqWorthinessSAP); 
				    system.debug('\n\n****SE RECIBE RESPUESTA SATISFACTORIAMENTE '+ respSap + '\n\n');  
				    
	         } catch (Exception e)
	          {   
	         	
	              	 System.debug('\n\n****Error en comunicacion con el servicio web: '+ e);            	               
		             if(numattempts<numaCalls)
		             {
	               	   numattempts++;
	                   system.debug('\n\n****error_intento de conexion n° numattempts--> '+numattempts + '  de -->'+numaCalls ); 
	                   this.invoke(parRse, numattempts, numaCalls); 
		             }
		         else{
		                 //Llamar a notificacion por email y enviar el error con la excepcion ocurrida
	                     if(sendEmail && !Test.isRunningTest()){
		                      sndMail.sendMail(email, sndMail.getTemplateSubject(), sndMail.getTemplateNotifi('error en el servicio web de chequeo de credito: ' + e.getMessage()));
		                      strErrorWS = sndMail.getTemplateSubject() + ' ' + 'SAP_CheckAndQuotaCredit ' + e.getMessage();
	                      }
                       

	                   	
		                system.debug('Error en el servicio web de chequeo de credito '+' Ex: '+e.getMessage());
						this.setMsg(2,'Error en el servicio web de chequeo de credito');
						return null;
		              }
	 		 }    
		
		}else
		{
			//acciones a realizar si es clase de prueba ***********************************
            //============================================================================================================
           System.debug('\n\n****Clase_de_prueba=========================: '); 
           CALLWS001_Sap_ConsCupoCredit_Object1.CreditWorthiness_element valores_test = new CALLWS001_Sap_ConsCupoCredit_Object1.CreditWorthiness_element();
           valores_test.CreditSegmentInternalID = '001';
           valores_test.Indicator = 'false';
           valores_test.DebtorPartyBlockedIndicator = 'false';
           valores_test.DebtorPartySpecialAttentionRequiredIndicator='false';
           valores_test.DynamicCheckHorizonEndDate= '2014-02-05';
           
           CALLWS001_Sap_ConsCupoCredit_Object1.DebtorParty_element DatosDebtorPartytest = new CALLWS001_Sap_ConsCupoCredit_Object1.DebtorParty_element();
           DatosDebtorPartytest.InternalID='00004';
           
           valores_test.DebtorParty = DatosDebtorPartytest;
           
           CALLWS001_Sap_ConsCupoCredit_Object1.Rating_element Ratingtest = new  CALLWS001_Sap_ConsCupoCredit_Object1.Rating_element();
           Ratingtest.Code = '900';
           CALLWS001_Sap_ConsCupoCredit_Object4.DateTimePeriod validityperiodtest = new CALLWS001_Sap_ConsCupoCredit_Object4.DateTimePeriod();
           validityperiodtest.StartDateTime = '2014-03-09T00:00:00Z';
           validityperiodtest.EndDateTime = '2014-03-09T00:00:00Z';
           Ratingtest.ValidityPeriod = validityperiodtest;
           
           valores_test.Rating = Ratingtest;
           
           CALLWS001_Sap_ConsCupoCredit_Object1.RiskClass_element RiskClasstest = new CALLWS001_Sap_ConsCupoCredit_Object1.RiskClass_element();
           RiskClasstest.Code = 'B';
           RiskClasstest.ValidityPeriod = validityperiodtest;
           
           valores_test.RiskClass=RiskClasstest;
           
           CALLWS001_Sap_ConsCupoCredit_Object1.CreditLimit_element CreditLimittest = new CALLWS001_Sap_ConsCupoCredit_Object1.CreditLimit_element();
           CreditLimittest.Amount = '3500000';
           CreditLimittest.currencyCode = 'COP';
           CreditLimittest.ValidityPeriod = validityperiodtest;
           
           valores_test.CreditLimit = CreditLimittest;
           
           CALLWS001_Sap_ConsCupoCredit_Object1.CreditExposure_element CreditExposuretest = new CALLWS001_Sap_ConsCupoCredit_Object1.CreditExposure_element();
           CreditExposuretest.Amount = '3119000';
           CreditExposuretest.currencyCode='COP';
           
           valores_test.CreditExposure = CreditExposuretest;
           
           CALLWS001_Sap_ConsCupoCredit_Object1.DT_CM_Basis_Response DTE_CM1_Info_Adicional_CMtest = new CALLWS001_Sap_ConsCupoCredit_Object1.DT_CM_Basis_Response();
           DTE_CM1_Info_Adicional_CMtest.PermiteExcepcion=true;
           DTE_CM1_Info_Adicional_CMtest.RequiereEstudio = false;
           
           valores_test.DTE_CM1_Info_Adicional_CM = DTE_CM1_Info_Adicional_CMtest;
           
           respSap = valores_test;
           //============================================================================================================
           //para completar cobertura de CALLWS001_Sap_ConsCupoCredit_Object4
           
           CALLWS001_Sap_ConsCupoCredit_Object4.ProductCategoryInternalID ProductCategoryInternaltest = new CALLWS001_Sap_ConsCupoCredit_Object4.ProductCategoryInternalID();
           ProductCategoryInternaltest.schemeID= '123';
           ProductCategoryInternaltest.schemeAgencyID ='123';
           
           CALLWS001_Sap_ConsCupoCredit_Object4.PartyInternalID PartyInternalIDtest = new CALLWS001_Sap_ConsCupoCredit_Object4.PartyInternalID();
           PartyInternalIDtest.schemeID='123';
           PartyInternalIDtest.schemeAgencyID='456';
           
           
           CALLWS001_Sap_ConsCupoCredit_Object4.ExchangeLogData ExchangeLogDatatest = new CALLWS001_Sap_ConsCupoCredit_Object4.ExchangeLogData();
           ExchangeLogDatatest.severity = '458';
           ExchangeLogDatatest.text = '145';
           ExchangeLogDatatest.url = '4564';
           ExchangeLogDatatest.id = '474';
           
           
           CALLWS001_Sap_ConsCupoCredit_Object4.CrdtWrthnsRspCrdtrPty CrdtWrthnsRspCrdtrPtytest= new CALLWS001_Sap_ConsCupoCredit_Object4.CrdtWrthnsRspCrdtrPty();
           CrdtWrthnsRspCrdtrPtytest.InternalID = PartyInternalIDtest;
           
           CALLWS001_Sap_ConsCupoCredit_Object4.DateTimePeriod DateTimePeriodtest= new CALLWS001_Sap_ConsCupoCredit_Object4.DateTimePeriod();
           DateTimePeriodtest.StartDateTime ='456456';
           DateTimePeriodtest.EndDateTime = '1515';
           
           
           CALLWS001_Sap_ConsCupoCredit_Object4.CrdtWrthnsRspSlrPty CrdtWrthnsRspSlrPtytest= new CALLWS001_Sap_ConsCupoCredit_Object4.CrdtWrthnsRspSlrPty(); 
           CrdtWrthnsRspSlrPtytest.InternalID = PartyInternalIDtest;
           
           CALLWS001_Sap_ConsCupoCredit_Object4.CrdtWrthnsRspProdCat CrdtWrthnsRspProdCattest = new CALLWS001_Sap_ConsCupoCredit_Object4.CrdtWrthnsRspProdCat();
           CrdtWrthnsRspProdCattest.InternalID=ProductCategoryInternaltest;
           
           CALLWS001_Sap_ConsCupoCredit_Object4.ExchangeFaultData ExchangeFaultDatatest = new CALLWS001_Sap_ConsCupoCredit_Object4.ExchangeFaultData();
           ExchangeFaultDatatest.faultText = '456456';
           ExchangeFaultDatatest.faultUrl = '45646';
           //============================================================================================================
       
		}
		
		 //Se captura el response del servicio web y se convierte en el Wrraper de SalesForce para mostrar respuesta en la pagina web
		 //*********** pendiente 
		system.debug('respSap--> '+respSap); 
		if (respSap != null )
		{
	        // 1. VERIFICAR EL INDICADOR 
			system.debug('respSap.Indicator--> '+respSap.Indicator);
			if(respSap.Indicator!=null)
			{
				//cwrqSF = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness()----------------
				if(respSap.Indicator == 'true' || respSap.Indicator == 'false' ){
						cwrqSF.indicador	=	Boolean.valueOf(respSap.Indicator); // viene String y es Boolean						
				}else{
					system.debug('Indicator: ' + 'CHEQUEO_CREDITO_No_se_recibe_indicador valido');
					this.setMsg(2,'Indicator: ' + 'CHEQUEO_CREDITO No se recibe indicador valido'); 
					return null;						
				}
			}else{
				system.debug('Indicator: ' + 'CHEQUEO_CREDITO No se recibe indicador');
				this.setMsg(2,'Indicator: ' + 'CHEQUEO_CREDITO No se recibe indicador');
				return null;
			}
			
			// 2. Si las banderas permiteExcepcion y requiereEstudio vienen nulos, se asume que viene en False
			
			//----------CL008_Sap_ConsCupoCredit_ObjectsSF.DTE_CM1_Info_Adicional_CM iaSF -----------------------------
			if(respSap.DTE_CM1_Info_Adicional_CM != null)
			{					
				if(respSap.DTE_CM1_Info_Adicional_CM.PermiteExcepcion != null){
					iaSF.permiteExcepcion  = respSap.DTE_CM1_Info_Adicional_CM.PermiteExcepcion;
				  cwrqSF.permiteExcepcion  = respSap.DTE_CM1_Info_Adicional_CM.PermiteExcepcion; //JAAR AGREGADO PARA LA VISUALIZACION EN LA PAGE
				}else {
					iaSF.permiteExcepcion  = false;
					cwrqSF.permiteExcepcion = false;
				}
				if(respSap.DTE_CM1_Info_Adicional_CM.PermiteExcepcion != null){
					iaSF.requiereEstudio  = respSap.DTE_CM1_Info_Adicional_CM.RequiereEstudio;
					cwrqSF.requiereEstudio =respSap.DTE_CM1_Info_Adicional_CM.RequiereEstudio;
				}else {
					iaSF.requiereEstudio  = false;
					cwrqSF.requiereEstudio = false;
				}
				cwrqSF.parInfo_Adicional_CM = iaSF;
				
			}
			
			if(respSap.CreditSegmentInternalID != null){					
					cwrqSF.creditSegmentInternalid 	= 	respSap.CreditSegmentInternalID;
				}
			
			// 3.Descripcion del os mensajes de reglas de chequeo
			cwrqSF.listCheckingDescription = new List<CL008_Sap_ConsCupoCredit_ObjectsSF.DescripcionMsgRs>();					
			if (respSap.CheckingDescription!=null)
			{
				for(String  ds:respSap.CheckingDescription){ 
					CL008_Sap_ConsCupoCredit_ObjectsSF.DescripcionMsgRs dmsg = new CL008_Sap_ConsCupoCredit_ObjectsSF.DescripcionMsgRs();
					dmsg.mensaje = ds;
					cwrqSF.listCheckingDescription.add(dmsg);
					if (ds != null && ds.contains('ID:')) {
						system.debug('@@cadena-ds -->'+ds);
						integer tam = ds.length();
						string idlogx = ds.substring(3, tam);
						idlogx = idlogx.trim();
						cwrqSF.checkingDescription = idlogx;
					}							 
				}
			}
			system.debug('@cwrqSF.checkingDescription--> '+cwrqSF.checkingDescription);	
			
			// 4. Tomar el dato del debtorbartyBlockedIndicator					
			system.debug('respSap.DebtorPartyBlockedIndicator--> '+respSap.DebtorPartyBlockedIndicator);
		    if(respSap.DebtorPartyBlockedIndicator!=null)
		    {
				if(respSap.DebtorPartyBlockedIndicator == 'true' || respSap.DebtorPartyBlockedIndicator == 'false' ){
						cwrqSF.debtorbartyBlockedIndicator	=	Boolean.valueOf(respSap.DebtorPartyBlockedIndicator); // viene String y es Boolean						
				}else{
					system.debug('DebtorPartyBlockedIndicator: ' + 'CHEQUEO_CREDITO El dato recibido no es valido');
					this.setMsg(2,'DebtorPartyBlockedIndicator: ' +'CHEQUEO_CREDITO El dato recibido no es valido'); 
					return null;						
				}
			}else{
				system.debug('DebtorPartyBlockedIndicator: ' +'CHEQUEO_CREDITO no se recibe información');
				this.setMsg(2,'DebtorPartyBlockedIndicator: ' +'CHEQUEO_CREDITO no se recibe información');
				return null;
			}
		    
		    system.debug('PASO CERO');
			// 5. Tomar el dato del DebtorPartySpecialAttentionRequiredIndicator
			system.debug('respSap.DebtorPartySpecialAttentionRequiredIndicator--> '+respSap.DebtorPartySpecialAttentionRequiredIndicator);
			if(respSap.DebtorPartySpecialAttentionRequiredIndicator!=null){
				if(respSap.DebtorPartySpecialAttentionRequiredIndicator == 'true' || respSap.DebtorPartySpecialAttentionRequiredIndicator == 'false' ){
						cwrqSF.debtorPartySpecialAttentionRequiredIndicator	=	Boolean.valueOf(respSap.DebtorPartySpecialAttentionRequiredIndicator);// viene String y es Boolean						
				}else{
					system.debug('DebtorPartySpecialAttentionRequiredIndicator: ' +'CHEQUEO_CREDITO El dato recibido no es valido');
					this.setMsg(2,'DebtorPartySpecialAttentionRequiredIndicator: ' +'CHEQUEO_CREDITO El dato recibido no es valido'); 
					return null;						
				}
			}else{
				system.debug('DebtorPartySpecialAttentionRequiredIndicator: ' +'CHEQUEO_CREDITO no se recibe información');
				this.setMsg(2,'DebtorPartySpecialAttentionRequiredIndicator: ' +'CHEQUEO_CREDITO no se recibe información');
				return null;
			}
			
			system.debug('PASO UNO');
			// 6. Tomar el valor de DynamicCheckHorizonEndDate
			system.debug('respSap.DynamicCheckHorizonEndDate-->'+respSap.DynamicCheckHorizonEndDate);
			if(respSap.DynamicCheckHorizonEndDate != null)
			{
				try{
					cwrqSF.dynamicCheckHorizonEndDate		= 	Date.valueOf(respSap.DynamicCheckHorizonEndDate);
					system.debug('respSap.DynamicCheckHorizonEndDate--> '+respSap.DynamicCheckHorizonEndDate);
					
				   }catch (Exception ex){
					system.debug('El valor no es valido'+ex.getMessage());
					this.setMsg(2,'El valor de DynamicCheckHorizonEndDate no es valido');
					return null;						
				   }	
			}else
			{
					system.debug('no se recibe inf en el campo DynamicCheckHorizonEndDate ');
			}
			system.debug('PASO DOS');
			// 7.DebtorParty
		    if(respSap.DebtorParty != null){
				cwrqSF.debtorPartyRS = new CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRS();
				cwrqSF.debtorPartyRS.internalId = respSap.DebtorParty.InternalID;
				rcDP.internalId = respSap.DebtorParty.InternalID;
			}
			//CreditLimit		
		    if(respSap.CreditLimit!=null)
		    {				    	
		    	cwrqSF.creditLimit = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditLimit();
		    	if (respSap.CreditLimit.Amount!=null){
		    		cwrqSF.creditLimit.amount = Double.valueOf(respSap.CreditLimit.Amount);
		    	}
		    	cwrqSF.creditLimit.validityPeriod = new CL008_Sap_ConsCupoCredit_ObjectsSF.ValidityPeriod();
		    	if(respSap.CreditLimit.ValidityPeriod.StartDateTime!=null)
		    	{
					system.debug('respSap.CreditLimit.ValidityPeriod.StartDateTime--> '+respSap.CreditLimit.ValidityPeriod.StartDateTime);
					String fechatexto = respSap.CreditLimit.ValidityPeriod.StartDateTime;
					fechatexto=fechatexto.replace('T', ' ');
					fechatexto=fechatexto.replace('Z', ' ');
					cwrqSF.creditLimit.validityPeriod.startDate  	= 	Date.valueOf(respSap.CreditLimit.ValidityPeriod.StartDateTime);	
					
		    	}
		    	if(respSap.CreditLimit.ValidityPeriod.EndDateTime!=null)
		    	{
		    		
					system.debug('respSap.CreditLimit.ValidityPeriod.EndDateTime--> '+respSap.CreditLimit.ValidityPeriod.EndDateTime);
					String fechatexto = respSap.CreditLimit.ValidityPeriod.EndDateTime;
					fechatexto=fechatexto.replace('T', ' ');
					fechatexto=fechatexto.replace('Z', ' ');
					cwrqSF.creditLimit.validityPeriod.endDate  	= 	Date.valueOf(respSap.CreditLimit.ValidityPeriod.EndDateTime);	
				}
		 }
		 
		 	// CreditExposure
			if(respSap.CreditExposure!=null)
			{
				if (respSap.CreditExposure.Amount!=null){
					cwrqSF.parCreditExposure = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditExposure();
					cwrqSF.parCreditExposure.amount=Double.valueOf(respSap.CreditExposure.Amount);
				}
			}
						
		// 11.Rating
		if (respSap.Rating != null)
		{		
			rtSF.validityPeriod = new CL008_Sap_ConsCupoCredit_ObjectsSF.ValidityPeriod();
			cwrqSF.rating = new CL008_Sap_ConsCupoCredit_ObjectsSF.Rating();
			cwrqSF.rating.validityPeriod = new CL008_Sap_ConsCupoCredit_ObjectsSF.ValidityPeriod();
			if (respSap.Rating.Code != null){
				cwrqSF.rating.code = respSap.Rating.Code;
			}else{
				system.debug('Rating Code Value from SAP Invalid');
				this.setMsg(2,'Rating Code Value from SAP Invalid');
				return null;							
			}
			if(respSap.Rating.ValidityPeriod.StartDateTime != null)
			{
			  try {							
					system.debug('respSap.Rating.ValidityPeriod.StartDateTime--> '+respSap.Rating.ValidityPeriod.StartDateTime);
					String fechatexto = respSap.Rating.ValidityPeriod.StartDateTime;
					fechatexto=fechatexto.replace('T', ' ');
					fechatexto=fechatexto.replace('Z', ' ');
					system.debug('fechatexto '+fechatexto);
					Datetime t = datetime.valueOfGmt(fechatexto);
					system.debug('Datetime t-->'+ t);
					Date fecha = Date.newInstance(t.year(),t.month(),t.day());
					system.debug('fecha--> '+fecha);
					rtSF.validityPeriod.startDate 	= 	Date.valueOf(fecha);
					system.debug('rtSF.validityPeriod.endDate--> ');
					
																										
				 }catch(Exception ex){
					system.debug('Rating StartDateTime Value from SAP Invalid');
					this.setMsg(2,'Rating StartDateTime Value from SAP Invalid');
					return null;												
				}
			}
			if(respSap.Rating.ValidityPeriod.EndDateTime != null)
			{
			  try {
					system.debug('respSap.Rating.ValidityPeriod.EndDateTime--> '+respSap.Rating.ValidityPeriod.EndDateTime);
					String fechatexto = respSap.Rating.ValidityPeriod.EndDateTime;
					fechatexto=fechatexto.replace('T', ' ');
					fechatexto=fechatexto.replace('Z', ' ');
					system.debug('fechatexto '+fechatexto);
					Datetime t = datetime.valueOfGmt(fechatexto);
					system.debug('Datetime t-->'+ t);
					Date fecha = Date.newInstance(t.year(),t.month(),t.day());
					system.debug('fecha--> '+fecha);
					rtSF.validityPeriod.endDate 	= 	Date.valueOf(fecha);
					system.debug('rtSF.validityPeriod.endDate--> ');
					
											
				}catch(Exception ex){
					system.debug('Rating EndDateTime Value from SAP Invalid  '+ex.getmessage());
					this.setMsg(2,'Rating EndDateTime Value from SAP Invalid');
					return null;												
				}
			}	
			cwrqSF.rating=	rtSF;																				
		}  	
		
		system.debug('PASO CUATR0');
		// RiskClass
		system.debug('respSap.RiskClass1--> '+respSap.RiskClass);
		if (respSap.RiskClass != null)
		{	
			rcSF.validityPeriod = new CL008_Sap_ConsCupoCredit_ObjectsSF.ValidityPeriod();
			if (respSap.RiskClass.Code != null){
				rcSF.code    = respSap.RiskClass.Code;
			}else{
				system.debug('RiskClass Code Value from SAP Invalid');
									
			}
			if(respSap.RiskClass.ValidityPeriod.StartDateTime != null){
				try {
					rcSF.validityPeriod.startDate   	= Date.valueOf(respSap.RiskClass.ValidityPeriod.StartDateTime);
				}catch(Exception ex){
					system.debug('RiskClass StartDateTime Value from SAP Invalid');
					this.setMsg(2,'RiskClass StartDateTime Value from SAP Invalid');
					return null;												
				}
			}
			system.debug('respSap.RiskClass.ValidityPeriod.EndDateTime--> '+respSap.RiskClass.ValidityPeriod.EndDateTime);
			if(respSap.RiskClass.ValidityPeriod.EndDateTime != null){
				try {
					rcSF.validityPeriod.endDate   	= 	Date.valueOf(respSap.RiskClass.ValidityPeriod.EndDateTime);
				}catch(Exception ex){
					system.debug('RiskClass EndDateTime Value from SAP Invalid');
					this.setMsg(2,'RiskClass EndDateTime Value from SAP Invalid');
					return null;												
				}
			}	
			cwrqSF.riskClass=	rcSF;				
		}		
		
		system.debug('PASO OCHO' + cwrqSF);
		objResponseSF.parCreditWorthiness = cwrqSF;
	} else {
            system.debug('LA RESPUESTA DEL WS ES NULA=======>>>> ');
			this.setMsg(2,'LA RESPUESTA DEL WS ES NULA');
			return null;				
    }
    
	system.debug('@@rsSF--> '+objResponseSF);
	return objResponseSF;
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