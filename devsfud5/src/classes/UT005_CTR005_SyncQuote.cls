/*
*   unit test over CTR005_SyncQuote class
*   24 Enero 2014 - Joe Ayala
*/

@isTest (SeeAllData=true)
public with sharing class UT005_CTR005_SyncQuote
{

 static testMethod void validesync() 
 {
    	
    	 //fnCrearData();
        Test.startTest();
       
          Date DateOpp = date.newinstance(2136, 12, 31);	
         Date Datemen = date.newinstance(2012, 12, 31);	
         Profile prof=[Select Id from Profile limit 1];
         Tipo_identificacion__c  tiponit = [SELECT Id,Name FROM Tipo_identificacion__c where Name = 'CC'];
         
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
            
        Account acc1 = new Account();
            acc1.Activo__c = true;
            acc1.Codigo_cliente_unico__c = 123;
            acc1.Name = 'cuenta1';
            acc1.OwnerId= usr.Id;
            acc1.Tipo_identificacion__c = tiponit.Id;
            acc1.Numero_identificacion__c= '80048577'; 
            insert acc1;
            
         product2 prod2 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10);
           insert prod2;
           
          product2 prod3 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10,Linea_de_produccion__c = 'Solución Básica');
           insert prod3;  
    
       pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
       pricebook2 custompb = new pricebook2(name='test',isactive=true);
    insert custompb;
    pricebookentry standardprice = new pricebookentry( product2id = prod2.id, pricebook2id = standardpb.id,IsActive=true,  UnitPrice=100), 
              		 customprice = new pricebookentry( product2id = prod2.id, pricebook2id = custompb.id, IsActive=true, UnitPrice=100, usestandardprice = true );
    insert standardprice;
    insert customprice;
        
       
         
           
         
    
          
           
           
          Opportunity opp1 = new Opportunity();   
            opp1 = new Opportunity();
            opp1.AccountId = acc1.id;
            opp1.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp1.CloseDate    = DateOpp;
            opp1.Name  = 'opportprueba';
            opp1.OwnerId = usr.Id;
            opp1.StageName = '01 Preparación';
         	opp1.Pricebook2Id = custompb.Id;
         	insert opp1;
         	
         	system.debug('Oportunidad_Preparación ');
         	
         	         	
           List<ProcessInstance> ap = [SELECT ID,Status, TargetObjectID
				FROM ProcessInstance
				limit 1];
				system.debug('processInstance_List' + ap);
				

         Quote cotiz1 = new Quote();
            cotiz1.BillingName = 'carvajal';
            cotiz1.Cuota_normalizada__c = true;
            cotiz1.Fecha_primera_cuota__c = DateOpp;
            cotiz1.Name = 'carvajal';
            cotiz1.Numero_cuotas__c = 1;
            cotiz1.OpportunityId = opp1.id;
            cotiz1.Recalcular_cuotas__c = true;
            cotiz1.Pricebook2Id = custompb.Id;
            cotiz1.Token_venta_en_linea__c = 'AABBCC12';
            insert cotiz1;
            
        Quote cotiz2 = new Quote();
            cotiz2.BillingName = 'carvajal';
            cotiz2.Cuota_normalizada__c = false;
            cotiz2.Fecha_primera_cuota__c = DateOpp;
            cotiz2.Name = 'carvajal';
            cotiz2.Numero_cuotas__c = 2;
            cotiz2.OpportunityId = opp1.id;
            cotiz2.Recalcular_cuotas__c = true;
            cotiz2.Pricebook2Id = custompb.Id;
            cotiz2.Token_venta_en_linea__c = 'ABBZ1237';
            insert cotiz2;  
            
         
            cotiz2.BillingName = 'carvajal';
            cotiz2.Cuota_normalizada__c = false;
            cotiz2.Recalcular_cuotas__c = false;
            update cotiz2; 
            
          
            Asset activo = new Asset();
          activo.AccountId = acc1.id;
          activo.Fecha_primera_activacion__c = DateOpp;
          activo.InstallDate = DateOpp;
          activo.Status = '01. Creado';
          activo.Product2Id= prod2.id;
          activo.Name = 'activoname';
          activo.Codigo_activo__c=10000000;
          insert activo;
          
           Asset activo2 = new Asset();
          activo2.AccountId = acc1.id;
          activo2.Fecha_primera_activacion__c = DateOpp;
          activo2.InstallDate = DateOpp;
          activo2.Status = '01. Creado';
          activo2.Product2Id= prod3.id;
          activo2.Name = 'activoname';
          activo2.Codigo_activo__c=10000000;
          insert activo2;
          
          
          
          
           
           QuoteLineItem prodUCTOPP = new QuoteLineItem();
           prodUCTOPP.Discount = 30;
           prodUCTOPP.Quantity = 1;
           prodUCTOPP.QuoteId = cotiz1.id;
           prodUCTOPP.Description= 'dsdasd';
           prodUCTOPP.ServiceDate =DateOpp;
           prodUCTOPP.UnitPrice = 100000;
           prodUCTOPP.Token_publicidad__c = 'A7894567';
           prodUCTOPP.PricebookEntryId = customprice.id;
           prodUCTOPP.Activo_renovacion__c = activo.id;
           insert prodUCTOPP; 
           system.debug('prodUCTOPP' +prodUCTOPP);
           
            QuoteLineItem prodUCTOop = new QuoteLineItem();
           prodUCTOop.Discount = 30;
           prodUCTOop.Quantity = 1;
           prodUCTOop.QuoteId = cotiz2.id;
           prodUCTOop.Description= 'dsdasd';
           prodUCTOop.ServiceDate =DateOpp;
           prodUCTOop.UnitPrice = 100000;
           prodUCTOop.Token_publicidad__c = 'zzzz';
           prodUCTOop.PricebookEntryId = customprice.id;
           prodUCTOop.Activo_renovacion__c = activo2.id;
           insert prodUCTOop; 
 
            
            Cuota__c cuota = new Cuota__c();
            cuota.Fecha_cuota__c = DateOpp;
            cuota.No_Cuota__c = 1;
            cuota.Valor_cuota__c = 10;
            cuota.Presupuesto__c =cotiz2.Id;
            insert cuota;
            
      
           
        
        CTR005_SyncQuote sincr = new CTR005_SyncQuote(new ApexPages.StandardController(cotiz1)
        );
        sincr.StartSync();
        CTR005_SyncQuote sincr2 = new CTR005_SyncQuote(new ApexPages.StandardController(cotiz2)
        );
        sincr2.StartSync();
   
        Test.stopTest();
    }








 static void fnCrearData()
    {
        try{
         Date DateOpp = date.newinstance(2136, 12, 31);	
         Date Datemen = date.newinstance(2012, 12, 31);	
         Profile prof=[Select Id from Profile limit 1];
         Tipo_identificacion__c  tiponit = [SELECT Id,Name FROM Tipo_identificacion__c where Name = 'CC'];
         
         User usrgestor=new User();
            usrgestor.FirstName='Prueba';
            usrgestor.LastName='Manager';
            usrgestor.Username='GESTOR@publicar.com';
            usrgestor.Email='GESTOR@publicar.com';
            usrgestor.Alias='asesor';
            usrgestor.Country= 'Colombia';
            usrgestor.City = 'Bogotá D.C.';
            usrgestor.CommunityNickname='p-asesor1';
            usrgestor.TimeZoneSidKey='GMT';
            usrgestor.LocaleSidKey='es_CO';
            usrgestor.EmailEncodingKey='ISO-8859-1';
            usrgestor.ProfileId=prof.Id;
            usrgestor.LanguageLocaleKey='es';
            insert usrgestor;
         
         User usr=new User();
            usr.FirstName='Prueba';
            usr.LastName='Asesor';
            usr.Username='asesor@publicar.com';
            usr.Email='asesor@publicar.com';
            usr.Alias='asesoryu';
            usr.Country= 'Colombia';
            usr.City = 'Bogotá D.C.';
            usr.CommunityNickname='p-asesor';
            usr.TimeZoneSidKey='GMT';
            usr.LocaleSidKey='es_CO';
            usr.EmailEncodingKey='ISO-8859-1';
            usr.ProfileId=prof.Id;
            usr.LanguageLocaleKey='es';
            usr.ManagerId = usrgestor.Id;
            insert usr;
            
        Account acc1 = new Account();
            acc1.Activo__c = true;
            acc1.Codigo_cliente_unico__c = 123;
            acc1.Name = 'cuenta1';
            acc1.OwnerId= usr.Id;
            acc1.Tipo_identificacion__c = tiponit.Id;
            acc1.Numero_identificacion__c= '80048577'; 
            insert acc1;
            
        Pricebook2 lista = new Pricebook2();
            lista.IsActive = true;
            lista.Name= 'lista1';
            insert lista;
        
        Opportunity opp1 = new Opportunity();   
            opp1 = new Opportunity();
            opp1.AccountId = acc1.id;
            opp1.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp1.CloseDate    = DateOpp;
            opp1.Name  = 'opportprueba';
            opp1.OwnerId = usr.Id;
         	opp1.Pricebook2Id = lista.id;
         	opp1.StageName = '01 Preparación';
         	insert opp1;
         	
         	system.debug('Oportunidad_Preparación ');
         	
         	         	
           List<ProcessInstance> ap = [SELECT ID,Status, TargetObjectID
				FROM ProcessInstance
				limit 1];
				system.debug('processInstance_List' + ap);
				

        Quote cotiz1 = new Quote();
            cotiz1.BillingName = 'carvajal';
            cotiz1.Cuota_normalizada__c = true;
            cotiz1.Fecha_primera_cuota__c = DateOpp;
            cotiz1.Name = 'carvajal';
            cotiz1.Numero_cuotas__c = 2;
            cotiz1.OpportunityId = opp1.id;
            cotiz1.Recalcular_cuotas__c = true;
            insert cotiz1;
            
        Quote cotiz2 = new Quote();
            cotiz2.BillingName = 'carvajal';
            cotiz2.Cuota_normalizada__c = false;
            cotiz2.Fecha_primera_cuota__c = DateOpp;
            cotiz2.Name = 'carvajal';
            cotiz2.Numero_cuotas__c = 2;
            cotiz2.OpportunityId = opp1.id;
            cotiz2.Recalcular_cuotas__c = true;
            
            insert cotiz2;  
            
         
            cotiz2.BillingName = 'carvajal';
            cotiz2.Cuota_normalizada__c = false;
            cotiz2.Recalcular_cuotas__c = false;
            update cotiz2; 
            
            system.debug('modifico_la_cuota' + cotiz2); 
            
            Cuota__c cuota = new Cuota__c();
            cuota.Fecha_cuota__c = DateOpp;
            cuota.No_Cuota__c = 1;
            cuota.Valor_cuota__c = 10;
            cuota.Presupuesto__c =cotiz2.Id;
            insert cuota;
            
            
           
            
            cotiz2.BillingName = 'carvajal';
            cotiz2.Cuota_normalizada__c = false;
            cotiz2.Recalcular_cuotas__c = true;
            update cotiz2; 
         
       Product2 referencia = new Product2();
           referencia.Family = 'Soluciones Web';
           referencia.Genera_Produccion__c = true;
           referencia.IsActive = true;
           referencia.Linea_de_negocio__c = 'Soluciones Digitales';
           referencia.Linea_de_produccion__c = 'Solución Básica';
           referencia.Meses_Vigencia__c = 2;
           referencia.Name = 'REFERENCIA';
           referencia.ProductCode = 'BASDOMC2';
           referencia.Producto_financiero__c = 'ABX1231321';
           referencia.Tipo_de_produccion__c = 'Soluciones web';
           referencia.Venta_limitada__c = false;
           insert referencia;
                      
        PricebookEntry  prodentry = new PricebookEntry();
           prodentry.IsActive = true;
           prodentry.Pricebook2Id = lista.Id;
           prodentry.Product2Id = referencia.id;
           prodentry.UnitPrice = 450000;
           prodentry.UseStandardPrice = false;  
           insert prodentry; 
           
       QuoteLineItem prod = new QuoteLineItem();
           prod.Discount = 10;
           prod.Quantity = 1;
           prod.QuoteId = cotiz1.id;
           prod.Description= 'dsdasd';
           prod.ServiceDate =DateOpp;
           prod.UnitPrice = 1000;
           prod.PricebookEntryId = prodentry.id;
           prod.Token_publicidad__c = 'A7894567';
           insert prod;
           
         
          cuota.Valor_cuota__c = 5;
           update cuota;  
           
           cuota.Fecha_cuota__c = Datemen;
           update cuota;
           
           
            cotiz2.Cuota_normalizada__c = false;
            cotiz2.Recalcular_cuotas__c = true;
            update cotiz2;  
            
            
            cotiz2.Cuota_normalizada__c = true;
            cotiz2.Recalcular_cuotas__c = false;
            update cotiz2;  
            
            
          Asset activo = new Asset();
          activo.AccountId = acc1.id;
          activo.Fecha_primera_activacion__c = DateOpp;
          activo.InstallDate = DateOpp;
          activo.Status = '01. Creado';
          insert activo;
          
          activo.InstallDate = DateOpp.addDays(1);
          activo.Status = '03. Activo';
          update activo;
          
          
          Movimiento_produccion__c movimiento = new Movimiento_produccion__c();
          movimiento.Activo__c = activo.id;
          movimiento.Etapa__c = '01. Por Producir';
          movimiento.Tipo_movimiento__c = 'Producto nuevo';
          insert movimiento;
                	
        }catch(System.exception ex)
        {
            System.debug('\n\n ##Error##' + ex + '\n\n');
        }
   
    }

}