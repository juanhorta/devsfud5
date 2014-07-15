/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Junio 24 de 2014
*  Decripción:          Clase de prueba del proceso de registro de ventas limitadas
*  @version:            1.0
* ===================================================================================================================================
**/

@isTest (SeeAllData=true)
public with sharing class UT011_CTR012_RegistrovtaLimitada {
   static public Registro_de_Venta_Limitada__c	vtalimitada{get;set;}
   static public Registro_de_Venta_Limitada__c	vtalimitada2{get;set;}
   static public Registro_de_Venta_Limitada__c	vtalimitada3{get;set;}
   static public Quote cotiz1{get;set;}
   static public QuoteLineItem partpres1{get;set;}
   static public QuoteLineItem partpres2{get;set;}
   static public QuoteLineItem partpres3{get;set;}
   static public Section__c  seccion{get;set;}
   static public Ciudad__c city{get;set;}
   static public Stock_Type__c tipoinventario{get;set;}
       
   static testMethod void fnTest1() 
    {
    	fnCrearData();
        Test.startTest();
        system.debug('objeto_vtalimitada'  + vtalimitada);
        //System.Pagereference pr1 = Apexpages.currentPage();
        //pr1.getParameters().put('id',partpres1.Id);
       
       CTR012_RegistrovtaLimitada CTR012logic2 = new CTR012_RegistrovtaLimitada(new ApexPages.StandardController(vtalimitada2));
       CTR012logic2.LoadTipodeInventario(); 
       
       CTR012_RegistrovtaLimitada CTR012logic3 = new CTR012_RegistrovtaLimitada(new ApexPages.StandardController(vtalimitada3));
       CTR012logic3.LoadTipodeInventario();
       
       CTR012_RegistrovtaLimitada CTR012logic = new CTR012_RegistrovtaLimitada(new ApexPages.StandardController(vtalimitada));
       CTR012logic.LoadTipodeInventario();
       CTR012logic.PreciociudadPrincipal();
       CTR012logic.ValidarDisponibilidad();
       CTR012logic.Calculatevaluetotal(partpres1.Id);
       CTR012logic.getQuoteLineItem(partpres1.Id);
       CTR012logic.getVtasasociadas(partpres1.Id);
       CTR012logic.setMsg(0, 'Esta es una prueba ');
       CTR012logic.setMsg(1, 'Esta es una prueba ');
       CTR012logic.setMsg(2, 'Esta es una prueba ');
       CTR012logic.doCancel();
       CTR012logic.getControlInventario(seccion.Id, city.Id, tipoinventario.Id);
       
      
     
        Test.stopTest();
    }
   
    static testMethod void fnTest2() 
    {
    	fnCrearData();
        Test.startTest();
        delete vtalimitada;
        Test.stopTest();
    }
   
   
   static void fnCrearData()
    {
        try{
	           system.debug('Entro_a_fnCrearDatavtalimitada');	 
	  			//----
		       Date DateOpp = date.newinstance(2136, 12, 31);	
		       Date Datemen = date.newinstance(2012, 12, 31);	
		       Profile prof=[Select Id from Profile limit 1];
		       
		       Tipo_identificacion__c  tiponit = [SELECT Id,Name FROM Tipo_identificacion__c where Name = 'CC'];
		       
		       User usrgestor=new User();
		            usrgestor.FirstName='Prueba';
		            usrgestor.LastName='Manager';
		            usrgestor.Username='4556sads@publicar.com';
		            usrgestor.Email='GESTOR@publicar.com';
		            usrgestor.Alias='r7r8r';
		            usrgestor.Country= 'Colombia';
		            usrgestor.City = 'Bogotá D.C.';
		            usrgestor.CommunityNickname='p-aser1a5aa';
		            usrgestor.TimeZoneSidKey='GMT';
		            usrgestor.LocaleSidKey='es_CO';
		            usrgestor.EmailEncodingKey='ISO-8859-1';
		            usrgestor.ProfileId=prof.Id;
		            usrgestor.LanguageLocaleKey='es';
		            insert usrgestor;
		         
		        User usr=new User();
		            usr.FirstName='Prueba';
		            usr.LastName='Asesor';
		            usr.Username='asdjk4j56j5@publicar.com';
		            usr.Email='asesor@publicar.com';
		            usr.Alias='or8g9g';
		            usr.Country= 'Colombia';
		            usr.City = 'Bogotá D.C.';
		            usr.CommunityNickname='p-aseso2b3cx';
		            usr.TimeZoneSidKey='GMT';
		            usr.LocaleSidKey='es_CO';
		            usr.EmailEncodingKey='ISO-8859-1';
		            usr.ProfileId=prof.Id;
		            usr.LanguageLocaleKey='es';
		            usr.ManagerId = usrgestor.Id;
		            insert usr;
		            system.debug('creamos_el_User' + usr);	
		            
		            city = new Ciudad__c(
		           Capital__c = 'Es capital de pais',
		           Codigo_capital__c = '203',
		           Codigo_ciudad__c = '11001',
		           Codigo_estado__c = '11',
		           Codigo_pais__c = '1',
		           Codigo_region__c = '11001',
		           Estado__c = 'Distrito Capital',
		           Name = 'BOGOTA',
		           Pais__c = 'Colombia',
		           Region__c = 'Centro');
		           insert city;
		           system.debug('creamos_la_Ciudad__c' + city);	
		            
		        Account acc1 = new Account();
		            acc1.Activo__c = true;
		            acc1.Codigo_cliente_unico__c = 123;
		            acc1.Name = 'cuenta1';
		            acc1.OwnerId= usr.Id;
		            acc1.Tipo_identificacion__c = tiponit.Id;
                    acc1.Numero_identificacion__c= '80048577';
		            insert acc1;
		             system.debug('creamos_Account' + acc1);	
		             
		        Account acc2 = new Account();
		            acc2.Activo__c = true;
		            acc2.Tipo_identificacion__c = tiponit.Id;
                    acc2.Numero_identificacion__c= '80048576';
		            acc2.Name = 'cuenta2';
		            acc2.OwnerId= usr.Id;
		            insert acc2;  
		            
		        Pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
		        pricebook2 custompb = new pricebook2(name='test',isactive=true);
                insert custompb;
		        
		        tipoinventario = new Stock_Type__c(
		        Nombre_Tipo_Inventario__c = 'Arbol de prueba');
		        insert tipoinventario;
		        
		         seccion = new Section__c(
		        Name = 'telefonos',
		        Categoria__c = 'telefonos',
		        Stock_Type__c = tipoinventario.Id);
		        insert seccion;
		        
		        
		        Product2 referencia1 = new Product2();
	           referencia1.Family = 'Soluciones Web';
	           referencia1.Genera_Produccion__c = true;
	           referencia1.IsActive = true;
	           referencia1.Linea_de_negocio__c = 'Soluciones Digitales';
	           referencia1.Linea_de_produccion__c = 'Solución Básica';
	           referencia1.Meses_Vigencia__c = 2;
	           referencia1.Name = 'REFERENCIA1';
	           referencia1.ProductCode = 'BASDOMC1';
	           referencia1.Producto_financiero__c = 'ABX1231321';
	           referencia1.Tipo_de_produccion__c = 'Soluciones web';
	           referencia1.Venta_limitada__c = true;
	           referencia1.Ventas_permitidas__c = 2;
	           referencia1.Tipo_Inventario__c = tipoinventario.Id;
	           referencia1.Numero_cuotas_maximo__c = 10;
	           insert referencia1;
	           
	           
	           referencia1.Principal_city_price__c = 500;
	           referencia1.Ventas_permitidas__c = 3;
	           update referencia1;
	           
	           Product2 referencia2 = new Product2();
	           referencia2.Family = 'Soluciones Web';
	           referencia2.Genera_Produccion__c = true;
	           referencia2.IsActive = true;
	           referencia2.Linea_de_negocio__c = 'Soluciones Digitales';
	           referencia2.Linea_de_produccion__c = 'Solución Básica';
	           referencia2.Meses_Vigencia__c = 2;
	           referencia2.Name = 'referencia2';
	           referencia2.ProductCode = 'BASDOMC1';
	           referencia2.Producto_financiero__c = 'ABX1231321';
	           referencia2.Tipo_de_produccion__c = 'Soluciones web';
	           referencia2.Venta_limitada__c = false;
	           referencia2.Ventas_permitidas__c = 2;
	           referencia2.Tipo_Inventario__c = tipoinventario.Id;
	           referencia2.Numero_cuotas_maximo__c = 10;
	           insert referencia2;
	           
	           Product2 referencia3 = new Product2();
	           referencia3.Family = 'Soluciones Web';
	           referencia3.Genera_Produccion__c = true;
	           referencia3.IsActive = true;
	           referencia3.Linea_de_negocio__c = 'Soluciones Digitales';
	           referencia3.Linea_de_produccion__c = 'Solución Básica';
	           referencia3.Meses_Vigencia__c = 2;
	           referencia3.Name = 'referencia3';
	           referencia3.ProductCode = 'BASDOMC1';
	           referencia3.Producto_financiero__c = 'ABX1231321';
	           referencia3.Tipo_de_produccion__c = 'Soluciones web';
	           referencia3.Venta_limitada__c = true;
	           referencia3.Tipo_Inventario__c = tipoinventario.Id;
	           referencia3.Numero_cuotas_maximo__c = 10;
	           insert referencia3;
	           
	           
	           
	           
	            PricebookEntry price1 = new PriceBookEntry();
	       		 price1.Pricebook2Id = standardpb.Id;
	       		 price1.Product2Id = referencia1.Id;
	       		 price1.UnitPrice=1000000;
	       		 price1.IsActive=true;
	       		 insert price1;
	       		
	       		PricebookEntry price2 = new PriceBookEntry();
	       		 price2.Pricebook2Id = standardpb.Id;
	       		 price2.Product2Id = referencia2.Id;
	       		 price2.UnitPrice=1000000;
	       		 price2.IsActive=true;
	       		 insert price2;
	       		 
	       		PricebookEntry price3 = new PriceBookEntry();
	       		 price3.Pricebook2Id = standardpb.Id;
	       		 price3.Product2Id = referencia3.Id;
	       		 price3.UnitPrice=1000000;
	       		 price3.IsActive=true;
	       		 insert price3; 
	       		 
	       	  system.debug('pbeprice: ' + price1.UnitPrice);    
	       	  
	       	 
	       		 
	       		 Asset activo1 = new Asset();
	          activo1.AccountId = acc1.id;
	          activo1.Ano_Fiscal__c = '2014';
	          activo1.Fecha_primera_activacion__c = DateOpp;
	          activo1.Codigo_activo__c = 10000100;
	          activo1.Codigo_internet__c = '456989';
	          activo1.Name = '2014_Febrero_BASDOMC1_Solución Básica_venta nueva';
	          activo1.Price = 100000;
	          activo1.Product2Id = referencia1.id;
	          activo1.InstallDate = DateOpp;
	          activo1.Status = '01. Creado';
	          insert activo1;
	          
           	Opportunity opptest = new Opportunity();
            opptest.AccountId = acc1.id;
            opptest.Ano_Fiscal__c = String.valueOf(system.now().year());
            opptest.CloseDate    = DateOpp;
            opptest.Name  = 'testopp';
            opptest.OwnerId = usr.Id;
         	opptest.Pricebook2Id = standardpb.id;
         	opptest.StageName = '01 Preparación';
         	insert opptest;
	         
	          cotiz1 = new Quote(
            BillingName = 'carvajal',
            Cuota_normalizada__c = true,
            Fecha_primera_cuota__c = DateOpp,
            Name = 'carvajal',
            Numero_cuotas__c = 2,
            OpportunityId = opptest.id,
            Pricebook2Id = standardpb.Id,
            Recalcular_cuotas__c = true);
            insert cotiz1;
            system.debug('objeto_cotiz1' + cotiz1);	
	         	
	       partpres1 = new QuoteLineItem(
           Discount = null,
           Quantity = 1,
           QuoteId = cotiz1.Id,
           Description= 'dsdasd',
           ServiceDate =DateOpp,
           UnitPrice = 100000,
           Token_publicidad__c = 'A7894567',
           Seccion__c = seccion.Id,
           PricebookEntryId = price1.Id );
           
           insert partpres1;     
           
           partpres2 = new QuoteLineItem(
           Discount = null,
           Quantity = 1,
           QuoteId = cotiz1.Id,
           Description= 'dsdasd',
           ServiceDate =DateOpp,
           UnitPrice = 100000,
           Seccion__c = seccion.Id,
           Token_publicidad__c = 'A7894567',
           PricebookEntryId = price2.Id );
           insert partpres2;  
           
           partpres3 = new QuoteLineItem(
           Discount = null,
           Quantity = 1,
           QuoteId = cotiz1.Id,
           Description= 'dsdasd',
           ServiceDate =DateOpp,
           UnitPrice = 100000,
           Seccion__c = seccion.Id,
           Token_publicidad__c = 'A7894564',
           PricebookEntryId = price3.Id );
           insert partpres3; 
		   
		   Control_de_Inventario__c kardex = new Control_de_Inventario__c();
		   //kardex.Cantidad_Disponible__c = 1;
		   kardex.Cantidad_Permitida__c = 2;
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
           Partida_de_presupuesto__c = partpres1.Id,
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
           Contrato__c = 'UD12345678',
           //Control_de_Inventario__c,
           Estado__c ='EN PROCESO',
           Partida_de_presupuesto__c = partpres2.Id,
           Control_de_Inventario__c = kardex.Id,
           Precio__c = 1000,
           Seccion_principal__c = seccion.Id,
           Tipo_de_Inventario__c = tipoinventario.Id
           );
         
           CTR012_RegistrovtaLimitada CTR012logic = new CTR012_RegistrovtaLimitada(new ApexPages.StandardController(vtalimitada2));
           
           vtalimitada3 = new Registro_de_Venta_Limitada__c(
           Activado__c = true,
           Ciudad_es_principal__c = false,
           Ciudad__c = city.Id,
           Contrato__c = 'UD12345673',
           //Control_de_Inventario__c,
           Estado__c ='EN PROCESO',
           Partida_de_presupuesto__c = partpres3.Id,
           Control_de_Inventario__c = kardex.Id,
           Precio__c = 1000,
           Seccion_principal__c = seccion.Id,
           Tipo_de_Inventario__c = tipoinventario.Id
           );
           
           
           
           
		}catch(System.exception ex)
	        {
	            System.debug('\n\n ##Error##' + ex + '\n\n');
	        }
   
    }
   
}