/*
*   unit test over utils class
*   21 Enero 2014 - Joe Ayala
*   Versión: 1.1  SIF 12/03/2014 Desarrollo de la clase de pruebas para archivos x casos
*/

@isTest (SeeAllData=true)
public class UT004_CTR001_NewS3File{
	

 static testMethod void filennew() {
    	
    	//fnCrearData();
        Test.startTest();
        //Cargar Data
        
         
         
         //objetos necesarios para el test -----------------------------------------------------------------------
         
         Date DateOpp = date.newinstance(2136, 12, 31);	
         	Profile prof=[Select Id from Profile limit 1];
        	Tipo_identificacion__c  tiponit = [SELECT Id,Name FROM Tipo_identificacion__c where Name = 'CC'];
        	
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
        	
        	Account acc3 = new Account();
            acc3.Activo__c = true;
            acc3.Codigo_cliente_unico__c = 123;
            acc3.Name = 'cuenta1';
            acc3.OwnerId= usr.Id;
            acc3.Tipo_identificacion__c = tiponit.Id;
            acc3.Numero_identificacion__c= '80048577'; 
            insert acc3;
        	
        	Case caso = new Case();
        	caso.Description='Caso para pruebas de archivos por caso';
        	caso.Status = 'Nuevo';
            caso.Origin = 'Telefónico';
            caso.Priority = 'Media';
            caso.Nombres_contacto__c = 'Usuario 1';
            caso.Apellidos_contacto__c= 'apellidos';
            caso.Telefono_contacto__c = '123456';
            caso.Correo_electronico_del_contacto__c = 'mimail@yahoo.es';
        	insert caso;
        	
        	Pricebook2 lista = new Pricebook2();
            lista.IsActive = true;
            lista.Name= 'lista1';
            insert lista;
            
        	Opportunity opp3 = new Opportunity();
        	opp3 = new Opportunity();
            opp3.AccountId = acc3.id;
            opp3.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp3.CloseDate    = DateOpp;
            opp3.Name  = 'opportprueba';
            opp3.OwnerId = usr.Id;
         	opp3.Pricebook2Id = lista.id;
         	opp3.StageName = '01 Preparación';
         	insert opp3;
         	
         	system.debug('Oportunidad_Preparación ');
        	
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
	           referencia.Numero_cuotas_maximo__c=2;
	           insert referencia;
        	
        	Asset activo = new Asset();
	          activo.AccountId = acc3.id;
	          activo.Ano_Fiscal__c = '2014';
	          activo.Fecha_primera_activacion__c = DateOpp;
	          activo.Codigo_activo__c = 10000089;
	          activo.Codigo_internet__c = '123';
	          activo.Name = '2014_1. Enero_BASDOMC2_Solución Básica_venta nueva';
	          activo.Price = 100000;
	          activo.Product2Id = referencia.id;
	          activo.InstallDate = DateOpp;
	          activo.Status = '01. Creado';
	          insert activo;
	          
	                    
	          
	          Movimiento_produccion__c movimiento = new Movimiento_produccion__c();
	          movimiento.Activo__c = activo.id;
	          movimiento.Etapa__c = '01. Por Producir';
	          movimiento.Tipo_movimiento__c = 'Producto nuevo';
	          insert movimiento;
        	
        	Extension_archivo__c ext = [SELECT Extension__c,Id,Name FROM Extension_archivo__c WHERE Extension__c = 'pdf' LIMIT 1];
        	system.debug('Sabrina Prueba archivos x casos:' +  ext);
        	
        	Archivo_amazon_s3__c newfile =new Archivo_amazon_s3__c();
        	newfile.Bucket__c = 'SalesforceDevSFUd';
            newfile.Es_carpeta__c = false;
            newfile.Extension_archivo__c = 	ext.id;
            newfile.Name ='contrato';
            newfile.Permisos_archivo__c = '01. Lectura';
            newfile.Tipo_contenido__c = 'Contrato digitalizado';
            newfile.Ubicacion_archivo__c = '10000000/Oportunidades/UD00000031';
        	insert newfile;
        	
        	Archivo_por_oportunidad__c fileopo = new Archivo_por_oportunidad__c();
        	fileopo.Name = 'ArchivoTest';
        	fileopo.Extension__c = 'jpg';
        	fileopo.Oportunidad__c = opp3.id;
        	fileopo.Tipo_contenido__c = 'Contrato digitalizado';
        	
        	Archivo_por_movimiento_produccion__c filemov = new Archivo_por_movimiento_produccion__c();
        	filemov.Name = 'ArchivoTest';
        	filemov.Es_carpeta__c = true;
        	filemov.Movimiento_produccion__c = movimiento.id;
        	filemov.Tipo_contenido__c = 'Publicable';
            
    		Archivo_por_activo__c fileasset = new 	Archivo_por_activo__c();
    		fileasset.Name =  'ArchivoTest';
    		fileasset.Extension__c = 'ppt';
    		fileasset.Activo__c = activo.id;
        	fileasset.Tipo_contenido__c = 'ESTADISTICAS';  	
        	
        	Archivo_por_caso__c filecase = new 	Archivo_por_caso__c();
    		filecase.Name =  'ArchivoTestCaso';
    		filecase.Extension__c = 'ppt';
    		filecase.Caso__c=caso.Id;
    		filecase.Tipo_contenido__c = 'ESTADISTICAS';  	
        	        	
        	
        //----------------------------------------------------------------------------------------------------------------	
         
         System.Pagereference pr1 = Apexpages.currentPage();
         CTR001_NewS3File_Opportunity_Step0  constr2 = new CTR001_NewS3File_Opportunity_Step0(new ApexPages.StandardController(fileopo));
		 constr2.NextStep0();
                  
         CTR001_NewS3File_ProductionMov_Step0 constr3 = new CTR001_NewS3File_ProductionMov_Step0(
		 new ApexPages.StandardController(filemov)); 
		 System.Pagereference pr2 = constr3.NextStep0();
         
         CTR001_NewS3File_Asset_Step0 constr4 = new CTR001_NewS3File_Asset_Step0(
         new ApexPages.StandardController(fileasset) );
         System.Pagereference pr3 = constr4.NextStep0();
         
         fileasset.Activo__c= null;
         CTR001_NewS3File_Asset_Step0 constr6 = new CTR001_NewS3File_Asset_Step0(
         new ApexPages.StandardController(fileasset) );
         System.Pagereference pr6 = constr6.NextStep0();
         
         CTR001_NewS3File_Case_Step0 constr7 = new CTR001_NewS3File_Case_Step0(
         new ApexPages.StandardController(filecase) );
         System.Pagereference pr7 = constr7.NextStep0();
                         
		 Apexpages.currentPage().getParameters().put('FileId', pr2.getParameters().get('FileId'));                
		 Apexpages.currentPage().getParameters().put('retURL', pr2.getParameters().get('retURL'));
                
      	 System.debug('jairo1' + Apexpages.currentPage().getParameters().get('FileId'));
      	 
      	 System.debug('jairo2' + pr1.getParameters().get('FileId'));
      	       
         CTR001_NewS3File_Step1 constrStep1 = new CTR001_NewS3File_Step1(
		 new ApexPages.StandardController(newfile));	
		 
         String re = constrStep1.FileName; 
         re =constrStep1.getPolicy();
         re = constrStep1.key;  
         re = constrStep1.getSignedPolicy();  
         re = constrStep1.FileUploadVisible; 
         re = constrStep1.FileAccess; 
         
         
         Test.stopTest();
    }
	
}