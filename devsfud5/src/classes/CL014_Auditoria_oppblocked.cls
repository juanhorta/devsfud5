/**********************************************************************************************************************************    
    * JAAR 28-03-2014 Script que audita las oprotunidades y desbloquea la oportunidad y sus relacionados si encuentra inconsistencias
                      especificamente en las oportunidades devueltas por fulfillment y cartera, su objetivo es ejecutarse como tarea
                      programada para corregir las inconsistencias presentadas por este concepto.
 ***********************************************************************************************************************************/


global  class CL014_Auditoria_oppblocked implements Schedulable { 
CL007_Mail_ctr sndMail;
Map<Id,String> oppacorregir;   
public String email;    
public Boolean sendEmail; 
public Boolean ON_Tarea_Devueltas ;

public String emailCG;    
public Boolean sendEmailCG; 
public Boolean ON_Tarea_CG ;

                                    
     global void execute(SchedulableContext ctx)
    {
       sndMail			= new CL007_Mail_ctr();     
       oppacorregir		= new Map<Id,String>();
       //BLOQUEO DE OPORTUNIDADES DEVUELTAS =====================================================================
       Trabajos_Programados__c TaskSettings = Trabajos_Programados__c.getAll().get('DesbloqueoDevueltas'); 
       this.email 		= TaskSettings.Notify__c;
       this.sendEmail	= TaskSettings.Email_Notification__c;
       this.ON_Tarea_Devueltas    = TaskSettings.ON_tarea__c;
       //=========================================================================================================
      //BLOQUEO DE CERRADAS GANADAS =====================================================================
       Trabajos_Programados__c TaskSettings2 = Trabajos_Programados__c.getAll().get('bloqueoCerradasganadas'); 
       this.emailCG 		= TaskSettings2.Notify__c;
       this.sendEmailCG	= TaskSettings2.Email_Notification__c;
       this.ON_Tarea_CG    = TaskSettings2.ON_tarea__c;
       //=========================================================================================================
      
      
      
       //AUDITORIA BLOQUEO DE OPORTUNIDADES DEVUELTAS 
       if(ON_Tarea_Devueltas == true)
       {
       	   list<Opportunity> oppcheck = [SELECT Id,Name,RecordType.DeveloperName,StageName,Unidad_de_Negocio__c 
                                    FROM Opportunity 
                                    WHERE (StageName = '07 Cerrada Devuelta Facturación'
                                                                          OR StageName = '08 Cerrada Devuelta Fulfillment') 
                                    AND RecordType.DeveloperName = 'Oportunidad_bloqueada'];   
            
		    if(oppcheck.size()>0)
		    {
		    
		    //Llamar a notificacion por email y enviar el error con la excepcion ocurrida
		     if(!Test.isRunningTest())
		       {
		          
		          for(Opportunity opp : oppcheck)
				    {
				       RecordType recordtypeOp = [SELECT Id,Name FROM RecordType where Name =: opp.Unidad_de_Negocio__c];
				       opp.RecordTypeId                                   = recordtypeOp.id;
				       system.debug('oportunidad a modificar  ' +opp  + ' recordtype '+ recordtypeOp.Name);
				       oppacorregir.put(opp.id,opp.Name);
				       
				    }
				 if(sendEmail)
				 {
				 	sndMail.sendMail(email, sndMail.getTemplateSubjectTask(), sndMail.getTemplateNotifitask('La auditoria automática encontró oportunidades devueltas con tipo de registro bloqueado  y fueron corregidas en las siguientes oportunidades: ' + oppacorregir));
				 }
				 update oppcheck;
		      }
		    }else
		    {
		      system.debug('**************No se encontraron registros******************');
		    }
       }
       //AUDITORIA BLOQUEO DE CERRADAS GANADAS
       if(ON_Tarea_CG == true)
       {
		 /*******************************************************************************************************************    
		    * JAAR 28-03-2014 Script que bloquea la oportunidad y sus relacionados sis esta cerrada ganada
		
		 *********************************************************************************************************************/
			
			RecordType recordtypeOp     = [SELECT Id,Name FROM RecordType where Name =: 'Oportunidad bloqueada'];
		    RecordType recordtypequote  = [SELECT Id,Name FROM RecordType where Name =: 'Presupuesto Bloqueado'];
			system.debug('recordtypeOp ===>> ' + recordtypeOp.Id);
			map<id,Dato_facturacion__c> mapdatoacambiar;
		    mapdatoacambiar = new map<id,Dato_facturacion__c>();
			
			list<Opportunity> oppblock = [SELECT Id,Name,RecordType.DeveloperName,StageName,(SELECT IsSyncing,Id,OpportunityId,RecordTypeId,blocked_quote__c  FROM Quotes WHERE IsSyncing = true ),(SELECT Dato_facturacion__c,Dato_facturacion__r.Blocked_BillingData__c,Dato_facturacion__r.Id ,Id FROM Facturas_por_oportunidad__r) FROM Opportunity WHERE RecordType.DeveloperName != 'Oportunidad_bloqueada' and StageName = '09 Cerrada ganada' limit 20];
			//se recorren las oportunidades y si se encuentran sin bloquear se procede a bloquearlas	
			if(oppblock.size()>0)
			{
			   for(Opportunity opp : oppblock)
		         {   
				     system.debug('oportunidad a modificar  ' +opp  );
					 opp.RecordTypeId     = recordtypeOp.id;
					 
					 
					 //bloqueo de cotizaciones==========================================================================
					 if(opp.Quotes.size() >0)
					 {
					    for (Integer i = 0; opp.Quotes.size()>i ; i++ )
							{
								if(opp.Quotes.get(i).RecordTypeId != recordtypequote.Id)
								opp.Quotes.get(i).RecordTypeId     = recordtypequote.Id;
								opp.Quotes.get(i).blocked_quote__c = true;
							}
					 }
					 //========================================================================================================
					 //bloqueo de dato de facturacion==========================================================================
					  if(opp.Facturas_por_oportunidad__r.size() >0)
					 {
					     for (Integer i = 0; opp.Facturas_por_oportunidad__r.size()>i ; i++ )
							{
							    if(opp.Facturas_por_oportunidad__r.get(i).Dato_facturacion__r.Blocked_BillingData__c ==false)
								{
								   system.debug('tiene datos de facturacion desbloqueados' + opp.Facturas_por_oportunidad__r.get(i).Dato_facturacion__r.Blocked_BillingData__c);
								   opp.Facturas_por_oportunidad__r.get(i).Dato_facturacion__r.Blocked_BillingData__c = true;
								   
								   mapdatoacambiar.put(opp.Facturas_por_oportunidad__r.get(i).Dato_facturacion__r.Id,opp.Facturas_por_oportunidad__r.get(i).Dato_facturacion__r);
								   system.debug('mapdatoacambiar===============>>>  ' +mapdatoacambiar);
								}else
								{
								   system.debug('NO tiene datos de facturacion desbloqueados ===>>> ' + opp.Facturas_por_oportunidad__r.get(i).Dato_facturacion__r.Blocked_BillingData__c);
								}
							}
					 }
				 
				 if(opp.Quotes.size() >0)
					 {
		                 update opp.Quotes;
					 }	
					 //modif datos
					 
					 list<Dato_facturacion__c>listaDatos = new 	list<Dato_facturacion__c>();
					 for (Dato_facturacion__c datoacambiar:mapdatoacambiar.values())
					 {
					   listaDatos.add(datoacambiar);
					   system.debug('lista de datos de facturacion a cambiar====' + listaDatos );
					 }
					 
					 if(listaDatos <> null)
					 { 
					    update listaDatos;
					 }
				  if(opp.Facturas_por_oportunidad__r.size() >0)
					 {
		                 update opp.Facturas_por_oportunidad__r;
					 }
				  if(sendEmailCG)
					 {
					 	sndMail.sendMail(email, sndMail.getTemplateSubjectTask(), sndMail.getTemplateNotifitask('La auditoria automática encontró oportunidades cerradas ganadas sin bloquear y fueron corregidas : ' + oppblock));
					 }
					update oppblock;
				 }
			}else
			{
			  
			}
	
       	
       	
       }
       
       
       
       
                          
    }
}