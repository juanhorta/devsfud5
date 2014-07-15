/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Sebastian quintero
*  Fecha:               Marzo 13 de 2014
*  Decripción:          Clase de pruebas
*  @version:            1.0
* ===================================================================================================================================
**/
@isTest (SeeAllData=true)
private class UT010_CTR010_Management_Of_Approvals{
	
static public Quote cotiz1{get;set;}
static public Quote cotiz2{get;set;} 
static public Quote cotiz3{get;set;}  
static public Quote cotizpp{get;set;} 
static public Opportunity opp1{get;set;}
static public Opportunity opp10{get;set;}
static public Opportunity opppps{get;set;}
static public Registro_de_Venta_Limitada__c	vtalimitada{get;set;}
static public Registro_de_Venta_Limitada__c	vtalimitada2{get;set;}

static public Dato_facturacion__c datofact {get;set;}
static public Cuota_facturacion__c cuotadato {get;set;}
static public QuoteLineItem prodUCTOPP {get;set;}
static public Fulfillment_management__c obj_ffM {get;set;}
static public Requestfinancial__c obj_PeticionFinanciero{get;set;}
static public Account acc1 {get;set;}
static public Lead lead1 {get;set;}
static public Section__c  seccion{get;set;}

static public Stock_Type__c tipoinventario{get;set;}

  
     static testMethod  void fnEnviarAprobacion() 
    {
    	fnCrearData2('03 Negociación');
        Test.startTest();
            system.debug('objeto cotiz_4desde_el_test' + cotiz1 + ' oppId: ' + opp1);
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('PresupuestoId',cotiz1.Id);
	        pr4.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr4.getParameters().put('requestFrom', 'COTIZACION' );    
	        pr4.getParameters().put('accion', 'SIMULACION' );         
	       
	        CTR008_SendCreditCheck CTR008logic4 = new CTR008_SendCreditCheck();
	        CTR008logic4.lanzarProceso();
	        CTR008logic4.setMsg(0, 'message test');
	        CTR008logic4.setMsg(1, 'message test');
	        CTR008logic4.setMsg(2, 'message test');
            system.debug('prueba_n_4');	
        Test.stopTest();
   }

       static testMethod  void fnEnviarAprobacion_token() 
    {
    	fnCrearData2('03 Negociación');
        Test.startTest();
            system.debug('objeto cotiz_4desde_el_test' + cotiz1 + ' oppId: ' + opp1);
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('PresupuestoId',opp1.Id);
	        pr4.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr4.getParameters().put('requestFrom', 'OPORTUNIDAD' );    
	        pr4.getParameters().put('accion', 'SIMULACION' );         
	       
	        CTR008_SendCreditCheck CTR008logic4 = new CTR008_SendCreditCheck();
	        CTR008logic4.lanzarProceso();
	         CTR008logic4.setMsg(0, 'message test');
	        CTR008logic4.setMsg(1, 'message test');
	        CTR008logic4.setMsg(2, 'message test');
            system.debug('prueba_n_4');	
            
            CL014_Auditoria_oppblocked auditoria = new CL014_Auditoria_oppblocked();
            
        Test.stopTest();
   }
 
    static testMethod  void fnEnviarAprobacion_DataConValorCero() 
    {
    	fnCrearDataConValorCero();
        Test.startTest();
            system.debug('objeto cotiz_4desde_el_test' + cotiz1 + ' oppId: ' + opp1);
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('PresupuestoId',opp10.Id);
	        pr4.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr4.getParameters().put('requestFrom', 'OPORTUNIDAD' );    
	        pr4.getParameters().put('accion', 'SIMULACION' );         
	       
	        CTR008_SendCreditCheck CTR008logic4 = new CTR008_SendCreditCheck();
	        CTR008logic4.lanzarProceso();
            system.debug('prueba_n_4');	
        Test.stopTest();
   }
 
    /*---------------------------------------------------*/
 
   static testMethod  void fnApruebaFF() 
    {
    	fnCrearData2('06 Cerrada Entregada Fulfillment');
        Test.startTest();
            system.debug('objeto aprobacion_desde_el_test');
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('oportunity',opp1.Id);
	        pr4.getParameters().put('OperationCode', 'FULFILLMENT' );
	        pr4.getParameters().put('origin', 'Opportunity' );    	              
	       
	        CTR010_Management_Of_Approvals CTR010logic = new CTR010_Management_Of_Approvals();
	        CTR010logic.lanzarProceso();
	        CTR010logic.doApproval();
            system.debug('prueba_doApproval');	
        Test.stopTest();
   }  
   
 
   static testMethod  void fnRechazaFF() 
   	{
    	fnCrearData2('06 Cerrada Entregada Fulfillment');
        Test.startTest();
            system.debug('objeto rechazo_desde_el_test');
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('oportunity',opp1.Id);
	        pr4.getParameters().put('OperationCode', 'FULFILLMENT' );
	        pr4.getParameters().put('origin', 'Opportunity' );    	          
	       
	        CTR010_Management_Of_Approvals CTR010logic = new CTR010_Management_Of_Approvals();
	        CTR010logic.lanzarProceso();
	        CTR010logic.doReject();
            system.debug('prueba_doReject');	
        Test.stopTest();
   }  
   

   static testMethod  void fnApruebaCartera() 
    {
    	fnCrearData2('05 Cerrada Entregada Facturación');
        Test.startTest();
            system.debug('objeto aprobacion_de_cartera_desde_el_test');
	        System.Pagereference pr5 = Apexpages.currentPage();
	        pr5.getParameters().put('oportunity',opp1.Id);
	        pr5.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr5.getParameters().put('Requestfinaid', obj_PeticionFinanciero.Id);
	        pr5.getParameters().put('origin', 'Opportunity' );    	              
	       
	        CTR010_Management_Of_Approvals CTR010logic = new CTR010_Management_Of_Approvals();
	        CTR010logic.lanzarProceso();
	        CTR010logic.doApproval();
            system.debug('prueba_doApproval');	
        Test.stopTest();
   }   
  
   static testMethod  void fnRechazaCartera() 
   	{
    	fnCrearData2('05 Cerrada Entregada Facturación');
        Test.startTest();
            system.debug('objeto rechazo_de_cartera_desde_el_test');
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('oportunity',opp1.Id);
	        pr4.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr4.getParameters().put('Requestfinaid', obj_PeticionFinanciero.Id);
	        pr4.getParameters().put('origin', 'Opportunity' );    	          
	       
	        CTR010_Management_Of_Approvals CTR010logic = new CTR010_Management_Of_Approvals();
	        CTR010logic.lanzarProceso();
	        CTR010logic.doReject();
            system.debug('prueba_doReject');	
        Test.stopTest();
   }   
   
   static testMethod  void fnCancelaCartera() 
   	{
   		fnCrearData2('05 Cerrada Entregada Facturación');
        Test.startTest();
            system.debug('objeto cancela_cartera_desde_el_test');
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('oportunity',opp1.Id);
	        pr4.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr4.getParameters().put('Requestfinaid', obj_PeticionFinanciero.Id);
	        pr4.getParameters().put('origin', 'Solicitudafinanciero' );    	          
	       
	        CTR010_Management_Of_Approvals CTR010logic = new CTR010_Management_Of_Approvals();
	        CTR010logic.lanzarProceso();
	        CTR010logic.doCancel();
            system.debug('prueba_doCancel');	
        Test.stopTest();
   	}
   static testMethod  void fnCancelaFF() 
   	{
    	fnCrearData2('06 Cerrada Entregada Fulfillment');
        Test.startTest();
            system.debug('objeto cancela_desde_el_test');
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('oportunity',opp1.Id);
	        pr4.getParameters().put('OperationCode', 'FULFILLMENT' );
	        pr4.getParameters().put('origin', 'Opportunity' );    	          
	       
	        CTR010_Management_Of_Approvals CTR010logic = new CTR010_Management_Of_Approvals();
	        CTR010logic.lanzarProceso();
	        CTR010logic.doCancel();
            system.debug('prueba_doCancel');	
        Test.stopTest();
   }


 static testMethod  void pendientepago()  //JDHC 21-03-2014
    {
    	fnCrearData2('03 Negociación');
        Test.startTest();
            system.debug('objeto cotiz_4desde_el_test' + cotiz1 + ' oppId: ' + opp1);
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('PresupuestoId',opppps.Id);
	        pr4.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr4.getParameters().put('requestFrom', 'OPORTUNIDAD' );    
	        pr4.getParameters().put('origin', 'Opportunity' );         
	       
	        CTR008_SendCreditCheck CTR008logic4 = new CTR008_SendCreditCheck();
	        CTR008logic4.lanzarProceso();
            system.debug('prueba_PP');	
        Test.stopTest();
   }
   
     static testMethod  void servicioInactivo() 
    {
    	fnCrearData2('03 Negociación');
        Test.startTest();
            system.debug('objeto cotiz_4desde_el_test' + cotiz1 + ' oppId: ' + opp1);
	       
	    	System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('PresupuestoId',cotiz1.Id);
	        pr4.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr4.getParameters().put('requestFrom', 'COTIZACION' );    
	        pr4.getParameters().put('accion', 'SIMULACION' );          
	       
	        CTR008_SendCreditCheck CTR008logic4 = new CTR008_SendCreditCheck();
	        CTR008logic4.disabledService();
            system.debug('prueba_n_4');	
        Test.stopTest();
   }
 
 
 
     /*---------------------------------------------------*/
     
	  static testMethod  void FN_CONSCUPO_CUENTA() 
	    {
	     fnCrearData2('03 Negociación');
	        Test.startTest();
	            system.debug('objeto cuenta_desde_el_test' + acc1);
	         System.Pagereference pr5 = Apexpages.currentPage();
	         pr5.getParameters().put('CuentaId',acc1.Id);
	         pr5.getParameters().put('OperationCode', 'CUPO' );
	         pr5.getParameters().put('requestFrom', 'CUENTA' );    
	         pr5.getParameters().put('accion', 'CONSCUPO' );         
	        
	         CTR008_SendCreditCheck CTR008logic5 = new CTR008_SendCreditCheck();
	         CTR008logic5.validarCU();
	         CTR008logic5.lanzarProceso();
	            system.debug('FN_CONSCUPO_CUENTA'); 
	        Test.stopTest();
	   }
 
 
 	  static testMethod  void FN_CONSCUPO_LEAD() 
	    {
	     fnCrearData2('03 Negociación');
	        Test.startTest();
	            system.debug('objeto cuenta_desde_el_test' + lead1);
	         System.Pagereference pr5 = Apexpages.currentPage();
	         pr5.getParameters().put('LeadId',lead1.Id);
	         pr5.getParameters().put('OperationCode', 'CUPO' );
	         pr5.getParameters().put('requestFrom', 'LEAD' );    
	         pr5.getParameters().put('accion', 'CONSCUPO' );         
	        
	         CTR008_SendCreditCheck CTR008logic5 = new CTR008_SendCreditCheck();
	         CTR008logic5.validarCU();
	         CTR008logic5.lanzarProceso();
	            system.debug('FN_CONSCUPO_CUENTA'); 
	        Test.stopTest();
	   }
 
 
  static void fnCrearData2(string Etapa)
    {
        try{
         system.debug('Entro_a_fnCrearData');	 
  //----
       Date DateOpp = date.newinstance(2136, 12, 31);	
       Date Datemen = date.newinstance(2012, 12, 31);	
       
       Date fechaEntregadaFF = date.newinstance(2014, 03, 12);
       Date fechaCerradaFF = date.newinstance(2014, 03, 14);	
       
       Date DateLastCreditCheck = date.newinstance(2012, 12, 31);
       Date DateCreditLimitValidUntilDate = date.newinstance(2012, 12, 31);
       Date DateFecha_Entregada_Facturacion = date.newinstance(2012, 12, 31);
   	   Date DateFecha_cerrada_entregada_facturacion = date.newinstance(2012, 12, 31);
   	   
      
       
   Profile prof=[Select Id from Profile limit 1];
  
   User usrgestor=new User();
            usrgestor.FirstName='Prueba';
            usrgestor.LastName='Manager';
            usrgestor.Username='GESTORwdsads@publicar.com';
            usrgestor.Email='GESTOR@publicar.com';
            usrgestor.Alias='rsdsd';
            usrgestor.Country= 'Colombia';
            usrgestor.City = 'Bogotá D.C.';
            usrgestor.CommunityNickname='p-asesor1sdd';
            usrgestor.TimeZoneSidKey='GMT';
            usrgestor.LocaleSidKey='es_CO';
            usrgestor.EmailEncodingKey='ISO-8859-1';
            usrgestor.ProfileId=prof.Id;
            usrgestor.LanguageLocaleKey='es';
            insert usrgestor;
         
         User usr=new User();
            usr.FirstName='Prueba';
            usr.LastName='Asesor';
            usr.Username='asesorsddad@publicar.com';
            usr.Email='asesor@publicar.com';
            usr.Alias='orcvcv';
            usr.Country= 'Colombia';
            usr.City = 'Bogotá D.C.';
            usr.CommunityNickname='p-asesorvcx';
            usr.TimeZoneSidKey='GMT';
            usr.LocaleSidKey='es_CO';
            usr.EmailEncodingKey='ISO-8859-1';
            usr.ProfileId=prof.Id;
            usr.LanguageLocaleKey='es';
            usr.ManagerId = usrgestor.Id;
            insert usr;
            system.debug('creamos_el_User' + usr);	
            
       Ciudad__c city = new Ciudad__c();
           city.Capital__c = 'Es capital de pais';
           city.Codigo_capital__c = '203';
           city.Codigo_ciudad__c = '11001';
           city.Codigo_estado__c = '11';
           city.Codigo_pais__c = '1';
           city.Codigo_region__c = '11001';
           city.Estado__c = 'Distrito Capital';
           city.Name = 'BOGOTA';
           city.Pais__c = 'Colombia';
           city.Region__c = 'Centro';
           insert city;
           system.debug('creamos_la_Ciudad__c' + city);	
           
            Tipo_identificacion__c  tiponit = [SELECT Id,Name FROM Tipo_identificacion__c where Name = 'CC'];
            
        lead1 = new Lead();
        	lead1.LastName = 'prueba lead';
        	lead1.Company = 'carvajal';
        	lead1.Telefono_adicional__c = '6251444';
        	lead1.Nit__c = '80048578';
        	lead1.Tipo_identificacion__c = tiponit.Id;
        	lead1.Status = '01. Nuevo';
            insert lead1;
            system.debug('creamos_lead1:  ' + lead1);	
            
        acc1 = new Account();
            acc1.Activo__c = true;
            acc1.Codigo_cliente_unico__c = 589.287;
            acc1.Name = 'cuenta1';
            acc1.Numero_identificacion__c = '80048578';
            acc1.Tipo_identificacion__c = tiponit.Id;
            //acc1.Codigo_cuenta__c = '325550';            
            acc1.OwnerId= usr.Id;
            acc1.Pendiente_pago__c = false;
            insert acc1;
            system.debug('creamos_Account' + acc1);	
             
        Account acc2 = new Account();
            acc2.Activo__c = true;
            acc2.Numero_identificacion__c = '80048578';
            acc2.Tipo_identificacion__c = tiponit.Id;
            acc2.Name = 'cuenta2';
            acc2.OwnerId= usr.Id;
            insert acc2;       
            
            
        Account acc3 = new Account();			//JDHC 21-03-2013
            acc3.Activo__c = true;
            acc3.Codigo_cliente_unico__c = 589.287;
            acc3.Name = 'cuenta1';
            acc3.Numero_identificacion__c = '80048578';
            acc3.Tipo_identificacion__c = tiponit.Id;
            acc3.OwnerId= usr.Id;
            acc3.Pendiente_pago__c = true;
            insert acc3;
            system.debug('creamos_Account 3' + acc3);
            
            tipoinventario = new Stock_Type__c(
		    Nombre_Tipo_Inventario__c = 'Arbol de prueba');
		    insert tipoinventario;
		        
	        seccion = new Section__c(
	        Name = 'telefonos',
	        Categoria__c = 'telefonos',
	        Stock_Type__c = tipoinventario.Id);
	        insert seccion;	 
            
        product2 prod2 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10, Allows_Additional_City__c = true,Tipo_Inventario__c = tipoinventario.Id,Price_additional_city__c = 0);
        insert prod2;
           
        product2 prod3 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10,Linea_de_produccion__c = 'Solución Básica',Allows_Additional_City__c = false);
        insert prod3;  
       
       	system.debug('creamos_el_product2' + prod3);
       	
       	pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
       	
       	pricebook2 custompb = new pricebook2(name='test',isactive=true);
    	insert custompb;
   
    	pricebookentry standardprice = new pricebookentry( product2id = prod2.id, pricebook2id = standardpb.id,IsActive=true,  UnitPrice=100000), 
        customprice = new pricebookentry( product2id = prod2.id, pricebook2id = custompb.id, IsActive=true, UnitPrice=100000, usestandardprice = true );
    
    	insert standardprice;
    	insert customprice;
        
       
         //Opportunity opp1 = new Opportunity();   
            opp1 = new Opportunity();
            opp1.AccountId = acc1.id;
            opp1.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp1.CloseDate    = DateOpp;
            opp1.Name  = 'opportprueba';
            opp1.OwnerId = usr.Id;
            opp1.StageName = '01 Preparación';
         	opp1.Pricebook2Id = custompb.Id;    
         	opp1.CreditCheckCode__c = '123';   
         	opp1.endcheckup__c = 'APROBADO';   
         	opp1.Token_venta_en_linea__c = 'A7894567';   
         			         	         
         	insert opp1;
         	
         	system.debug('Oportunidad_Preparación ' + opp1);
         	
         	/*
         	Opportunity opp2 = new Opportunity();   
            opp2 = new Opportunity();
            opp2.AccountId = acc2.id;
            opp2.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp2.CloseDate    = DateOpp;
            opp2.Name  = 'opportprueba';
            opp2.OwnerId = usr.Id;
         	opp2.Pricebook2Id = custompb.Id;
         	opp2.StageName = '01 Preparación';
         	insert opp2;
         	
         	system.debug('Oportunidad_2');
         	
         	Opportunity opp3 = new Opportunity();   
            opp3= new Opportunity();
            opp3.AccountId = acc1.id;
            opp3.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp3.CloseDate    = DateOpp;
            opp3.Name  = 'opportprueba2';
            opp3.OwnerId = usr.Id;
         	opp3.Pricebook2Id = custompb.Id;
         	opp3.StageName = '01 Preparación';
         	insert opp3;
         	
         	system.debug('Oportunidad_3' + opp3);
         	         	*/
         	         	
         opppps = new Opportunity();
            opppps.AccountId = acc3.id;
            opppps.Ano_Fiscal__c = String.valueOf(system.now().year());
            opppps.CloseDate    = DateOpp;
            opppps.Name  = 'opportprueba1';
            opppps.OwnerId = usr.Id;
            opppps.StageName = '01 Preparación';
         	opppps.Pricebook2Id = custompb.Id;    
         	opppps.CreditCheckCode__c = '123'; 	
         	     	         
         	insert opppps;
           List<ProcessInstance> ap = [SELECT ID,Status, TargetObjectID	FROM ProcessInstance limit 1];
		   system.debug('processInstance_List' + ap);
				

         cotiz1 = new Quote(		//JDHC 21-03-2014
            BillingName = 'carvajal',
            Cuota_normalizada__c = true,
            Fecha_primera_cuota__c = DateOpp,
            Name = 'carvajal',
            Numero_cuotas__c = 1,
            OpportunityId = opp1.id,
            Pricebook2Id = custompb.Id,
            Recalcular_cuotas__c = true,
            Ciudad_venta__c = city.Id
            //IsSyncing = true
            );  
                      
            insert cotiz1;
            system.debug('objeto_cotiz1' + cotiz1);
            
            
            //sincroniza la cotizacion       
      		opp1.SyncedQuoteId = cotiz1.Id;
      		opp1.StageName = Etapa; //'06 Cerrada Entregada Fulfillment';  
      		update opp1;
            system.debug('Oportunidad_Preparación2 ' + opp1);
          
            cotizpp = new Quote(	//JDHC 21-03-2014
            BillingName = 'carvajal',
            Cuota_normalizada__c = true,
            Fecha_primera_cuota__c = DateOpp,
            Name = 'carvajal',
            Numero_cuotas__c = 1,
            OpportunityId = opppps.id,
            Pricebook2Id = custompb.Id,
            Recalcular_cuotas__c = true,
            Ciudad_venta__c = city.Id
            
            //IsSyncing = true
            );
            
             insert cotizpp;
            system.debug('objeto_cotizpp' + cotizpp);
            
            //sincroniza la cotizacion       
      		opppps.SyncedQuoteId = cotizpp.Id;
      		//opppps.StageName = Etapa; //'06 Cerrada Entregada Fulfillment';  
      		update opppps;  
            /*
          cotiz2 = new Quote(
            BillingName = 'carvajal',
            Cuota_normalizada__c = false,
            Fecha_primera_cuota__c = DateOpp,
            Name = 'carvajal',
            Numero_cuotas__c = 2,
            OpportunityId = opp2.id,
            Pricebook2Id = custompb.Id,
            Recalcular_cuotas__c = true);
            
            insert cotiz2;  
            
           cotiz3 = new Quote(
            BillingName = 'carvajal',
            Cuota_normalizada__c = false,
            Fecha_primera_cuota__c = DateOpp,
            Name = 'carvajal',
            Numero_cuotas__c = 2,
            OpportunityId = opp3.id,
            Pricebook2Id = custompb.Id,
            Recalcular_cuotas__c = true);
            
            insert cotiz3;  
            */
           
            Asset activo = new Asset();
          activo.AccountId = acc1.id;
          activo.Ano_Fiscal__c = '2014';
          activo.Fecha_primera_activacion__c = DateOpp;
          activo.Codigo_activo__c = 100000;
          activo.Codigo_internet__c = '123';
          activo.Name = '2014_1. Enero_BASDOMC2_Solución Básica_venta nueva';
          activo.Price = 1000;
          activo.Product2Id = prod2.id;
          activo.InstallDate = DateOpp;
          activo.Status = '01. Creado';
          insert activo;
           
          
       //QuoteLineItem 
       prodUCTOPP = new QuoteLineItem();
          
           prodUCTOPP.Discount = 0;
           prodUCTOPP.Quantity = 1;
           prodUCTOPP.QuoteId = cotiz1.id;
           prodUCTOPP.Description= 'dsdasd';
           prodUCTOPP.ServiceDate =DateOpp;
           prodUCTOPP.UnitPrice = 100000;
           prodUCTOPP.Token_publicidad__c = 'A7894567';
           prodUCTOPP.PricebookEntryId = customprice.id;              
           insert prodUCTOPP; 
           system.debug('prodUCTOPP_1' +prodUCTOPP);
           
           QuoteLineItem qlipp = new QuoteLineItem();		//JDHC 21-03-2014
          qlipp.Discount = 0;
           qlipp.Quantity = 1;
           qlipp.QuoteId = cotizpp.id;
           qlipp.Description= 'dsdasd';
           qlipp.ServiceDate =DateOpp;
           qlipp.UnitPrice = 100000;
           qlipp.Token_publicidad__c = 'A7894567';
           qlipp.PricebookEntryId = customprice.id;
           qlipp.Activo_renovacion__c  = activo.Id;  
           qlipp.Seccion__c  = seccion.Id;          
           insert qlipp; 
           system.debug('qlipp' +qlipp);
           
           /*
           QuoteLineItem prodUCTOop = new QuoteLineItem();
           prodUCTOop.Discount = 30;
           prodUCTOop.Quantity = 1;
           prodUCTOop.QuoteId = cotiz2.id;
           prodUCTOop.Description= 'dsdasd';
           prodUCTOop.ServiceDate =DateOpp;
           prodUCTOop.UnitPrice = 100000;
           prodUCTOop.Token_publicidad__c = 'zzzz';
           prodUCTOop.PricebookEntryId = customprice.id;
           //prodUCTOop.Activo_renovacion__c = activo2.id;
           insert prodUCTOop; 
           system.debug('prodUCTOPP_2' +prodUCTOPP);
           
           QuoteLineItem prodUCTOP3 = new QuoteLineItem();
           prodUCTOP3.Discount = 30;
           prodUCTOP3.Quantity = 1;
           prodUCTOP3.QuoteId = cotiz3.id;
           prodUCTOP3.Description= 'dsdasd';
           prodUCTOP3.ServiceDate =DateOpp;
           prodUCTOP3.UnitPrice = 100000;
           prodUCTOP3.Token_publicidad__c = 'A7894567';
           prodUCTOP3.PricebookEntryId = customprice.id;
           insert prodUCTOP3; 
           system.debug('prodUCTOP3' +prodUCTOP3);
           */
           
           Control_de_Inventario__c kardex = new Control_de_Inventario__c();
		   //kardex.Cantidad_Disponible__c = 1;
		   kardex.Cantidad_Permitida__c = 5;
		   kardex.Ciudad__c = city.Id;
		   kardex.Seccion__c = seccion.Id;
		   kardex.Tipo_Inventario__c = tipoinventario.Id;
		   insert kardex;
		            
           vtalimitada = new Registro_de_Venta_Limitada__c(
           Activado__c = true,
           Ciudad_es_principal__c = true,
           Ciudad__c = city.Id,
           Contrato__c = 'UD12345678',
           //Control_de_Inventario__c,
           Estado__c ='EN PROCESO',
           Partida_de_presupuesto__c = qlipp.Id,
           Control_de_Inventario__c = kardex.Id,
           Precio__c = 1000,
           
           Seccion_principal__c = seccion.Id,
           Tipo_de_Inventario__c = tipoinventario.Id
           );
           insert vtalimitada;
           
           vtalimitada2 = new Registro_de_Venta_Limitada__c(
           Activado__c = true,
           Ciudad_es_principal__c = true,
           Ciudad__c = city.Id,
           Contrato__c = 'UD12345679',
           //Control_de_Inventario__c,
           Estado__c ='EN PROCESO',
           Partida_de_presupuesto__c = prodUCTOPP.Id,
           Control_de_Inventario__c = kardex.Id,
           Precio__c = 1000,
           Seccion_principal__c = seccion.Id,
           Tipo_de_Inventario__c = tipoinventario.Id
           );
           insert vtalimitada2;
           
           
           
       //Dato_facturacion__c datofact = new Dato_facturacion__c();
       datofact = new Dato_facturacion__c();
           
           datofact.Agente_facturacion__c = 'CARVAJAL INFORMACION';
           datofact.Agente_recaudo__c = 'FACTURA DIRECTA';
           datofact.Ciudad_facturacion__c = city.id;
           datofact.Ciudad_telefono_facturacion__c =city.id;
           datofact.Correo_facturacion__c = 'email@corporativo.com';
           datofact.Cuota_normalizada__c = true;
           datofact.Direccion_facturacion__c='cll 68 n 45-89';
           datofact.Fecha_primera_cuota__c = DateOpp;
           datofact.Name = 'Factura ';
           datofact.Numero_cuotas__c= 1;
           datofact.Numero_identificacion__c= '80048578';
           datofact.Tipo_identificacion__c = tiponit.Id;
           datofact.Presupuesto__c = cotiz1.id;
           datofact.Razon_social__c = 'cuenta1';
           datofact.Telefono_contacto_financiero__c= '6465555';
           datofact.Valor_facturacion__c = 100000;
           datofact.Codigo_Cliente_Unico__c = 589.287;           
           insert datofact;
           system.debug('datofact_creado'+ datofact);
                      
           
            Dato_facturacion__c datofactpp = new Dato_facturacion__c();		//JDHC 21-03-2014
           
           datofactpp.Agente_facturacion__c = 'CARVAJAL INFORMACION';
           datofactpp.Agente_recaudo__c = 'FACTURA DIRECTA';
           datofactpp.Ciudad_facturacion__c = city.id;
           datofactpp.Ciudad_telefono_facturacion__c =city.id;
           datofactpp.Correo_facturacion__c = 'email@corporativo.com';
           datofactpp.Cuota_normalizada__c = true;
           datofactpp.Direccion_facturacion__c='cll 68 n 45-89';
           datofactpp.Fecha_primera_cuota__c = DateOpp;
           datofactpp.Name = 'Factura ';
           datofactpp.Numero_cuotas__c= 1;
           datofactpp.Numero_identificacion__c= '80048578';
           datofactpp.Tipo_identificacion__c = tiponit.Id;
           datofactpp.Presupuesto__c = cotizpp.id;
           datofactpp.Razon_social__c = 'cuenta1';
           datofactpp.Telefono_contacto_financiero__c= '6465555';
           datofactpp.Valor_facturacion__c = 100000;
           datofactpp.Codigo_Cliente_Unico__c = 589287;           
           insert datofactpp;
           system.debug('datofactpp_creado'+ datofactpp);
           
       //Cuota_facturacion__c 
       cuotadato = new Cuota_facturacion__c();
         
           cuotadato.Dato_facturacion__c = datofact.id;
           cuotadato.Fecha_cuota__c = DateOpp;
           cuotadato.Partida_de_presupuesto__c = prodUCTOPP.id;
           cuotadato.Valor_cuota__c = 100000;
           cuotadato.No_Cuota__c = 1;
           insert cuotadato;
           system.debug('Cuota_creada'+ cuotadato);
           
           
           
          Cuota_facturacion__c cuotadatopp = new Cuota_facturacion__c();	//JDHC 21-03-2014
           cuotadatopp.Dato_facturacion__c = datofactpp.id;
           cuotadatopp.Fecha_cuota__c = DateOpp;
           cuotadatopp.Partida_de_presupuesto__c = prodUCTOPP.id;
           cuotadatopp.Valor_cuota__c = 100000;
           cuotadatopp.No_Cuota__c = 1;
           insert cuotadatopp;
           system.debug('Cuotapp_creada'+ cuotadatopp);
       /*  
       // Objeto gestion Fulfiltment (HISTORICO)
       obj_ffM = new Fulfillment_management__c();
       
       		obj_ffM.IdOportunidad__c = opp1.id;
       		obj_ffM.Fecha_Entregada_Fulfillment__c = fechaEntregadaFF;
       		obj_ffM.Fecha_cerrada_fulfillment__c = fechaCerradaFF;
       		obj_ffM.Comments_fulfillment__c = '';
       		obj_ffM.Responsable_fulfillment__c = 'Sebastian Quintero Parra';
       		
       		insert obj_ffM;
       		system.debug('pruebas_Fulfillment_management_Creado ' + obj_ffM);
       	*/
       		
       	//Gestion FF       		
       		opp1.Fecha_Entregada_Fulfillment__c = fechaEntregadaFF;
       		opp1.Fecha_cerrada_fulfillment__c = fechaCerradaFF;
       		opp1.Comentarios_fulfillment__c = '';
       		opp1.Responsable_fulfillmet__c = usr.id;
       		//'00540000001lMlK'; ADMIN NO PUEDE APROBAR       			        		
   		//chequeo de credito
	   		opp1.LastCreditCheck__c = DateLastCreditCheck;
	   		opp1.CreditLimitValidUntilDate__c = DateCreditLimitValidUntilDate;
	   		opp1.Fecha_Entregada_Facturacion__c = DateFecha_Entregada_Facturacion;
	   		opp1.Fecha_cerrada_entregada_facturacion__c =   DateFecha_cerrada_entregada_facturacion;   		   	
	   		update opp1;
	  system.debug('pruebas_ChequeoCredito_Creado ' + opp1);
	  
	  	
	  obj_PeticionFinanciero = new Requestfinancial__c();
	  	obj_PeticionFinanciero.Idoportunity__c = opp1.Id;	  	
	  	obj_PeticionFinanciero.CreditCheckCode__c = '123';
	  	obj_PeticionFinanciero.Monto__c = 100000;
	  	obj_PeticionFinanciero.Mensajes_Chequeo__c = 'ola q ase';
	  	obj_PeticionFinanciero.IsCreditAnalysisRequired__c = true;
	  	obj_PeticionFinanciero.IsCreditExceptionAllowed__c = true;	  
	  	obj_PeticionFinanciero.Status_del_chequeo__c = 'EN PROCESO';	
   	  insert obj_PeticionFinanciero;
   	  system.debug('pruebas_PeticionFinanciero_Creado ' + obj_PeticionFinanciero);		
         
        Fulfillment_management__c gestionFF = new Fulfillment_management__c();
         gestionFF.IdOportunidad__c = opp1.Id;
         gestionFF.Status_fulfillment__c = 'APROBADO';    
         gestionFF.Responsable_fulfillment__c = usr.Id;
         insert gestionFF;    
             
            Task tarea = new Task();
            tarea.WhatId = gestionFF.Id;
            tarea.Status = '01. No Iniciada';
            tarea.Comentarios_Asesor__c = 'ola q ase';
            insert tarea;
            
            tarea.Status = '02. En Ejecución';
            update tarea;
            
            tarea.Status = '03. Completada';
            update tarea;
            
            tarea.Status = '04. En espera de alguien mas';
            update tarea;                
            
            tarea.Status = '05. Aplazado' ;
            update tarea;     		              
           
		}catch(System.exception ex)
	        {
	            System.debug('\n\n ##Error##' + ex + '\n\n');
	        }   
    }
    
    //string Etapa
    static void fnCrearDataConValorCero()
    {
        try{
         system.debug('Entro_a_fnCrearData');	 
  //----
       Date DateOpp = date.newinstance(2136, 12, 31);	
       Date Datemen = date.newinstance(2012, 12, 31);	
       
       Date fechaEntregadaFF = date.newinstance(2014, 03, 12);
       Date fechaCerradaFF = date.newinstance(2014, 03, 14);	
       
       Date DateLastCreditCheck = date.newinstance(2012, 12, 31);
       Date DateCreditLimitValidUntilDate = date.newinstance(2012, 12, 31);
       Date DateFecha_Entregada_Facturacion = date.newinstance(2012, 12, 31);
   	   Date DateFecha_cerrada_entregada_facturacion = date.newinstance(2012, 12, 31);
   	   
       
       
   Profile prof=[Select Id from Profile limit 1];
  
   User usrgestor=new User();
            usrgestor.FirstName='Prueba';
            usrgestor.LastName='Manager';
            usrgestor.Username='GESTORwdsads@publicar.com';
            usrgestor.Email='GESTOR@publicar.com';
            usrgestor.Alias='rsdsd';
            usrgestor.Country= 'Colombia';
            usrgestor.City = 'Bogotá D.C.';
            usrgestor.CommunityNickname='p-asesor1sdd';
            usrgestor.TimeZoneSidKey='GMT';
            usrgestor.LocaleSidKey='es_CO';
            usrgestor.EmailEncodingKey='ISO-8859-1';
            usrgestor.ProfileId=prof.Id;
            usrgestor.LanguageLocaleKey='es';
            insert usrgestor;
         
         User usr=new User();
            usr.FirstName='Prueba';
            usr.LastName='Asesor';
            usr.Username='asesorsddad@publicar.com';
            usr.Email='asesor@publicar.com';
            usr.Alias='orcvcv';
            usr.Country= 'Colombia';
            usr.City = 'Bogotá D.C.';
            usr.CommunityNickname='p-asesorvcx';
            usr.TimeZoneSidKey='GMT';
            usr.LocaleSidKey='es_CO';
            usr.EmailEncodingKey='ISO-8859-1';
            usr.ProfileId=prof.Id;
            usr.LanguageLocaleKey='es';
            usr.ManagerId = usrgestor.Id;
            insert usr;
            system.debug('creamos_el_User' + usr);	
            
       Ciudad__c city = new Ciudad__c();
           city.Capital__c = 'Es capital de pais';
           city.Codigo_capital__c = '203';
           city.Codigo_ciudad__c = '11001';
           city.Codigo_estado__c = '11';
           city.Codigo_pais__c = '1';
           city.Codigo_region__c = '11001';
           city.Estado__c = 'Distrito Capital';
           city.Name = 'BOGOTA';
           city.Pais__c = 'Colombia';
           city.Region__c = 'Centro';
           insert city;
           system.debug('creamos_la_Ciudad__c' + city);	
            
         Tipo_identificacion__c  tiponit = [SELECT Id,Name FROM Tipo_identificacion__c where Name = 'CC'];
            
         acc1 = new Account();
            acc1.Activo__c = true;
            acc1.Codigo_cliente_unico__c = 589.287;
            acc1.Name = 'cuenta1';
            acc1.Numero_identificacion__c = '80048578';
            acc1.Tipo_identificacion__c = tiponit.Id;
            acc1.OwnerId= usr.Id;
            acc1.Pendiente_pago__c = false;
            insert acc1;
            system.debug('creamos_Account' + acc1);	
             
        Account acc2 = new Account();
            acc2.Activo__c = true;
            acc2.Numero_identificacion__c = '80048578';
            acc2.Tipo_identificacion__c = tiponit.Id;
            acc2.Name = 'cuenta2';
            acc2.OwnerId= usr.Id;
            insert acc2;        
            
        product2 prod2 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10, Allows_Additional_City__c = false);
        insert prod2;
           
        product2 prod3 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10,Linea_de_produccion__c = 'Solución Básica', Allows_Additional_City__c = false);
        insert prod3;  
       
       	system.debug('creamos_el_product2' + prod3);
       	
       	pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
       	
       	pricebook2 custompb = new pricebook2(name='test',isactive=true);
    	insert custompb;
   
    	pricebookentry standardprice = new pricebookentry( product2id = prod2.id, pricebook2id = standardpb.id, IsActive = true,  UnitPrice = 0), 
        customprice = new pricebookentry( product2id = prod2.id, pricebook2id = custompb.id, IsActive = true, UnitPrice= 0, usestandardprice = true );
    
    	insert standardprice;
    	insert customprice;
        
       
         //Opportunity opp1 = new Opportunity();   
            opp10 = new Opportunity();
            opp10.AccountId = acc1.id;
            opp10.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp10.CloseDate    = DateOpp;
            opp10.Name  = 'opportprueba';
            opp10.OwnerId = usr.Id;
            opp10.StageName = '01 Preparación';
         	opp10.Pricebook2Id = custompb.Id;    
         	opp10.CreditCheckCode__c = '123'; 	
         	         	         
         	insert opp10;         	
         	system.debug('Oportunidad_Preparación ' + opp1);
         	
           List<ProcessInstance> ap = [SELECT ID,Status, TargetObjectID	FROM ProcessInstance limit 1];
		   system.debug('processInstance_List' + ap);
				

         cotiz1 = new Quote(
            BillingName = 'carvajal',
            Cuota_normalizada__c = true,
            Fecha_primera_cuota__c = DateOpp,
            Name = 'carvajal',
            Numero_cuotas__c = 1,
            OpportunityId = opp10.id,
            Pricebook2Id = custompb.Id,
            Recalcular_cuotas__c = true,
            Ciudad_venta__c = city.Id
            //IsSyncing = true
            );  
                      
            insert cotiz1;
            system.debug('objeto_cotiz1' + cotiz1);
            
            //sincroniza la cotizacion       
      		opp10.SyncedQuoteId = cotiz1.Id;
      		//opp1.StageName = Etapa; //'06 Cerrada Entregada Fulfillment';  
      		update opp1;                        
          
       //QuoteLineItem 
       prodUCTOPP = new QuoteLineItem();
          
           prodUCTOPP.Discount = 0;
           prodUCTOPP.Quantity = 1;
           prodUCTOPP.QuoteId = cotiz1.id;
           prodUCTOPP.Description= 'dsdasd';
           prodUCTOPP.ServiceDate =DateOpp;
           prodUCTOPP.UnitPrice = 0;
           prodUCTOPP.Token_publicidad__c = 'A7894567';
           prodUCTOPP.PricebookEntryId = customprice.id;              
           insert prodUCTOPP; 
           
           system.debug('prodUCTOPP_1' +prodUCTOPP);     
           
           
      obj_PeticionFinanciero = new Requestfinancial__c();
	  	obj_PeticionFinanciero.Idoportunity__c = opp10.Id;	  	
	  	obj_PeticionFinanciero.CreditCheckCode__c = '123';
	  	obj_PeticionFinanciero.Monto__c = 100000;
	  	obj_PeticionFinanciero.Mensajes_Chequeo__c = 'ola q ase';
	  	obj_PeticionFinanciero.IsCreditAnalysisRequired__c = true;
	  	obj_PeticionFinanciero.IsCreditExceptionAllowed__c = true;	  
	  	obj_PeticionFinanciero.Status_del_chequeo__c = 'EN PROCESO';	
   	  	insert obj_PeticionFinanciero;
   	  	system.debug('pruebas_PeticionFinanciero_Creado ' + obj_PeticionFinanciero);	
                              
                 
        system.debug('Oportunidad_js ' + opp10);	                       
           	                       
		}catch(System.exception ex)
	        {
	            System.debug('\n\n ##Error##' + ex + '\n\n');
	        }   
    }
    
    
} // clase