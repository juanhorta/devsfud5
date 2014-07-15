/*
*   unit test over asset automatization
*   16 Enero 2013 - Joe Ayala - Clase de prueba TG003_Asset_UpdateLifeTime
*/
@isTest (SeeAllData=true)
public class UT003_Asset_UpdateLifeTime
{ 
    static public Opportunity opp1{get;set;} 
     
     static testMethod void GetMonthName() {
    	
    	fnCrearData();
        Test.startTest();
        //Cargar Data
        CL002_AssetsProcessing asses = new CL002_AssetsProcessing();
        //asses.clase_prueba();       
                
        Test.stopTest();
    }
     
    
    
    static void fnCrearData()
    {
        try{
         Date DateOpp = date.newinstance(2136, 12, 31);	
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
                      
           
            
          Asset activo = new Asset();
          activo.AccountId = acc1.id;
          activo.Ano_Fiscal__c = '2014';
          activo.Fecha_primera_activacion__c = DateOpp;
          activo.Codigo_activo__c = 1000000;
          activo.Codigo_internet__c = '123';
          activo.Name = '2014_1. Enero_BASDOMC2_Solución Básica_venta nueva';
          activo.Price = 100000;
          activo.Product2Id = referencia.id;
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
          
          movimiento.Etapa__c = '02. Pendiente';
          update movimiento;
          
          movimiento.Etapa__c = '99. Entregado';
          update movimiento;
          
          movimiento.Etapa__c = '95. Anulado';
          update movimiento;
          
          movimiento.Etapa__c = '01. Por Producir';
          update movimiento;
          
          movimiento.Etapa__c = '07. Suspendido';
          update movimiento;
          
           movimiento.Etapa__c = '04. Pausado';
          update movimiento;
          
          
          Asset activo2 = new Asset();
          activo2.AccountId = acc1.id;
          activo2.Ano_Fiscal__c = '2014';
          activo2.Fecha_primera_activacion__c = DateOpp;
          activo2.Codigo_activo__c = 1000000;
          activo2.Codigo_internet__c = '456';
          activo2.Name = '2014_1. Enero_BASDOMC2_Solución Básica_venta nueva';
          activo2.Price = 100000;
          activo2.Product2Id = referencia.id;
          activo2.InstallDate = DateOpp;
          activo2.Status = '01. Creado';
          activo2.Activo_relacionado__c = activo.id;
          insert activo2;
          
          activo2.InstallDate = DateOpp.addDays(1);
          activo2.Status = '03. Activo';
          update activo2;
                	
        }catch(System.exception ex)
        {
            System.debug('\n\n ##Error##' + ex + '\n\n');
        }
   
    } 
      
}