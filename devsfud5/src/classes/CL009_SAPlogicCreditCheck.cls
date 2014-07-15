/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Enero 30 de 2013
*  Decripción:          Clase que contiene la lógica para la construcción del request del Chequeo de Credito
*  @version:            1.0
*  @version:            1.1  26-02-2014	JAAR Se realiza modificacion para permitir que sea posible laconsulta del chequeo con o sin datos
										     de facturtación
* ===================================================================================================================================
**/

public with sharing class CL009_SAPlogicCreditCheck
{
     public CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos   rqChequearCred {get;set;}
     public List<CL008_Sap_ConsCupoCredit_ObjectsSF.Producto>           listProducts{get;set;}
     public String Cotizacionid {get;set;}
     public String OperationCode {get;set;}
     public String requestFrom {get;set;}
     public Boolean requestFromsimulation {get;set;}//JAAR Agregado para controlar que se genere la consulta de chequeo asi no tenga datos de fact
     public Boolean requestcupo{get;set;}//JAAR  21-04-2014 validar que el request se realice desde la  cuenta
     List<QuoteLineItem> Listproductos;
     List<QuoteLineItem> listcuotxprodfinancial;
     List<Cuota_facturacion__c> listCuotbyprod;
     List<Dato_facturacion__c> listBDBC; 
     Boolean senalIndicadorSalesReportCheck{get;set;}
     Double valCheck=0;    
     Quote Cotizacion;
     Account cuenta;
     Lead lead;
     User ownerUser;
     CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos rsChequearCred = new CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos();
     map<ID,CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos>     mapRsChequearCred;
     
     public CL009_SAPlogicCreditCheck(String parCotizacionid, String parOperationCode , String parrequestFrom, Boolean parrequestFromsimulation, Boolean parrequestcupo){
        this.Cotizacionid       =   parCotizacionid;
        this.OperationCode      =  parOperationCode;
        this.requestFrom        =  parrequestFrom;
        this.requestFromsimulation = parrequestFromsimulation;
        this.requestcupo = parrequestcupo;
    } 
    
    
    public object proccesCheckCredit(){
        object obj;	
        if(requestcupo == true)
        {
	    	if(requestFrom == 'CUENTA')
  			{
  				this.cuenta = getAccountById(Cotizacionid);
	        	system.debug('esta es la_cuenta_que_se_consulta  ' + cuenta);
	        	if(this.cuenta != null){
		        	mapRsChequearCred   = new map<ID,CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos>();
		        	CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos             rsChequearCred      = new CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos();
			        system.debug('paso1_checkCretidInvoke_from_account_CL009');
			         rsChequearCred = this.checkCretidInvokeaccount(this.cuenta);        // Cargar data en el Request e invocar al WS de Chequeo de Credito
		            if(rsChequearCred != null)
		            {
		            	mapRsChequearCred.put(Cotizacionid,rsChequearCred); 
		            	if(rsChequearCred.parCreditWorthiness.indicador==false)
		                 {
		                   senalIndicadorSalesReportCheck=false;
		                 } 
		                  system.debug('---RETORNA EL MAPA');
		                  return mapRsChequearCred;  
		            }else 
		            {                                                  // posterior evaluacion
		               return null;
		            }	
	        	}
  			}else if(requestFrom == 'LEAD')
  			{
  				//aquiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
  				this.lead = getLeadById(Cotizacionid);
  				system.debug('esta es el_lead_que_se_consulta  ' + lead);
  				if(this.lead != null){
  					mapRsChequearCred   = new map<ID,CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos>();
		        	CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos             rsChequearCred      = new CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos();
			        system.debug('paso1_checkCretidInvoke_from_Lead_CL009');
			        rsChequearCred = this.checkCretidInvokeaccount(this.lead);        // Cargar data en el Request e invocar al WS de Chequeo de Credito
		            if(rsChequearCred != null)
		            {
		            	mapRsChequearCred.put(Cotizacionid,rsChequearCred); 
		            	if(rsChequearCred.parCreditWorthiness.indicador==false)
		                 {
		                   senalIndicadorSalesReportCheck=false;
		                 } 
		                  system.debug('---RETORNA EL MAPA');
		                  return mapRsChequearCred; 
		            }else 
		            {                                                  // posterior evaluacion
		               return null;
		            }	
  				}
  			}
        	
        	
        	
        	
        }else
        {
        	this.Cotizacion = this.getCotizacionById(Cotizacionid);
    	    system.debug('Cotizacion_igual_A====>: '+this.Cotizacion);
	    	if(this.Cotizacion != null){
	    		system.debug('2-Entro_a_ProccesCheckCredit_Cotizacion====>: '+this.Cotizacion);
	            this.Listproductos = new List<QuoteLineItem>();
	            
	            // carga en this.Listproductos los productos de la cotización
	            this.getQuotLnItemByCotizid();
	            
	            //Buscar todos los BillingDataByProposal__c para cada Proposal_Document__c
	            this.listBDBC   = new List<Dato_facturacion__c>();
	            this.listBDBC = this.getListBillingDataBycotizacion(Cotizacionid);
	            system.debug('3-Cotizacion_datos_de_facturacion====>: '+this.listBDBC ); 
	            
		           
	            mapRsChequearCred   = new map<ID,CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos>();
	            CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos             rsChequearCred      = new CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos();
	            system.debug('paso1_checkCretidInvoke_from_CL009');
	            rsChequearCred = this.checkCretidInvoke(this.Cotizacion);        // Cargar data en el Request e invocar al WS de Chequeo de Credito
	            if(rsChequearCred != null)
	            {
	               system.debug('---Paso2_respuesta_del_chequeo_de_credito_rsChequearCred2_en_cl009: '+rsChequearCred);
	               mapRsChequearCred.put(Cotizacionid,rsChequearCred);    // Almacenar la respuesta de cada invocacion en una lista para su evaluacion
	               system.debug('---MAPA_CON:LAS_RESPUESTAS  : '+mapRsChequearCred);
	               if(rsChequearCred.parCreditWorthiness.indicador==false)
	                 {
	                   senalIndicadorSalesReportCheck=false;
	                   //   if(rsChequearCred.parCreditWorthiness.permiteExcepcion==true)
	                   //       System.debug('permiteExcepcion==true');
	                   //--------------------------------------------------------------
	                 }
	                 system.debug('---RETORNA EL MAPA');
	                 return mapRsChequearCred; 
	            }else {                                                  // posterior evaluacion
	               return null;
	            }
	        }
	        
        }
    	
    	return null;
    } 
    
     // Invoke the WS CreditCheck
     public CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos checkCretidInvoke(Quote cotizacion){

        //CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos   rqChequearCred   = new CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos();
        CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos  rsChequearCred = new CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos();
        CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness  rsCreditWorthiness     = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness();

        system.debug('4-$$$mi_cotizacion_para_el_chequeo: '+cotizacion);
     //Configuracion del WS
     //------------------------------------
        CallOutSettings__c wsSettings = CallOutSettings__c.getAll().get('CALLWS001_Chequeocredito');

        rqChequearCred = this.findDataForCretidInvoke(cotizacion);   //  Find Data For WS
        system.debug('\n\n REQUEST_DEL_SERVICIO: '+rqChequearCred + '\n\n');
        if (rqChequearCred != null){
            CAllOUT001_Sap_ConsCupoCredit checkCredit = new CAllOUT001_Sap_ConsCupoCredit();
            rsChequearCred = checkCredit.invoke(rqChequearCred,1,wsSettings.attempts__c);                        // OJO-LRPA: 1.1  Invoke WS Credit Check
            system.debug('\n\n RESPUESTA_DEL_SERVICIO:  '+rsChequearCred + '\n\n');
            rsChequearCred.parCreditWorthiness.nombrePropuestaComercial=cotizacion.Name; 
        } else {
            return null;
        }
        return rsChequearCred;
     }
     
       // Invoke the WS CreditCheck desde la cuenta -------------------------------------------------------------------------
     public CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos checkCretidInvokeaccount(Account cuenta){
        system.debug('entro_a_checkCretidInvokeaccount');
        //CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos   rqChequearCred   = new CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos();
        CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos  rsChequearCred = new CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos();
        CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness  rsCreditWorthiness     = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness();

        system.debug('4-$$$mi_cuenta_para_el_chequeo: '+cuenta);
     //Configuracion del WS
     //------------------------------------
        CallOutSettings__c wsSettings = CallOutSettings__c.getAll().get('CALLWS001_Chequeocredito');

        rqChequearCred = this.findDataForCretidInvokeaccount(cuenta);   //  Find Data For WS
        system.debug('\n\n REQUEST_DEL_SERVICIO: '+rqChequearCred + '\n\n');
        if (rqChequearCred != null){
            CAllOUT001_Sap_ConsCupoCredit checkCredit = new CAllOUT001_Sap_ConsCupoCredit();
            rsChequearCred = checkCredit.invoke(rqChequearCred,1,wsSettings.attempts__c);                        // OJO-LRPA: 1.1  Invoke WS Credit Check
            system.debug('\n\n RESPUESTA_DEL_SERVICIO:  '+rsChequearCred + '\n\n');
            rsChequearCred.parCreditWorthiness.nombrePropuestaComercial=cuenta.Name; 
        } else {
            return null;
        }
        return rsChequearCred;
     }
     
       // Invoke the WS CreditCheck desde el lead -------------------------------------------------------------------------
     public CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos checkCretidInvokeaccount(Lead lead){
        system.debug('entro_a_checkCretidInvokeaccount_para_lead');
        CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos  rsChequearCred = new CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos();
        CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness  rsCreditWorthiness     = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness();

        system.debug('mi_Lead_para_el_chequeo: '+lead);
     //Configuracion del WS
     //------------------------------------
        CallOutSettings__c wsSettings = CallOutSettings__c.getAll().get('CALLWS001_Chequeocredito');

        rqChequearCred = this.findDataForCretidInvokelead(lead);   //  Find Data For WS
        system.debug('\n\n REQUEST_DEL_SERVICIO: '+rqChequearCred + '\n\n');
        if (rqChequearCred != null){
            CAllOUT001_Sap_ConsCupoCredit checkCredit = new CAllOUT001_Sap_ConsCupoCredit();
            rsChequearCred = checkCredit.invoke(rqChequearCred,1,wsSettings.attempts__c);                        // OJO-LRPA: 1.1  Invoke WS Credit Check
            system.debug('\n\n RESPUESTA_DEL_SERVICIO:  '+rsChequearCred + '\n\n');
            rsChequearCred.parCreditWorthiness.nombrePropuestaComercial=lead.Name; 
        } else {
            return null;
        }
        return rsChequearCred;
     }
     
      //=========INVOKE DESDE EL LEAD ==============================================================================
      // Invoke the WS CreditCheck
    public CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos findDataForCretidInvokelead(Lead lead)
    {
        CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos rcc= new CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos();

        // Cargar informacion en el objeto  CreditWorthinessQuery
        CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery cwq= new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
        cwq     =   this.findDataForCreditWorthinessQuerylead();
        rcc.parCreditWorthinessQuery = cwq;

        // Cargar informacion de CM1_Info_Adicional
        CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional cm1InfoAdic= new CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional();
        CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery rpcwq = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
        cm1InfoAdic=this.getDataForCM1_Info_Adicionallead(lead);
        system.debug('cm1InfoAdic_2 '+ cm1InfoAdic);
        if (cm1InfoAdic != null){
        	rpcwq.parcm1_Info_Adicional = cm1InfoAdic;
        }else {
            return null;
        }
        //------------------------------CreditWorthinessQuery----------------------------------------------------
        
        ownerUser = this.getInfoUser(this.lead.OwnerId); // get information of Owner User
        system.debug('$$$ownerUser:'+ownerUser);
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        //se toma el valor de la configuración personalizada
        rpcwq.creditSegmentInternalID =   Utilschequeo.creditSegmentInternalID__c='0001';
        rpcwq.currencyCode            =   Utilschequeo.Moneda__c;   // Moneda
        rpcwq.checkingRuleCode        =   Utilschequeo.checkingRuleCode__c;// Regla de chequeo
        rpcwq.checkingSeverityCode    =   Utilschequeo.checkingSeverityCode__c;// Codigo de severidad
        // Cargar informacion de parCreditAgencyReportRetrievalPermissionIndicator
        rpcwq.parCreditAgencyReportRetrievalPermissionIndicator ='true';
        //------------------------------------------------------------------------------------------------------
        
        
        // Cargar informacion de CM1_Info_Adicional
        CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq debtorPartyRq= new CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq();
        debtorPartyRq   =   this.getDebtorPartyRqlead();
        rpcwq.parDebtorParty = debtorPartyRq;
        //rcc.parDebtorParty = debtorPartyRq;
        
        rcc.parCreditWorthinessQuery = rpcwq; //************igualar este valor al final
        //rcc.parCreditWorthinessQuery = cwq; //jaaaaaaaar123456789
        return rcc;
    }
    //------------------------------------------------------------------------------------------------------------------------------
     
     
     //=========INVOKE DESDE LA CUENTA ==============================================================================
      // Invoke the WS CreditCheck
    public CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos findDataForCretidInvokeaccount(Account cuenta)
    {
        CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos rcc= new CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos();

        // Cargar informacion en el objeto  CreditWorthinessQuery
        CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery cwq= new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
        cwq     =   this.findDataForCreditWorthinessQueryaccount();
        rcc.parCreditWorthinessQuery = cwq;

        // Cargar informacion de CM1_Info_Adicional
        CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional cm1InfoAdic= new CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional();
        CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery rpcwq = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
        cm1InfoAdic=this.getDataForCM1_Info_Adicionalaccount(cuenta);
        system.debug('cm1InfoAdic_2 '+ cm1InfoAdic);
        if (cm1InfoAdic != null){
        	rpcwq.parcm1_Info_Adicional = cm1InfoAdic;
        }else {
            return null;
        }
        //------------------------------CreditWorthinessQuery----------------------------------------------------
        ownerUser = this.getInfoUser(this.cuenta.OwnerId); // get information of Owner User
        system.debug('$$$ownerUser:'+ownerUser);
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        //se toma el valor de la configuración personalizada
        rpcwq.creditSegmentInternalID =   Utilschequeo.creditSegmentInternalID__c='0001';
        rpcwq.currencyCode            =   Utilschequeo.Moneda__c;   // Moneda
        rpcwq.checkingRuleCode        =   Utilschequeo.checkingRuleCode__c;// Regla de chequeo
        rpcwq.checkingSeverityCode    =   Utilschequeo.checkingSeverityCode__c;// Codigo de severidad
        // Cargar informacion de parCreditAgencyReportRetrievalPermissionIndicator
        rpcwq.parCreditAgencyReportRetrievalPermissionIndicator ='true';
        //------------------------------------------------------------------------------------------------------
        
        
        // Cargar informacion de CM1_Info_Adicional
        CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq debtorPartyRq= new CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq();
        debtorPartyRq   =   this.getDebtorPartyRqaccount();
        rpcwq.parDebtorParty = debtorPartyRq;
        //rcc.parDebtorParty = debtorPartyRq;
        
        rcc.parCreditWorthinessQuery = rpcwq; //************igualar este valor al final
        //rcc.parCreditWorthinessQuery = cwq; //jaaaaaaaar123456789
        return rcc;
    }
    //------------------------------------------------------------------------------------------------------------------------------
     
     
     
    
    // Invoke the WS CreditCheck
    public CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos findDataForCretidInvoke(Quote cotizacion)
    {
        CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos rcc= new CL008_Sap_ConsCupoCredit_ObjectsSF.RequestChequearCreditos();

        // Cargar informacion en el objeto  CreditWorthinessQuery
        CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery cwq= new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
        cwq     =   this.findDataForCreditWorthinessQuery();
        rcc.parCreditWorthinessQuery = cwq;

        // Cargar informacion de CM1_Info_Adicional
        CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional cm1InfoAdic= new CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional();
        CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery rpcwq = new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
        cm1InfoAdic=this.getDataForCM1_Info_Adicional(cotizacion);
        system.debug('cm1InfoAdic_2 '+ cm1InfoAdic);
        if (cm1InfoAdic != null){
        	rpcwq.parcm1_Info_Adicional = cm1InfoAdic;
        }else {
            return null;
        }

        
        
        //------------------------------CreditWorthinessQuery----------------------------------------------------
        ownerUser = this.getInfoUser(this.Cotizacion.Opportunity.OwnerId); // get information of Owner User
        system.debug('$$$ownerUser:'+ownerUser);
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        //se toma el valor de la configuración personalizada
        rpcwq.creditSegmentInternalID =   Utilschequeo.creditSegmentInternalID__c='0001';
        rpcwq.chekedAmount            =   (this.Cotizacion.GrandTotal).intValue();    //se envia el total con iva
        system.debug('\n\n@@@@_cwq_chekedAmount--> '+cwq.chekedAmount);
        rpcwq.currencyCode            =   Utilschequeo.Moneda__c;   // Moneda
        rpcwq.checkingRuleCode        =   Utilschequeo.checkingRuleCode__c;// Regla de chequeo
        rpcwq.checkingSeverityCode    =   Utilschequeo.checkingSeverityCode__c;// Codigo de severidad
        // Cargar informacion de parCreditAgencyReportRetrievalPermissionIndicator
        rpcwq.parCreditAgencyReportRetrievalPermissionIndicator ='true';
        //------------------------------------------------------------------------------------------------------
        
        
        // Cargar informacion de CM1_Info_Adicional
        CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq debtorPartyRq= new CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq();
        debtorPartyRq   =   this.getDebtorPartyRq();
        rpcwq.parDebtorParty = debtorPartyRq;
        //rcc.parDebtorParty = debtorPartyRq;
        
        
        
        
        rcc.parCreditWorthinessQuery = rpcwq; //************igualar este valor al final
        //rcc.parCreditWorthinessQuery = cwq; //jaaaaaaaar123456789
        return rcc;
    }
    
    // Cargar informacion en el objeto  CreditWorthinessQuery===================================================================
    public CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery findDataForCreditWorthinessQuery(){
           CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery cwq= new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
           
        ownerUser = this.getInfoUser(this.Cotizacion.Opportunity.OwnerId); // get information of Owner User
        system.debug('$$$ownerUser:'+ownerUser);
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        //se toma el valor de la configuración personalizada
        cwq.creditSegmentInternalID =   Utilschequeo.creditSegmentInternalID__c='0001';
        cwq.chekedAmount            =   (this.Cotizacion.GrandTotal).intValue();   //se envia el total con iva
        system.debug('\n\n@@@@ cwq_chekedAmount--> '+cwq.chekedAmount);
        cwq.currencyCode            =   Utilschequeo.Moneda__c;   // Moneda
        cwq.checkingRuleCode        =   Utilschequeo.checkingRuleCode__c;// Regla de chequeo
        cwq.checkingSeverityCode    =   Utilschequeo.checkingSeverityCode__c;// Codigo de severidad
         system.debug('\n\n--> Info_CreditWorthinessQuery '+cwq);
        return cwq;
    }
    
    // Cargar informacion en el objeto  CreditWorthinessQuery desde la cuenta=============================================================
    public CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery findDataForCreditWorthinessQueryaccount(){
           CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery cwq= new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
           
        ownerUser = this.getInfoUser(this.cuenta.OwnerId); // get information of Owner User
        system.debug('$$$ownerUser:'+ownerUser);
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        //se toma el valor de la configuración personalizada
        cwq.creditSegmentInternalID =   Utilschequeo.creditSegmentInternalID__c='0001';
        //no va valor para cuenta -- cwq.chekedAmount            =   (this.Cotizacion.GrandTotal).intValue();   
     
        cwq.currencyCode            =   Utilschequeo.Moneda__c;   // Moneda
        cwq.checkingRuleCode        =   Utilschequeo.checkingRuleCode__c;// Regla de chequeo
        cwq.checkingSeverityCode    =   Utilschequeo.checkingSeverityCode__c;// Codigo de severidad
         system.debug('\n\n--> Info_CreditWorthinessQuery '+cwq);
        return cwq;
    }
    
     // Cargar informacion en el objeto  CreditWorthinessQuery desde el lead=============================================================
    public CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery findDataForCreditWorthinessQuerylead(){
           CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery cwq= new CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthinessQuery();
           
        ownerUser = this.getInfoUser(this.lead.OwnerId); // get information of Owner User
        system.debug('$$$ownerUser:'+ownerUser);
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        //se toma el valor de la configuración personalizada
        cwq.creditSegmentInternalID =   Utilschequeo.creditSegmentInternalID__c='0001';
        //no va valor para cuenta -- cwq.chekedAmount            =   (this.Cotizacion.GrandTotal).intValue();   
     
        cwq.currencyCode            =   Utilschequeo.Moneda__c;   // Moneda
        cwq.checkingRuleCode        =   Utilschequeo.checkingRuleCode__c;// Regla de chequeo
        cwq.checkingSeverityCode    =   Utilschequeo.checkingSeverityCode__c;// Codigo de severidad
         system.debug('\n\n--> Info_CreditWorthinessQuery '+cwq);
        return cwq;
    }
    
    // Cargar informacion en el objeto  CreditWorthinessQuery account===============================================================================
    public CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq getDebtorPartyRqaccount(){
        CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq dpRq= new CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq();
        system.debug('DebtorPartyRq_cuenta: '+this.cuenta.id);
        dpRq.internalId = String.valueOf(this.cuenta.Codigo_cliente_unico__c);
        return dpRq;
    }
    
     // Cargar informacion en el objeto  CreditWorthinessQuery Lead===============================================================================
    public CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq getDebtorPartyRqlead(){
        CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq dpRq= new CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq();
        system.debug('DebtorPartyRq_lead: '+this.lead.id);
        dpRq.internalId = String.valueOf(this.lead.Codigo_cliente_unico__c);
        return dpRq;
    }
    
        // Cargar informacion en el objeto  CreditWorthinessQuery
    public CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq getDebtorPartyRq(){
        CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq dpRq= new CL008_Sap_ConsCupoCredit_ObjectsSF.DebtorPartyRq();
        system.debug('cotizacion: '+this.Cotizacion.id);
        system.debug('$$$this.cotizacion.Opportunity.AccountId: '+this.Cotizacion.Opportunity.AccountId);
        system.debug('$$$this.Cotizacion.Opportunity.Account.Codigo_cliente_unico__c: '+this.Cotizacion.Opportunity.Account.Codigo_cliente_unico__c);
        system.debug('$$$String.valueOf(this.Cotizacion.Opportunity.AccountId): '+String.valueOf(this.Cotizacion.Opportunity.AccountId));
        dpRq.internalId = String.valueOf(this.Cotizacion.Opportunity.Account.Codigo_cliente_unico__c);
        return dpRq;
    }
    
    
    
        // Cargar informacion de CM1_Info_Adicional ============================================================================
   public CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional getDataForCM1_Info_Adicional(Quote cotizacion)
   {
        CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional cm1InfoAd= new CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional();
        CL008_Sap_ConsCupoCredit_ObjectsSF.DT_CM_Basis DT_CM_Basis = new CL008_Sap_ConsCupoCredit_ObjectsSF.DT_CM_Basis();
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        DT_CM_Basis.organizacionVentas  =  Utilschequeo.organizacionVentas__c; //temporalemnte en configuracion personalizada debe estar en el user 
        //cm1InfoAd.organizacionVentas    =  Utilschequeo.organizacionVentas; //temporalemnte en configuracion personalizada debe estar en el user
        
        
        
        // Obtencion de la lista de Productos
        Map <String, CL008_Sap_ConsCupoCredit_ObjectsSF.Producto>   mapProducts = new Map<String, CL008_Sap_ConsCupoCredit_ObjectsSF.Producto>();
        listProducts = new List<CL008_Sap_ConsCupoCredit_ObjectsSF.Producto>();
        mapProducts                     =   this.getMapProducts(cotizacion);             // Maps de productos
        
        if (mapProducts!= null){
            system.debug('@@mapProducts--> '+mapProducts);
        }

        if(mapProducts != null){
            listProducts                    =   mapProducts.values();               // Obtener List de productos
            DT_CM_Basis.productos           =   listProducts;                       // Asignar lista de productos al Request del WS
            //cm1InfoAd.productos             =   listProducts;                       // Asignar lista de productos al Request del WS
            
            
            
            system.debug('@@DT_CM_Basis.productos --> '+DT_CM_Basis.productos );
        }else {
            return null;
        }



        // Obtencion de la lista de Canales de Recaudo
        Map <String, CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo>   mapCanalReacudos = new Map<String, CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo>();
        List<CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo>           listCanalRecaudos = new List<CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo>();
        mapCanalReacudos                    =   this.getMapCanalReacudos(cotizacion);         // Maps de Canales de Recaudo
        listCanalRecaudos                   =   mapCanalReacudos.values();          // Obtener List de Canales de Recaudo
        //cm1InfoAd.canalRecaudo              =   listCanalRecaudos;                  // Asignar lista de Canales de Recaudo al Request del WS
        DT_CM_Basis.canalRecaudo            =   listCanalRecaudos;                  // Asignar lista de Canales de Recaudo al Request del WS

        // Obtencion de la lista de Canlaes Facturacion
        Map <String, CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion>   mapCanalesFacturacion = new Map<String, CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion>();
        List<CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion>           listCanalesFacturacion = new List<CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion>();
        mapCanalesFacturacion                   =   this.getMapCanalFacturacion(cotizacion);          // Maps de Canales de Facturacion
        listCanalesFacturacion                  =   mapCanalesFacturacion.values();         // Obtener List de Canales de Facturacion
        //cm1InfoAd.canalFacturacion              =   listCanalesFacturacion;                 // Asignar lista de Canales de Facturacion al Request del WS
        DT_CM_Basis.canalFacturacion            =   listCanalesFacturacion;                 // Asignar lista de Canales de Facturacion al Request del WS
        cm1InfoAd.parDT_CM_Basis = DT_CM_Basis; //igualar al final
        system.debug('cm1InfoAd_parDT_CM_Basis_1 '+cm1InfoAd.parDT_CM_Basis);
        return cm1InfoAd;
    }
    
 
   // Cargar informacion de CM1_Info_Adicional de la cuenta ============================================================================
   public CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional getDataForCM1_Info_Adicionalaccount(Account cuenta)
   {
        CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional cm1InfoAd= new CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional();
        CL008_Sap_ConsCupoCredit_ObjectsSF.DT_CM_Basis DT_CM_Basis = new CL008_Sap_ConsCupoCredit_ObjectsSF.DT_CM_Basis();
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        DT_CM_Basis.organizacionVentas  =  Utilschequeo.organizacionVentas__c; //temporalemnte en configuracion personalizada debe estar en el user 
        
        cm1InfoAd.parDT_CM_Basis = DT_CM_Basis; //igualar al final
        system.debug('cm1InfoAd_parDT_CM_Basis_1 '+cm1InfoAd.parDT_CM_Basis);
        return cm1InfoAd;
    }   
    
    
    // Cargar informacion de CM1_Info_Adicional del Lead ============================================================================
   public CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional getDataForCM1_Info_Adicionallead(Lead lead)
   {
        CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional cm1InfoAd= new CL008_Sap_ConsCupoCredit_ObjectsSF.CM1_Info_Adicional();
        CL008_Sap_ConsCupoCredit_ObjectsSF.DT_CM_Basis DT_CM_Basis = new CL008_Sap_ConsCupoCredit_ObjectsSF.DT_CM_Basis();
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        DT_CM_Basis.organizacionVentas  =  Utilschequeo.organizacionVentas__c; //temporalemnte en configuracion personalizada debe estar en el user 
        
        cm1InfoAd.parDT_CM_Basis = DT_CM_Basis; //igualar al final
        system.debug('cm1InfoAd_parDT_CM_Basis_1 '+cm1InfoAd.parDT_CM_Basis);
        return cm1InfoAd;
    }  
 //---------------------------------------------------------------------------------------------------------------------------------------   
    
    // get the Product List
    public map <String,CL008_Sap_ConsCupoCredit_ObjectsSF.Producto> getMapProducts(Quote cotizacion){

        Map <String, CL008_Sap_ConsCupoCredit_ObjectsSF.Producto> mapProducts   = new Map<String, CL008_Sap_ConsCupoCredit_ObjectsSF.Producto>();
        CL008_Sap_ConsCupoCredit_ObjectsSF.Producto                 producto    = new CL008_Sap_ConsCupoCredit_ObjectsSF.Producto();
        Double valTotalProductoscotizac=0;

        List<QuoteLineItem> listPPSearch = new List<QuoteLineItem>();
        listPPSearch = this.Listproductos;

        valTotalProductoscotizac=0;
        for( QuoteLineItem pp: this.Listproductos ){                                             
            if (pp.QuoteId == cotizacion.id ){                                       //obtener el valor total de todos los productos
                valTotalProductoscotizac=valTotalProductoscotizac+pp.TotalPrice;
            }
        }



        for( QuoteLineItem pp: this.Listproductos ){                                                // Iterar la lista de Proposal_Products__c para obtener la lista de Productos.
            system.debug('Obtener_el_codigo_financiero: '+pp.PricebookEntry.Product2.Producto_financiero__c);
            if (pp.QuoteId == cotizacion.id ){                                             // Solo los productos de la propuesta en cuestion
                if(!mapProducts.containsKey(pp.PricebookEntry.Product2.Producto_financiero__c)){
                    String codfinancial = pp.PricebookEntry.Product2.Producto_financiero__c;
                    system.debug('\n\n ProposalProduc--> '+pp);
                    producto = this.getOneProduc(pp,listPPSearch,cotizacion,valTotalProductoscotizac,codfinancial);
                    system.debug('@@ quote_producto--> '+producto);
                    if(producto != null){
                        mapProducts.put(producto.producto,producto);
                    } else {
                        return null;
                    }

                }
            }
        }
        system.debug('Retorno_de_mapProducts--> '+mapProducts);
        return mapProducts;

    }
    
    
    // get one  Product ================================================================================================
    public CL008_Sap_ConsCupoCredit_ObjectsSF.Producto getOneProduc(QuoteLineItem parPp,
                                                                    List<QuoteLineItem> parListPPSearch,
                                                                    Quote parPd,
                                                                    Double parValTotalProductosPropuesta,String codigofinanc){

        CL008_Sap_ConsCupoCredit_ObjectsSF.Producto product     = new CL008_Sap_ConsCupoCredit_ObjectsSF.Producto();
        Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
        Decimal plazo=0;
        Double cuotaInicial=0;
        Double monto=0;
        String moneda='';
        Date fecMaxPrimCuota = system.now().date()-1900;
        Date fecMaxUltCuota= system.now().date()-1900;
        product.producto = parPp.PricebookEntry.Product2.Producto_financiero__c;
        system.debug('1. cant_productos_parListPPSearch.size(): '+parListPPSearch.size());
        for( QuoteLineItem pp: parListPPSearch ){
            system.debug('2_Entre for_Proposal_Products__c_pp');
            moneda= Utilschequeo.Moneda__c;   // Moneda
            if(parPp.PricebookEntry.Product2.Producto_financiero__c == pp.PricebookEntry.Product2.Producto_financiero__c){
                monto   =   monto   +   pp.TotalPrice;
                system.debug('iparPp_FinancialCode__new   '+parPp.PricebookEntry.Product2.Producto_financiero__c);
                system.debug('3_pp_FinancialCode__c) '     +pp.PricebookEntry.Product2.Producto_financiero__c);
                //system.debug('numero_de_datos_de_fact '+ this.listBDBC.size());
            
            }
        }
        //lista de productos con el mismo cod financiero donde el cod = al codigofinanc
          listcuotxprodfinancial  = new list<QuoteLineItem>();
          
          //***Se le envia el cod financiero y el prod por cotizacion
          listcuotxprodfinancial = cuotxprodfinancial(parPd.id,codigofinanc); 
          
        //JAAR-25-02-2014 123
        system.debug('Es_una_simulacion_de_cheqeo? '+this.requestFromsimulation);
        if(listBDBC <> null)
         {
          
         	for(Dato_facturacion__c bdbp:this.listBDBC)
	        {
	            system.debug('4_bdbp_Presupuesto__c  ' +bdbp.Presupuesto__c);
	            system.debug('4_cuote_id  ' + parPd.id);
	            if(bdbp.Presupuesto__c == parPd.id)
	            {
	               system.debug('5.  if(bdbp_Presupuesto__c == parPp.id)');
	                // Busca el plazo mas alto entre todos los BillingDataByProposal__c de la Proposal_Products__c
	               for(QuoteLineItem prod: this.listcuotxprodfinancial)
		           {
		           	  	system.debug('mi_listcuotxprodfinancial  ' + listcuotxprodfinancial);
		           	  	//JAAR lista para definir las cuotas por producto
	                	listCuotbyprod = new List<Cuota_facturacion__c>();
	                	system.debug('prod.id__id  ' + prod.id);
	                	listCuotbyprod = Cuotbyprod(bdbp.id,prod.id);
	                	system.debug('result_listCuotbyprod  ' + listCuotbyprod);
	                	if(listCuotbyprod<>null)//si el producto tiene cuotas se vefrifica si aumenta el plazo max por prod financiero
	                	{
	                		if(listCuotbyprod.size() > plazo)
	                		{
	                    		plazo=listCuotbyprod.size();
	                    	}
	                	}else
	                	{
	                		system.debug('El_producto '+prod.id + 'no_tiene_cuotas');
	                	}
	                	//JAAR se agrega linea de produccion para visualizarla en la consulta
	                	product.Lineaproduccion = prod.PricebookEntry.Product2.Linea_de_produccion__c;
	                	system.debug('Lineaproduccion_por_prod_financiero  ' + product.Lineaproduccion );
		           }
	               
	            }
	             if (fecMaxPrimCuota< bdbp.Fecha_primera_cuota__c)
	                fecMaxPrimCuota= bdbp.Fecha_primera_cuota__c;
	                
	             for (Integer i = 0; bdbp.Cuotas_facturacion__r.size()>i ; i++ )
	             {  
	               
	                if (bdbp.Cuotas_facturacion__r.get(i).No_Cuota__c==bdbp.Numero_cuotas__c)
	                {
	                    system.debug('cuota '+bdbp.Cuotas_facturacion__r.get(i).No_Cuota__c);
	                    system.debug('cuota (i)'+ bdbp.Cuotas_facturacion__r.get(i).Fecha_cuota__c);
	                    if (fecMaxUltCuota< bdbp.Cuotas_facturacion__r.get(i).Fecha_cuota__c)
	                    fecMaxUltCuota= bdbp.Cuotas_facturacion__r.get(i).Fecha_cuota__c;
	                } 
	       
	            }
	        }
	        
         }else
         {	
         	if(this.requestFromsimulation== true)
         	{
         		system.debug('buscara_la_informacion_solo_de_productos===SIMULACION==SIMULACION==SIMULACION==SIMULACION ');
         		for(QuoteLineItem prod: this.listcuotxprodfinancial)
		           {
		           	  	system.debug('mi_listcuotxprodfinancial_2  ' + listcuotxprodfinancial);
		           	  	//JAAR el numero de cuotas se sacará del producto si no tiene datos de facturación
	                	system.debug('prod.id__id_2  ' + prod.id);
	                	//listCuotbyprod = Cuotbyprod(bdbp.id,prod.id); deprecada para esta opcion
	                	if(prod.Numberquota__c <> null)
	                	{
	                		if(prod.Numberquota__c > plazo)
	                		plazo=prod.Numberquota__c;
	                	}else
	                	{
	                		if(prod.PricebookEntry.Product2.Numero_cuotas_maximo__c <>null)
	                	    {
		                	   if(prod.PricebookEntry.Product2.Numero_cuotas_maximo__c > plazo)
		                	   {
		                	   	 plazo= prod.PricebookEntry.Product2.Numero_cuotas_maximo__c;
		                	   }
		                	}else
		                	{
		                		system.debug('No_tiene_ningun_parametro_de_donde_sacar_el_numero_de_cuotas');
		                	}
	                	} 
	                	
	                	system.debug('plazo_por_cod_financiero: ' + plazo + 'cod_financiero' + prod.PricebookEntry.Product2.Producto_financiero__c);
	                	
	                	//26-02-2014	JAAR se agrega linea de produccion para visualizarla en la consulta
	                	product.Lineaproduccion = prod.PricebookEntry.Product2.Linea_de_produccion__c;
	                	system.debug('Lineaproduccion_por_prod_financiero  ' + product.Lineaproduccion );
	                	
	                	
		           }
		           //si no tiene datos de facturacion la fecha se sacara de la fecha en la que realiza la consulta
		           fecMaxPrimCuota= system.today();
		           system.debug('fecMaxPrimCuota '+fecMaxPrimCuota);
		           fecMaxUltCuota= fecMaxPrimCuota.addMonths(integer.valueof(plazo));
		      //===============================================================================================================     
         	}
         }
      
	        
         
        String stringFecMaxPrimCuota = String.valueOf(fecMaxPrimCuota);
        stringFecMaxPrimCuota = stringFecMaxPrimCuota.replace('-','');
        String stringfecMaxUltCuota = String.valueOf(fecMaxUltCuota);
        stringfecMaxUltCuota = stringfecMaxUltCuota.replace('-','');
        system.debug('fecMaxPrimCuota: '+stringFecMaxPrimCuota);
        
        system.debug('fecMaxUltCuota: '+stringfecMaxUltCuota);

        product.plazo   =   plazo;
        product.monto   =   monto;
        product.moneda  =   moneda; 
        product.porcentajeCuotaInicual=0; 
        product.fMaxPrimeraCuota = stringFecMaxPrimCuota;      //APMD
        product.fMaxUltimaCuota = stringfecMaxUltCuota;        //APMD
        system.debug('%%%cuotaInicial: '+cuotaInicial);
        system.debug('%%%parValTotalProductosPropuesta: '+parValTotalProductosPropuesta);

        
        system.debug('###product.plazo:'+plazo + '    product.monto: '+product.monto+'  product.porcentajeCuotaInicual:'+product.porcentajeCuotaInicual);

        return product;
    }
    
    
    
    // get the Canal Recaudos List
    public map <String,CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo> getMapCanalReacudos(Quote parPd){

        Map <String, CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo> mapCanalReacudos  = new Map<String, CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo>();

        Boolean senal=false;
        // Iterar la lista de Proposal_Products__c para obtener la lista de Productos.
   
            system.debug('@@@_this_listBDBC_2-->'+this.listBDBC);
            //si es una simulacion de chequeo sin datos de faturacion se enviara como parametro FACTURA DIRECTA
            if(this.listBDBC <> null )
            {
		            
	            for(Dato_facturacion__c bdbp : this.listBDBC) {
	                system.debug('Entre_a_ciclo_Dato_facturacion__c');
	                system.debug('22bdbp.cotizacion--> '+bdbp.Presupuesto__c);
	                system.debug('22parPd.id--> '+parPd.id);
	                if(bdbp.Presupuesto__c== parPd.id ) {
	                    senal=true;
	                    system.debug('22bdbp.Agente_recaudo__c--> '+bdbp.Agente_recaudo__c);
	                    CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo canalReacudos = new CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo();
	                    if(bdbp.Agente_recaudo__c == 'FACTURA DIRECTA')
	                    {
	                    	canalReacudos.idCanalR = 'F';
	                    }else if(bdbp.Agente_recaudo__c == 'CODENSA')
	                    {
	                    	canalReacudos.idCanalR = 'O';
	                    }
	                   
	                    mapCanalReacudos.put(canalreacudos.idCanalR,canalreacudos);
	                }
	
	            }
	   
	          if (senal==false){
	            System.debug('###cotizacion no tiene Datos de Facturacion');
	            this.setMsg(2, ' la cotizacion no tiene datos de facturacion');
	            return null;
	          }
	          
            } else
            {
                if(requestFromsimulation == true)
                {
                	CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo canalReacudos = new CL008_Sap_ConsCupoCredit_ObjectsSF.CanalRecaudo();
            	    canalReacudos.idCanalR = 'F';
            	    mapCanalReacudos.put(canalreacudos.idCanalR,canalreacudos);
                }
            	
            }     
        return mapCanalreacudos;
    }
    
       public map <String,CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion> getMapCanalFacturacion(Quote parPd){

        Map <String, CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion> mapCanalFacturacion   = new Map<String, CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion>();
        CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion                 canalFacturacion;
        // Iterar la lista de Productos para obtener la lista de Productos.
        system.debug('@@@this.listBDBP33-->'+this.listBDBC);
        //26-02-2014	JAAR Si es una simulacion de chequeo de crédito y no tiene datos de facturación se enviará el canal de fact = 1
        if(this.listBDBC <> null)
        {
        	for(Dato_facturacion__c bdbp : this.listBDBC) {
                system.debug('Entre a ciclo Dato_facturacion__c');
                system.debug('bdbp.Presupuesto__c--> '+bdbp.Presupuesto__c);
                system.debug('parPd.id--> '+parPd.id);
                if(bdbp.Presupuesto__c== parPd.id ) {
                    system.debug('tipoCanalFacturacion--> ');
                    canalFacturacion    = new CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion();
                    canalFacturacion.tipoCanalFacturacion='1';
                    mapCanalFacturacion.put(canalFacturacion.tipoCanalFacturacion,canalFacturacion);
                }

            }
        }else
        {
        	 if(requestFromsimulation == true)
        	 {
        	 	canalFacturacion    = new CL008_Sap_ConsCupoCredit_ObjectsSF.CanalFacturacion();
                canalFacturacion.tipoCanalFacturacion='1';
                mapCanalFacturacion.put(canalFacturacion.tipoCanalFacturacion,canalFacturacion);
        	 }
        	
        }
            
        return mapCanalFacturacion;
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

        //return;

    }


    public void message(){
        Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.Info,' idAccount=');
        Apexpages.addMessage( msg );
    } 
    
    
    
    /**********************************************************************************
    *           						QUERY AREA
    **********************************************************************************/
        public Quote getCotizacionById(String idCotizacion){

        List<Quote> Cotizac =  [SELECT Ciudad_venta__c,GrandTotal,Id,Name,OpportunityId,Opportunity.Account.Codigo_cuenta__c,Opportunity.OwnerId,
        						Opportunity.Account.Codigo_cliente_unico__c,Opportunity.AccountId,TotalPrice 
        						FROM Quote 
                                where Id =:CotizacionId];

         if(Cotizac.size()>0){
            system.debug('###Cotizacion====>: '+Cotizac);
            return Cotizac.get(0);
        }else{
            return null;
        }
    }
    
    /******************get QuoteLineItem for Cotizacion  ***************************/
    public void getQuotLnItemByCotizid ()
    {
         this.Listproductos    =[SELECT Id,PricebookEntryId,PricebookEntry.Product2.Producto_financiero__c, QuoteId,TotalPrice,UnitPrice FROM QuoteLineItem
         						 WHERE QuoteId =: CotizacionId];
    }
    
   
   /**********Tomar los Datos de Facturacion por Propuesta)*************************/
    public List<Dato_facturacion__c> getListBillingDataBycotizacion(String idCotizacion){
        
         List<Dato_facturacion__c>     listBDBC = new List<Dato_facturacion__c>();

                                     listBDBC   = [SELECT Agente_facturacion__c,Agente_recaudo__c,Ciudad_facturacion__c,Ciudad_telefono_facturacion__c,Correo_facturacion__c,
                                                          Direccion_facturacion__c,Fecha_primera_cuota__c,Id,Numero_cuotas__c,Numero_identificacion__c,Presupuesto__c,Razon_social__c,
                                                          Valor_facturacion__c, (SELECT Dato_facturacion__c,Fecha_cuota__c,Id,Name,No_Cuota__c,Partida_de_presupuesto__c,Valor_cuota__c FROM Cuotas_facturacion__r)
          										   FROM Dato_facturacion__c WHERE Presupuesto__c =: CotizacionId];
         
        if(listBDBC.size()>0){
            return listBDBC;
        }else{
            return null;
        }

    }
   
      /*******************************Owner User Information  *********************/
    public User getInfoUser (Id idUser)
    {
        List<User> listUser=[SELECT City,Email,Id,Id_nomina__c,Name,Regional__c FROM User
                             where id=: idUser  limit 1];

        if(listUser.size()>0){
            return listUser.get(0);
        }else{
            return null;
        }
    }
    /*******************************Info cuotas por prod  *********************/
    public List<Cuota_facturacion__c>  Cuotbyprod (String Datofact, String product )
     {
     	List<Cuota_facturacion__c> listcuotbyprod = [SELECT Dato_facturacion__c,Fecha_cuota__c,Id,No_Cuota__c,Partida_de_presupuesto__c,Valor_cuota__c 
											     	FROM Cuota_facturacion__c 
											     	WHERE Dato_facturacion__c = :Datofact
											     	AND Partida_de_presupuesto__c =: product];
     if(listcuotbyprod.size()>0){
            return listcuotbyprod;
        }else{
            return null;
        }
     }
     /*******************************Info cuotas por prod fincanciero  *********************/
   public List<QuoteLineItem> cuotxprodfinancial(String cotizacionid, String prodfinancial)
    {
       List<QuoteLineItem> listprodfinancial=[SELECT Id,Numberquota__c,PricebookEntry.Product2.Producto_financiero__c,
											         PricebookEntry.Product2.Linea_de_produccion__c,											  PricebookEntry.Product2.Numero_cuotas_maximo__c,QuoteId 
											  FROM   QuoteLineItem WHERE QuoteId =: cotizacionid
                                              AND    PricebookEntry.Product2.Producto_financiero__c =: prodfinancial];
                                              
      if(listprodfinancial.size()>0){
            return listprodfinancial;
        }else{
            return null;
        }                                        
    }
   
   /*******************************Infocuenta *******************************************/
    public Account getAccountById(String Accountid){
    	list<Account> acc = [SELECT AccountNumber,BillingCity,BillingCountry,Ciudad__c,Codigo_cliente_unico__c,Codigo_cuenta__c,CreatedById,CreatedDate,Id,Industry,Name,Numero_identificacion__c,OwnerId,Tipo_identificacion__c 
    						 FROM Account where id =:Accountid];
    
    if(acc.size()>0){
            return acc.get(0);      
        }else{      
            return null;
        } 
    }
    
   /*******************************InfoLead *******************************************/
    public Lead getLeadById(String Leadid){
    	list<Lead> lead = [SELECT OwnerId,Name,Codigo_cliente_unico__c,Id,Nit__c,Tipo_identificacion__c,Tipo_identificacion__r.Name FROM Lead where id =:Leadid];
    
    if(lead.size()>0){
            return lead.get(0);      
        }else{      
            return null;
        } 
    }  
   
 
   
   
   
     
}