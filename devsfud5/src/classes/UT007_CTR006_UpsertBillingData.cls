@isTest (SeeAllData=true)
public with sharing class UT007_CTR006_UpsertBillingData {
	static testMethod void testclass1() {
    	
    	Test.startTest();
        
         Date DateOpp = date.newinstance(2016, 02, 15);	
         	Profile prof=[Select Id from Profile limit 1];
        	
        	User usrgestor=new User();
            usrgestor.FirstName='Prueba';
            usrgestor.LastName='Manager';
            usrgestor.Username='GESTOR2@publicar.com';
            usrgestor.Email='GESTOR@publicar.com';
            usrgestor.Alias='esor34';
            usrgestor.Country= 'Colombia';
            usrgestor.City = 'Bogotá D.C.';
            usrgestor.CommunityNickname='sesor12323';
            usrgestor.TimeZoneSidKey='GMT';
            usrgestor.LocaleSidKey='es_CO';
            usrgestor.EmailEncodingKey='ISO-8859-1';
            usrgestor.ProfileId=prof.Id;
            usrgestor.LanguageLocaleKey='es';
            insert usrgestor;
         
         User usr=new User();
            usr.FirstName='Prueba';
            usr.LastName='Asesor';
            usr.Username='asesor2@publicar.com';
            usr.Email='asesor@publicar.com';
            usr.Alias='oryu342';
            usr.Country= 'Colombia';
            usr.City = 'Bogotá D.C.';
            usr.CommunityNickname='p-asore32';
            usr.TimeZoneSidKey='GMT';
            usr.LocaleSidKey='es_CO';
            usr.EmailEncodingKey='ISO-8859-1';
            usr.ProfileId=prof.Id;
            usr.LanguageLocaleKey='es';
            usr.ManagerId = usrgestor.Id;
            insert usr;
            
            Tipo_identificacion__c  tiponit = [SELECT Id,Name FROM Tipo_identificacion__c where Name = 'CC'];
            
            Identificaciones__c ident = new Identificaciones__c();
            ident.Cliente_unico__c = 1000099;
            ident.Direccion_facturacion__c = 'calle 1';
            ident.Email_Facturacion__c = 'miemail@gmail.com';
            ident.Numero_identificacion__c = '80048577';
            ident.Pendiente_pago__c = false;
            ident.Telefono_facturacion__c = '2336545';
            ident.Tipo_identificacion__c = tiponit.id;
            insert ident;
            
            Account account1 = new Account();
            account1.Activo__c = true;
            account1.Codigo_cliente_unico__c = 1000099;
            account1.Name = 'testcuenta';
            account1.OwnerId= usr.Id;
            account1.Identificacion__c =ident.id;
            account1.Tipo_identificacion__c = tiponit.Id;
            account1.Numero_identificacion__c= '80048577';
            insert account1;
            
            Account account2 = new Account();
            account2.Activo__c = true;
            account2.Codigo_cliente_unico__c = 1000099;
            account2.Name = 'testcuenta';
            account2.OwnerId= usr.Id;
            account2.Tipo_identificacion__c = tiponit.Id;
            account2.Numero_identificacion__c= '80048578';
            insert account2;
            
            
            /*Pricebook2 pricelist = new Pricebook2();
            pricelist.IsActive = true;
            pricelist.Name= 'pricelist1';
            pricelist.IsStandard = true;
            insert pricelist;*/
            
            Pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
            
            
         	
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
	           referencia1.Venta_limitada__c = false;
	           referencia1.Numero_cuotas_maximo__c = 10;
	           insert referencia1;
	           
	       Product2 referencia2 = new Product2();
	           referencia2.Family = 'Soluciones Web 1';
	           referencia2.Genera_Produccion__c = true;
	           referencia2.IsActive = true;
	           referencia2.Linea_de_negocio__c = 'Soluciones Digitales';
	           referencia2.Linea_de_produccion__c = 'Solución Básica';
	           referencia2.Meses_Vigencia__c = 2;
	           referencia2.Name = 'REFERENCIA2';
	           referencia2.ProductCode = 'BASDOMC2';
	           referencia2.Producto_financiero__c = 'ABX1231321';
	           referencia2.Tipo_de_produccion__c = 'Soluciones web';
	           referencia2.Venta_limitada__c = false;
	           referencia2.Numero_cuotas_maximo__c = 10;
	           insert referencia2;
	           
	       Product2 referencia3 = new Product2();
	           referencia3.Family = 'Soluciones Web 1';
	           referencia3.Genera_Produccion__c = true;
	           referencia3.IsActive = true;
	           referencia3.Linea_de_negocio__c = 'Soluciones Digitales';
	           referencia3.Linea_de_produccion__c = 'Solución Básica';
	           referencia3.Meses_Vigencia__c = 2;
	           referencia3.Name = 'REFERENCIA3';
	           referencia3.ProductCode = 'BASDOMC3';
	           referencia3.Producto_financiero__c = 'ABX1231321';
	           referencia3.Tipo_de_produccion__c = 'Soluciones web';
	           referencia3.Venta_limitada__c = false;
	           referencia3.Numero_cuotas_maximo__c = 10;
	           insert referencia3;
	           
	       Product2 referencia4 = new Product2();
	           referencia4.Family = 'soluciones web';
	           referencia4.Genera_Produccion__c = true;
	           referencia4.IsActive = true;
	           referencia4.Linea_de_negocio__c = 'Clicks';
	           referencia4.Linea_de_produccion__c = 'Solución Básica';
	           referencia4.Meses_Vigencia__c = 2;
	           referencia4.Name = 'REFERENCIA4';
	           referencia4.ProductCode = 'BASDOMC4';
	           referencia4.Producto_financiero__c = 'ABX1231321';
	           referencia4.Tipo_de_produccion__c = 'Soluciones web';
	           referencia4.Venta_limitada__c = false;
	           referencia4.Numero_cuotas_maximo__c = 10;
	           insert referencia4;
	       
	       Product2 referencia5 = new Product2();
	           referencia5.Family = 'Soluciones Web';
	           referencia5.Genera_Produccion__c = true;
	           referencia5.IsActive = true;
	           referencia5.Linea_de_negocio__c = 'clicks';
	           referencia5.Linea_de_produccion__c = 'Solución Básica';
	           referencia5.Meses_Vigencia__c = 2;
	           referencia5.Name = 'REFERENCIA5';
	           referencia5.ProductCode = 'BASDOMC5';
	           referencia5.Producto_financiero__c = 'ABX1231321';
	           referencia5.Tipo_de_produccion__c = 'Soluciones web';
	           referencia5.Venta_limitada__c = false;
	           referencia5.Numero_cuotas_maximo__c = 10;
	           insert referencia5;
	           
	       PricebookEntry price1 = new PriceBookEntry();
	       		 price1.Pricebook2Id = standardpb.Id;
	       		 price1.Product2Id = referencia1.Id;
	       		 price1.UnitPrice=1000000;
	       		 price1.IsActive=true;
	       		 insert price1;
	       		 
	       system.debug('pbeprice: ' + price1.UnitPrice);
	       		 
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
	       		 
	       PricebookEntry price4 = new PriceBookEntry();
	       		 price4.Pricebook2Id = standardpb.Id;
	       		 price4.Product2Id = referencia4.Id;
	       		 price4.UnitPrice=1000000;
	       		 price4.IsActive=true;
	       		 insert price4;
	       		 
	       	 PricebookEntry price5 = new PriceBookEntry();
	       		 price5.Pricebook2Id = standardpb.Id;
	       		 price5.Product2Id = referencia5.Id;
	       		 price5.UnitPrice=1000000;
	       		 price5.IsActive=true;
	       		 insert price5;
	    
	       		 
	    
	           
	       Asset activo1 = new Asset();
	          activo1.AccountId = account1.id;
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
	          
	       Asset activo2 = new Asset();
	          activo2.AccountId = account1.id;
	          activo2.Ano_Fiscal__c = '2014';
	          activo2.Fecha_primera_activacion__c = DateOpp;
	          activo2.Codigo_activo__c = 10000101;
	          activo2.Codigo_internet__c = '456989';
	          activo2.Name = '2014_Febrero_BASDOMC32_Solución Básica_venta nueva';
	          activo2.Price = 100000;
	          activo2.Product2Id = referencia2.id;
	          activo2.InstallDate = DateOpp;
	          activo2.Status = '01. Creado';
	          insert activo2;
	          
	       Asset activo3 = new Asset();
	          activo3.AccountId = account1.id;
	          activo3.Ano_Fiscal__c = '2014';
	          activo3.Fecha_primera_activacion__c = DateOpp;
	          activo3.Codigo_activo__c = 10000099;
	          activo3.Codigo_internet__c = '456989';
	          activo3.Name = '2014_Febrero_BASDOMC3_Solución Básica_venta nueva';
	          activo3.Price = 100000;
	          activo3.Product2Id = referencia3.id;
	          activo3.InstallDate = DateOpp;
	          activo3.Status = '01. Creado';
	          insert activo3;
	          
	          
	       Asset activo4 = new Asset();
	          activo4.AccountId = account1.id;
	          activo4.Ano_Fiscal__c = '2014';
	          activo4.Fecha_primera_activacion__c = DateOpp;
	          activo4.Codigo_activo__c = 10000099;
	          activo4.Codigo_internet__c = '456989';
	          activo4.Name = '2014_Febrero_BASDOMC4_Solución Básica_venta nueva';
	          activo4.Price = 100000;
	          activo4.Product2Id = referencia4.id;
	          activo4.InstallDate = DateOpp;
	          activo4.Status = '01. Creado';
	          insert activo4;
	       
	       Asset activo5 = new Asset();
	          activo5.AccountId = account1.id;
	          activo5.Ano_Fiscal__c = '2014';
	          activo5.Fecha_primera_activacion__c = DateOpp;
	          activo5.Codigo_activo__c = 10000099;
	          activo5.Codigo_internet__c = '456989';
	          activo5.Name = '2014_Febrero_BASDOMC5_Solución Básica_venta nueva';
	          activo5.Price = 100000;
	          activo5.Product2Id = referencia5.id;
	          activo5.InstallDate = DateOpp;
	          activo5.Status = '01. Creado';
	          insert activo5;
	          
	       Opportunity opptest = new Opportunity();
	            opptest.AccountId = account2.id;
	            opptest.Ano_Fiscal__c = String.valueOf(system.now().year());
	            opptest.CloseDate    = DateOpp;
	            opptest.Name  = 'testopp';
	            opptest.OwnerId = usr.Id;
	         	opptest.Pricebook2Id = standardpb.id;
	         	opptest.StageName = '01 Preparación';
	         	insert opptest;
	         	
	         	
			
         /*Quote opp1quote1 = new Quote();
         	//opp1quote1.CreatedBy = usr.Id;
         	opp1quote1.Fecha_primera_cuota__c = DateOpp;
         	opp1quote1.Name = 'cotizacion1';
         	opp1quote1.OpportunityId = opptest.Id;
         	opp1quote1.Numero_cuotas__c=1;
         	opp1quote1.Pricebook2Id = custompb.Id;
         	insert opp1quote1;*/
         	
         	 
         Quote opp1quote1 = new Quote();
            opp1quote1.BillingName = 'cotizacion1';
            opp1quote1.Cuota_normalizada__c = true;
            opp1quote1.Fecha_primera_cuota__c = DateOpp;
            opp1quote1.Name = 'cotizacion1';
            opp1quote1.Numero_cuotas__c = 1;
            opp1quote1.OpportunityId = opptest.id;
            opp1quote1.Recalcular_cuotas__c = true;
            opp1quote1.Pricebook2Id = standardpb.Id;
            opp1quote1.Token_venta_en_linea__c = 'ABBZ1237';
            
            insert opp1quote1;  
         system.debug('billingname: ' + opp1quote1.BillingName);
        /* QuoteLineItem partpres1 = new QuoteLineItem();
         partpres1.Quantity = 1;
         partpres1.QuoteId = opp1quote1.Id;
         partpres1.PricebookEntryId = 
         //partpres1.Name = 'Partida1';
         //partpres1.Product2 = referencia1.Id;
         insert partpres1;*/
         
		 QuoteLineItem partpres1 = new QuoteLineItem();
           partpres1.Discount = null;
           partpres1.Quantity = 1;
           partpres1.QuoteId = opp1quote1.Id;
           partpres1.Description= 'dsdasd';
           partpres1.ServiceDate =DateOpp;
           partpres1.UnitPrice = 100000;
           partpres1.Token_publicidad__c = 'A7894567';
           partpres1.PricebookEntryId = price1.Id;
           //partpres1.Activo_renovacion__c = activo1.id;
           //partpres1.Activo_producido__c = activo1.id;
           insert partpres1;
           
           system.debug('unitpricebook: ' + partpres1.UnitPrice);
           system.debug('listprice: ' + partpres1.ListPrice);
           system.debug('subtotalprice: ' + partpres1.Subtotal);
           system.debug('totalprice: ' + partpres1.TotalPrice);
           
         Dato_facturacion__c datafact1 = new Dato_facturacion__c();
         	datafact1.Fecha_primera_cuota__c = DateOpp;
         	datafact1.Numero_cuotas__c = 1;
         	datafact1.Presupuesto__c = opp1quote1.Id;
         	datafact1.Valor_facturacion__c = 100000;
         	datafact1.Cuota_normalizada__c = false;
         	datafact1.billing_type__c = 'Facturación por cuotas iguales';
         	datafact1.Numero_identificacion__c = '80048578';
		 	datafact1.Tipo_identificacion__c = tiponit.Id;
		 	datafact1.Agente_recaudo__c = 'FACTURA DIRECTA';
         	insert datafact1;   
         	
        	CTR006_UpsertBillingData ubd = new CTR006_UpsertBillingData(new ApexPages.StandardController(datafact1));
        	ubd.LoadPage();
        	string strDisplayQuote = ubd.DisplayQuote;
        	decimal dcmMaxBillingValue = ubd.MaxBillingValue;
        	ubd.MaxBillingValue = dcmMaxBillingValue;
        	Quote qtRelatedQuoteInfo = ubd.RelatedQuoteInfo;
        	ubd.RelatedQuoteInfo = qtRelatedQuoteInfo;
        	Dato_facturacion__c cbiCurrentBillingInfo = ubd.CurrentBillingInfo;
        	ubd.CurrentBillingInfo = cbiCurrentBillingInfo;
        	ubd.UpsertBillingInfo();

			           
           
           Dato_facturacion__c datafact2 = new Dato_facturacion__c();
		  	datafact2.Fecha_primera_cuota__c = DateOpp;
		  	datafact2.Numero_cuotas__c = 1;
		  	datafact2.Presupuesto__c = opp1quote1.Id;
		  	datafact2.Valor_facturacion__c = 30000;
		  	datafact2.Cuota_normalizada__c = false;
		  	datafact2.billing_type__c = 'Facturación por cuotas iguales';
		 	datafact2.Agente_recaudo__c = 'CODENSA';
		 	datafact2.Numero_identificacion__c = '80048578';
		 	datafact2.Tipo_identificacion__c = tiponit.Id;
		  	datafact2.NIE__c =123;
		   	insert datafact2;         
                 
         	datafact1.NIE__c =456;
         	update datafact2;  
         
         	datafact1.Agente_recaudo__c = 'FACTURA DIRECTA';
         	update datafact2;       	
        	       	
        	        	        	     	        	        	        	        	
        	/*CTR006_UpsertBillingData ubd1 = new CTR006_UpsertBillingData(new ApexPages.StandardController(datafact2));
        	ubd1.LoadPage();
        	strDisplayQuote = ubd1.DisplayQuote;
        	dcmMaxBillingValue = ubd1.MaxBillingValue;
        	ubd1.UpsertBillingInfo();*/

        	
        	        	
        	Cuota_facturacion__c cuota1 = new Cuota_facturacion__c();
        	cuota1.Dato_facturacion__c = datafact2.Id;
        	cuota1.Valor_cuota__c = 100000;
        	cuota1.Fecha_cuota__c = DateOpp;
        	cuota1.No_Cuota__c= 1;
        	cuota1.Partida_de_presupuesto__c=partpres1.Id;
        	insert cuota1;
        	
        	//List<Cuota_facturacion__c> lstQuoteToUpdate = ubd1.getQuoteInfo();
        	
        	ApexPages.currentPage().getParameters().put('QuoteObjectId',cuota1.Id);
        	ApexPages.currentPage().getParameters().put('Field_QuoteValue','100000');
        	ApexPages.currentPage().getParameters().put('Field_QuoteDate','15/02/2015');
        	ApexPages.currentPage().getParameters().put('QuoteLineItemId',cuota1.Partida_de_presupuesto__c);
        	ApexPages.currentPage().getParameters().put('QuoteNumber','1');
        	
        	
        	CTR006_UpsertBillingData ubd2 = new CTR006_UpsertBillingData(new ApexPages.StandardController(datafact2));
        	ubd2.LoadPage();
        	strDisplayQuote = ubd2.DisplayQuote;
        	dcmMaxBillingValue = ubd2.MaxBillingValue;
        	ubd2.UpsertBillingInfo();
        	
        	/*close won opportunity*/
        	Ciudad__c ciudadj2 = new Ciudad__c();
        	ciudadj2.Name = 'Bogota';
        	insert ciudadj2;
        	
        	Opportunity opj2 = new Opportunity();
            opj2.AccountId = account1.id;
            opj2.Ano_Fiscal__c = String.valueOf(system.now().year());
            opj2.CloseDate    = DateOpp;
            opj2.Name  = 'testopp';
            opj2.OwnerId = usr.Id;
         	opj2.Pricebook2Id = standardpb.id;
         	opj2.StageName = '01 Preparación';
         	opj2.Type = CL000_Utils.C_OpportunitySaleTypeNew;
         	insert opj2;        	
        	
        	Quote qtj2 = new Quote();
        	qtj2.BillingName = 'cotizacion1';
            qtj2.Name = 'cotizacion1';
            qtj2.Ciudad_venta__c = ciudadj2.Id;
            qtj2.OpportunityId = opj2.id;
            qtj2.Pricebook2Id = standardpb.Id;
            insert qtj2;  
            
            Dato_Facturacion__c dfj2 = new Dato_Facturacion__c();
         	dfj2.Fecha_primera_cuota__c = DateOpp;
         	dfj2.Numero_cuotas__c = 1;
         	dfj2.Presupuesto__c = qtj2.Id;
         	dfj2.Valor_facturacion__c = 100000;
         	dfj2.Cuota_normalizada__c = true;
         	dfj2.Numero_identificacion__c = '80048578';
         	dfj2.Tipo_identificacion__c = tiponit.id;
         	dfj2.Agente_recaudo__c = 'CODENSA';
         	dfj2.billing_type__c = 'Facturación por cuotas iguales';
         	dfj2.NIE__c =123;
           	insert dfj2; 
           	
           	dfj2.NIE__c =456;
            update datafact2; 
            
            dfj2.Agente_recaudo__c = 'FACTURA DIRECTA';
             update dfj2; 
             
            dfj2.Agente_recaudo__c = 'CODENSA';
            dfj2.NIE__c =567;
             update dfj2; 
        	
        	CTR006_UpsertBillingData upsbill8 = new CTR006_UpsertBillingData(new ApexPages.StandardController(dfj2));
        	upsbill8.UpsertBillingInfo();
        	
        	QuoteLineItem qtlij2 = new QuoteLineItem();
           	qtlij2.Discount = 0;
           	qtlij2.Quantity = 1;
           	qtlij2.QuoteId = qtj2.Id;
           	qtlij2.Description= 'dsdasd';
           	qtlij2.ServiceDate =DateOpp;
           	qtlij2.UnitPrice = 100000;
           	qtlij2.PricebookEntryId = price1.Id;
        	insert qtlij2;
        	
        	//Dato_Facturacion__c dfj2 = new Dato_Facturacion__c();
         	//dfj2.Fecha_primera_cuota__c = DateOpp;
         	//dfj2.Numero_cuotas__c = 1;
         	//dfj2.Presupuesto__c = qtj2.Id;
         	//dfj2.Valor_facturacion__c = 100000;
         	//dfj2.Cuota_normalizada__c = true;
         	//dfj2.billing_type__c = 'Facturación por cuotas iguales';
           	//update dfj2;           	
        	
        	Cuota_Facturacion__c cfj2 = new Cuota_Facturacion__c();  
        	cfj2.Dato_facturacion__c = dfj2.Id;
        	cfj2.Valor_cuota__c = 100000;
        	cfj2.Fecha_cuota__c = DateOpp;
        	cfj2.No_Cuota__c= 1;
        	cfj2.Partida_de_presupuesto__c=qtlij2.Id;
        	insert cfj2;
        	
        	      	
        	/*Dato_Facturacion__c dfj3 = new Dato_Facturacion__c();
         	dfj3.Fecha_primera_cuota__c = DateOpp;
         	dfj3.Numero_cuotas__c = 1;
         	dfj3.Presupuesto__c = qtj2.Id;
         	dfj3.Valor_facturacion__c = 100000;
         	dfj3.Cuota_normalizada__c = true;
         	dfj3.billing_type__c = 'Facturación por cuotas iguales';
           	insert dfj3;*/           	
        	
        	

        	CTR005_SyncQuote syncq1 = new CTR005_SyncQuote(new ApexPages.StandardController(qtj2));
        	syncq1.StartSync();
        	
        	//opj2.StageName = 'Closed Won';
        	update opj2;
        	
        	CTR006_UpsertBillingData upsbill = new CTR006_UpsertBillingData(new ApexPages.StandardController(dfj2));
        	upsbill.renderpage();
        	
        	
        	dfj2.billing_type__c = 'Facturación Especial';
        	update dfj2;
        	
        	CTR006_UpsertBillingData upsbill4 = new CTR006_UpsertBillingData(new ApexPages.StandardController(dfj2));
        	upsbill4.UpsertBillingInfo();        	
        	
        	CTR005_SyncQuote syncq2 = new CTR005_SyncQuote(new ApexPages.StandardController(qtj2));
        	syncq2.StartSync();
        	
        	
        	CTR006_UpsertBillingData upsbill1 = new CTR006_UpsertBillingData(new ApexPages.StandardController(dfj2));
        	upsbill1.renderpage();
        	
        	dfj2.billing_type__c = 'Facturación por vigencia';
        	update dfj2;
        	
        	CTR006_UpsertBillingData upsbill7 = new CTR006_UpsertBillingData(new ApexPages.StandardController(dfj2));
        	upsbill7.UpsertBillingInfo();
        	
        	CTR006_UpsertBillingData upsbill89 = new CTR006_UpsertBillingData(new ApexPages.StandardController(dfj2));
        	upsbill7.SWMasterdata();
        	
        	CTR006_UpsertBillingData upsbill5 = new CTR006_UpsertBillingData(new ApexPages.StandardController(dfj2));
        	upsbill5.renderpage();
        	upsbill5.renderagrecaudo();
        	
        	CTR006_UpsertBillingData upsbill6 = new CTR006_UpsertBillingData(new ApexPages.StandardController(dfj2));
        	upsbill6.getQuoteLineIteminf();  
        	
        	CTR006_UpsertBillingData upsbill9 = new CTR006_UpsertBillingData(new ApexPages.StandardController(dfj2));
        	upsbill9.autocomplete = true;
        	upsbill9.autocompleteinf();  
        	
        	CTR006_UpsertBillingData upsbil10 = new CTR006_UpsertBillingData(new ApexPages.StandardController(datafact1));
        	upsbil10.autocomplete = true;
        	upsbil10.UpdateDataidentification();
        	upsbil10.autocompleteinf();  
        	
        	System.debug('jairo :::::  ' + string.valueof(opj2.IsClosed));
        	
        	CTR009_AssetAutomatization SyncAssetJ2 = new CTR009_AssetAutomatization(new ApexPages.StandardController(opj2));
        	SyncAssetJ2.StartSync();
        	
        	opj2.StageName = 'Closed Lost';
        	//update opj2;
        	
        	System.debug('jairo :::::  ' + string.valueof(opj2.IsClosed));
        	
        	/*CTR009_AssetAutomatization SyncAssetJ3 = new CTR009_AssetAutomatization(new ApexPages.StandardController(opj2));
        	SyncAssetJ3.StartSync();*/
        	//SyncAssetJ2.StartSync();
	
	Test.stopTest();
	}
}