/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Sebastian quintero
*  Fecha:               Julio 01 de 2014
*  Decripción:          Clase de prueba del historico en activos
*  @version:            1.0
* ===================================================================================================================================
**/

@isTest (SeeAllData=true)
public with sharing class UT012_CL015_AssetHistory {


   static testMethod void fnTest1() 
   {
        fnCrearData();
        Test.startTest();
        system.debug('prueba Activo'  );
        Test.stopTest();
   }
   
    static void fnCrearData()
    {
        try{
         system.debug('Entro_a_fnCrearData');   
         Date DateNew = date.newinstance(2136, 12, 31); 
         Date DateOld = date.newinstance(2012, 12, 31); 
         
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
                
          Account acc1 = new Account();
            acc1.Activo__c = true;
            acc1.Codigo_cliente_unico__c = 123;
            acc1.Name = 'cuenta1';
            acc1.OwnerId= usr.Id;
            acc1.Tipo_identificacion__c = tiponit.Id;
            acc1.Numero_identificacion__c= '80048577';
            insert acc1;
            system.debug('creamos_Account' + acc1); 
          
          product2 prod2 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10);
          insert prod2;
               
          product2 prod3 = new product2( name='test',isactive=true,Numero_cuotas_maximo__c = 3, Meses_Vigencia__c = 2,Venta_limitada__c = TRUE,Descuento_autorizado__c= 10,Linea_de_produccion__c = 'Solución Básica', Linea_de_negocio__c = 'Soluciones Digitales');
          insert prod3;  
          
          system.debug('creamos_el_product2' + prod3);
            
          pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
            
          pricebook2 custompb = new pricebook2(name='test',isactive=true);
          insert custompb;
       
          pricebookentry standardprice = new pricebookentry( product2id = prod2.id, pricebook2id = standardpb.id,IsActive=true,  UnitPrice=100000), 
          customprice = new pricebookentry( product2id = prod2.id, pricebook2id = custompb.id, IsActive=true, UnitPrice=100000, usestandardprice = true );
        
          insert standardprice;
          insert customprice;
          
          Asset activo = new Asset();       
            activo.Name = '2014_23_May_ORO_Suscripción SaludGurú_Migracion';
            activo.Codigo_activo__c = 12345679;
            activo.AccountId = acc1.id;
            activo.Status = '01. Creado'; 
            activo.Product2Id = prod3.Id;  
            
            //                  
            activo.Identificador__c = 'MES1';
            activo.Nivel_de_Satisfaccion__c = 'SATISFECHO';
            activo.Etapa__c = 'ADOPCION';
            activo.Area_Causal__c = 'Diseño';
            activo.Causal__c = 'ASESORIA DISEÑO';
            insert activo;
            system.debug('creamos_el_activo' + activo);   
            
            //
            activo.Status = '02. En Producción'; 
            activo.UsageEndDate = dateOld; 
            update activo;
            system.debug('modificamos_el_activo' + activo);             
            
            //
            activo.Identificador__c = 'MES1';
            activo.Nivel_de_Satisfaccion__c = 'POR CONFIRMAR';
            update activo;
            system.debug('modificamos_el_activo' + activo);  
            
            //
            activo.Identificador__c = 'MES2';
            activo.Nivel_de_Satisfaccion__c = 'NO SATISFECHO';
            activo.Etapa__c = 'FIDELIZACION';
            activo.Area_Causal__c = 'Fulfillment';
            activo.Causal__c = 'CALIDAD PRODUCTO';
            update activo;
            system.debug('modificamos_el_activo' + activo); 
            
            //
          	activo.Status = '05. Pausado';
         	update activo;
          	system.debug('modificamos_el_activo' + activo);
          	
          	//
          	activo.UsageEndDate =	dateNew;
         	update activo;
          	system.debug('modificamos_el_activo' + activo);  
         
        }
        catch(System.exception ex)
        {
            System.debug('\n\n ##Error##' + ex + '\n\n');
        }       
    }

}