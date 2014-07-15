/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Febrero 06 de 2014
*  Decripción:          Clase de prueba del proceso de chequeo de crédito con SAP
*  @version:            1.0
* ===================================================================================================================================
**/

@isTest (SeeAllData=true)
public with sharing class UT008_CTR008_SendCreditCheck {
	
static public Quote cotiz1{get;set;}
static public Quote cotiz2{get;set;} 
static public Quote cotiz3{get;set;}   
static public Account acc1{get;set;} 
static public Lead milead{get;set;} 
static public Opportunity opp1{get;set;}


   static testMethod void fnTest1() 
    {
    	fnCrearData2();
        Test.startTest();
        system.debug('objeto cotiz1desde_el_test' + cotiz1 );
        System.Pagereference pr1 = Apexpages.currentPage();
        pr1.getParameters().put('PresupuestoId',cotiz1.Id);
        pr1.getParameters().put('OperationCode', 'CHEQUEO' );
        pr1.getParameters().put('requestFrom', 'COTIZACION' );    
        pr1.getParameters().put('accion', 'SIMULACION' );         
       
       CTR008_SendCreditCheck CTR008logic = new CTR008_SendCreditCheck();
       CTR008logic.lanzarProceso();
       
     
       CTR008logic.clase_prueba();
		
        
      //------------------------------------------------------------------------------------
  } 
    
  /*
  static testMethod  void fnTest2() 
    {
    	fnCrearData2();
        Test.startTest();
        system.debug('objeto cotiz2desde_el_test' + cotiz1);
        System.Pagereference pr2 = Apexpages.currentPage();
        pr2.getParameters().put('PresupuestoId',cotiz1.Id);
        pr2.getParameters().put('OperationCode', 'CHEQUEO' );
        pr2.getParameters().put('requestFrom', 'OPORTUNIDAD' );     
        pr2.getParameters().put('accion', 'SIMULACION' );         
       
        CTR008_SendCreditCheck CTR008logic2 = new CTR008_SendCreditCheck();
        CTR008logic2.lanzarProceso();
        
        Test.stopTest();
   } 
  */
  static testMethod  void fnTest3() 
    {
    	fnCrearData2();
        Test.startTest();
            system.debug('objeto cotiz-2desde_el_test' + cotiz2);
	        System.Pagereference pr3 = Apexpages.currentPage();
	        pr3.getParameters().put('PresupuestoId',cotiz2.Id);
	        pr3.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr3.getParameters().put('requestFrom', 'COTIZACION' );    
	        pr3.getParameters().put('accion', 'SIMULACION' );         
	       
	        CTR008_SendCreditCheck CTR008logic3 = new CTR008_SendCreditCheck();
	        CTR008logic3.lanzarProceso();
        
        Test.stopTest();
   } 
   
   static testMethod  void fnTest4() 
    {
    	fnCrearData2();
        Test.startTest();
            system.debug('objeto cotiz_3desde_el_test' + cotiz3);
	        System.Pagereference pr4 = Apexpages.currentPage();
	        pr4.getParameters().put('PresupuestoId',cotiz3.Id);
	        pr4.getParameters().put('OperationCode', 'CHEQUEO' );
	        pr4.getParameters().put('requestFrom', 'COTIZACION' );    
	        pr4.getParameters().put('accion', 'SIMULACION' );         
	       
	        CTR008_SendCreditCheck CTR008logic4 = new CTR008_SendCreditCheck();
	        CTR008logic4.lanzarProceso();
            system.debug('prueba_n_4');	
        Test.stopTest();
   } 
   
   static testMethod  void anulaciondeopp() 
    {
    	fnCrearData2();
        Test.startTest();
            
	        System.Pagereference pr7 = Apexpages.currentPage();
	        pr7.getParameters().put('OportunidadId',opp1.Id);
	        CTR011_Annulationoport ctranulation = new CTR011_Annulationoport();        
	        ctranulation.validateconditions();
	        ctranulation.rendertipoanulacion();
	        ctranulation.doCancel();
	        //ctranulation.runanulation();
	        ctranulation.calculatevalueprod();
	       
	        system.debug('prueba_anulacion');	
        Test.stopTest();
   } 
   
   static testMethod  void consultacupodesdecuenta() 
    {
    	fnCrearData2();
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
            system.debug('prueba_n_5');	
        Test.stopTest();
   } 
   
     static testMethod  void consultacupodesdelead() 
    {
    	fnCrearData2();
        Test.startTest();
            system.debug('objeto cuenta_desde_el_test' + milead);
	        System.Pagereference pr6 = Apexpages.currentPage();
	        pr6.getParameters().put('LeadId',milead.Id);
	        pr6.getParameters().put('OperationCode', 'CUPO' );
	        pr6.getParameters().put('requestFrom', 'LEAD' );    
	        pr6.getParameters().put('accion', 'CONSCUPO' );         
	        
	        
	        CTR008_SendCreditCheck CTR008logic6 = new CTR008_SendCreditCheck();
	        CTR008logic6.validarCU();
	        CTR008logic6.lanzarProceso();
            system.debug('prueba_n_5');	
        Test.stopTest();
   } 
   
 
  static void fnCrearData2()
    {
        try{
         system.debug('Entro_a_fnCrearData');	 
  //----
       Date DateOpp = date.newinstance(2136, 12, 31);	
       Date Datemen = date.newinstance(2012, 12, 31);	
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
            
               
            
            
            acc1 = new Account(
           
            //Codigo_cliente_unico__c = '',
            Activo__c = true,
            
            Name = 'cuenta1',
            OwnerId= usr.Id,
            Numero_identificacion__c = '80048578',
            Tipo_identificacion__c = tiponit.id);
            insert acc1;
            system.debug('creamos_Account' + acc1);	
             
        Account acc2 = new Account();
            acc2.Activo__c = true;
            acc2.Numero_identificacion__c = '80048578';
            acc2.Tipo_identificacion__c = tiponit.id;
            acc2.Name = 'cuenta2';
            acc2.OwnerId= usr.Id;
            insert acc2; 
            
            
       milead = new Lead(
       Nit__c = '80048578',
       Tipo_identificacion__c = tiponit.id,
       Phone = '2365478',
       LastName = 'apellido',
       Status  = '01. Nuevo',
       Company = 'micompany',
       FirstName = 'milead');
       insert milead;
       system.debug('creamos_lead' + milead);	            
            
         product2 prod2 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10);
           insert prod2;
           
          product2 prod3 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10,Linea_de_produccion__c = 'Solución Básica');
           insert prod3;  
       system.debug('creamos_el_product2' + prod3);
       	
       pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
       pricebook2 custompb = new pricebook2(name='test',isactive=true);
    insert custompb;
    pricebookentry standardprice = new pricebookentry( product2id = prod2.id, pricebook2id = standardpb.id,IsActive=true,  UnitPrice=100), 
              		 customprice = new pricebookentry( product2id = prod2.id, pricebook2id = custompb.id, IsActive=true, UnitPrice=100, usestandardprice = true );
    insert standardprice;
    insert customprice;
        
       
            opp1 = new Opportunity(    
            AccountId = acc1.id,
            Ano_Fiscal__c = String.valueOf(system.now().year()),
            CloseDate    = DateOpp,
            Name  = 'opportprueba',
            OwnerId = usr.Id,
            StageName = '01 Preparación',
         	Pricebook2Id = custompb.Id);
         	insert opp1;
         	
         	system.debug('Oportunidad_Preparación ' + opp1);
         	
         	
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
         	
         	/*opp2.SyncedQuoteId = cotiz1.Id;
         	update opp2;
         	*/
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
         	         	
           List<ProcessInstance> ap = [SELECT ID,Status, TargetObjectID
				FROM ProcessInstance
				limit 1];
				system.debug('processInstance_List' + ap);
				

         cotiz1 = new Quote(
            BillingName = 'carvajal',
            Cuota_normalizada__c = true,
            Fecha_primera_cuota__c = DateOpp,
            Name = 'carvajal',
            Numero_cuotas__c = 2,
            OpportunityId = opp1.id,
            Pricebook2Id = custompb.Id,
            Recalcular_cuotas__c = true);
            insert cotiz1;
            system.debug('objeto_cotiz1' + cotiz1);
            
      
            
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
            system.debug('mi_cotizacion_es  '+cotiz3 );
            insert cotiz3;  
            
            
          
          QuoteLineItem prodUCTOPP = new QuoteLineItem();
           prodUCTOPP.Discount = 30;
           prodUCTOPP.Quantity = 1;
           prodUCTOPP.QuoteId = cotiz1.id;
           prodUCTOPP.Description= 'dsdasd';
           prodUCTOPP.ServiceDate =DateOpp;
           prodUCTOPP.UnitPrice = 100000;
           prodUCTOPP.Token_publicidad__c = 'A7894567';
           prodUCTOPP.PricebookEntryId = customprice.id;
           insert prodUCTOPP; 
           system.debug('prodUCTOPP_1' +prodUCTOPP);
           
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
           
           
           Dato_facturacion__c datofact = new Dato_facturacion__c();
           datofact.Agente_facturacion__c = 'CARVAJAL INFORMACION';
           datofact.Agente_recaudo__c = 'FACTURA DIRECTA';
           datofact.Ciudad_facturacion__c = city.id;
           datofact.Ciudad_telefono_facturacion__c =city.id;
           datofact.Correo_facturacion__c = 'email@corporativo.com';
           datofact.Cuota_normalizada__c = true;
           datofact.Direccion_facturacion__c='cll 68 n 45-89';
           datofact.Fecha_primera_cuota__c = DateOpp;
           datofact.Name = 'Factura ';
           datofact.Numero_cuotas__c= 2;
           datofact.Numero_identificacion__c='80048578';
           datofact.Tipo_identificacion__c = tiponit.id;
           datofact.Presupuesto__c = cotiz1.id;
           datofact.Razon_social__c = 'cuenta1';
           datofact.Telefono_contacto_financiero__c= '6465555';
           datofact.Valor_facturacion__c = 789;
           insert datofact;
           system.debug('datofact_creado'+ datofact);
           
         Cuota_facturacion__c cuotadato = new Cuota_facturacion__c();
           cuotadato.Dato_facturacion__c = datofact.id;
           cuotadato.Fecha_cuota__c = DateOpp;
           cuotadato.Partida_de_presupuesto__c = prodUCTOPP.id;
           cuotadato.Valor_cuota__c = 15000;
           cuotadato.No_Cuota__c = 1;
           insert cuotadato;
           system.debug('Cuota_creada'+ cuotadato);
           
		}catch(System.exception ex)
	        {
	            System.debug('\n\n ##Error##' + ex + '\n\n');
	        }
   
    }


}