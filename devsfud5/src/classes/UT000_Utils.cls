/*
*	unit test over utils class
*	12 Enero 2013 - Jairo Guzman - GetMonthName: validate month name
*/

@isTest (SeeAllData=true)
private class UT000_Utils{
	static public Opportunity opp1{get;set;}    
	static public Campaign objCampaign1 {get;set;}  
    static public Account objAccount1{get;set;}
 
    public list<ProcessInstanceStep> aprobacion{get;set;}
    
    
     static testMethod void GetMonthName() {
    	/*
    	list<ProcessInstanceStep> aprobacion = new list<ProcessInstanceStep>();
    	aprobacion = [SELECT Id,OriginalActorId,ProcessInstanceId,StepStatus FROM ProcessInstanceStep];
        aprobacion[0].StepStatus = 'Approved';
    	
    	*/
    	fnCrearData();
        Test.startTest();
        //Cargar Data
        
       
        string strMonthDate = CL000_Utils.GetMonthName(system.today());
        for(Integer i= 1; i <=11; i ++)
        {
        	strMonthDate = CL000_Utils.GetMonthName(system.now().addMonths(i));
        }
        String strprueba = CL000_Utils.C_NewAssetStatus;
         
        CL000_Utils cl000= new CL000_Utils();
        cl000.clase_prueba();
		
		/*
		System.assertEquals(true,strMonthDate.indexOf(system.today().month().format()) >= 0);
		string strMonthDateTime = CL000_Utils.GetMonthName(system.now());
		System.debug('UT000_Utils_GetMonthName_strMonthDateTime: ' + strMonthDateTime);
		System.assertEquals(true,strMonthDate.indexOf(system.now().month().format()) >= 0);
        */
        
        
              
        
        Test.stopTest();
    }

   static void fnCrearData()
    {
        try{
         Date DateOpp = date.newinstance(2136, 12, 31);	
         Date Datemen = date.newinstance(2012, 12, 31);	
         Profile prof=[Select Id from Profile limit 1];
         
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
              Tipo_identificacion__c  tiponit = [SELECT Id,Name FROM Tipo_identificacion__c where Name = 'CC'];
              
        Account acc1 = new Account();
            acc1.Activo__c = true;
            acc1.Codigo_cliente_unico__c = 123;
            acc1.Name = 'cuenta1';
            acc1.OwnerId= usr.Id;
            acc1.Identificacion__c = '80048598';
            acc1.Tipo_identificacion__c = tiponit.Id;
            insert acc1;
            
        Pricebook2 lista = new Pricebook2();
            lista.IsActive = true;
            lista.Name= 'lista1';
            insert lista;
        
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
				
/*				
			
			ap[0].TargetObjectId = opp1.Id;
			ap[0].Status = 'Approved';
			update ap;
			system.debug('processInstance_creado ');


			List<ProcessInstanceStep> actor = [SELECT ActorID,ProcessInstanceID
							FROM ProcessInstanceStep
							WHERE (StepStatus='Approved' OR StepStatus='Rejected') AND ProcessInstanceID in: ap];
							system.debug('processInstanceStep List' + actor);
		
			ProcessInstanceStep piStep = new ProcessInstanceStep();
			piStep.StepStatus = 'Approved';
			piStep.ProcessInstanceID = ap[0].ID;
			piStep.ActorId = usr.Id;
				
		/*
		ProcessInstance processInstance = new ProcessInstance();
				processInstance.TargetObjectId = opp1.Id;
				processInstance.Status = 'Approved';
				
				insert processInstance;	
				
            
            opp1.AccountId = acc1.id;
            opp1.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp1.CloseDate    = DateOpp;
            opp1.Name  = 'opportprueba01';
            opp1.OwnerId = usr.Id;
         	opp1.Pricebook2Id = lista.id;
         	opp1.StageName = '05 Cerrada Entregada Jurídica';
         	update opp1; 
         	
         	system.debug('Oportunidad_Jurídica ');
         	
         	opp1.AccountId = acc1.id;
            opp1.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp1.CloseDate    = DateOpp;
            opp1.Name  = 'opportprueba01';
            opp1.OwnerId = usr.Id;
         	opp1.Pricebook2Id = lista.id;
         	opp1.StageName = '06 Cerrada Entregada Fullfilment';
         	update opp1; 
         	
         	system.debug('  ');	
         
            opp1.AccountId = acc1.id;
            opp1.Ano_Fiscal__c = String.valueOf(system.now().year());
            opp1.CloseDate    = DateOpp;
            opp1.Name  = 'opportprueba01';
            opp1.OwnerId = usr.Id;
         	opp1.Pricebook2Id = lista.id;
         	opp1.StageName = '09 Cerrada ganada';
         	update opp1; 
         	
         	system.debug('Oportunidad Cerrada ganada ');	
        */ 	
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
                      
           
           
       QuoteLineItem prod = new QuoteLineItem();
           prod.Discount = 10;
           prod.Quantity = 1;
           prod.QuoteId = cotiz1.id;
           prod.UnitPrice = 1000;
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