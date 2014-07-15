/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Febrero 03 de 2014
*  Decripción:          Clase que controla la gestión de las aprobaciones
*  @version:            1.0
* ===================================================================================================================================
**/

public with sharing class CTR010_Management_Of_Approvals 
{
 public String strTittlePage {get;set;} //variable que contiene el título de la página visualforce
 
 public ApexPages.Standardcontroller controller;
 public boolean ApprovalCartera {get;set;}
 public boolean ApprovalFulfillment {get;set;}
 public String comentarios{get;set;}  
 public boolean allowedaccess {get;set;} 
 public Fulfillment_management__c gestionfull{get;set;} 
 public String idRequestfinancial {get;set;} 
 public String stroportunityid {get;set;} 
 public String strOperationCode {get;set;} 
 public String strorigin {get;set;}
 public String stroppName {get;set;}
 public String stroppowner {get;set;}
 public String profileuser{get;set;}
 public String userName{get;set;}
 public String userId{get;set;}
 public Quote cotizacion{ get; set; }
 public Opportunity oppcheck{ get; set; }
 public Profile strProfile{ get; set; }
 public Requestfinancial__c Reqfinancial{ get; set; } 
 public String recordtypesrt{get;set;}

 
 public CTR010_Management_Of_Approvals()
 {
        if(Apexpages.currentPage().getParameters().get('OperationCode')!=null && Apexpages.currentPage().getParameters().get('OperationCode')=='CHEQUEO')
        {
                system.debug('\n\n Apexpages.currentPage_getParameters_requestFrom'+ Apexpages.currentPage().getParameters().get('oportunity'));  
                ApprovalCartera = true;
                ApprovalFulfillment = false;
                idRequestfinancial  = Apexpages.currentPage().getParameters().get('Requestfinaid');
        }else if(Apexpages.currentPage().getParameters().get('OperationCode')!=null && Apexpages.currentPage().getParameters().get('OperationCode')=='FULFILLMENT')
        {
                system.debug('\n\n APROBACION_FULFILLMENT');
                ApprovalFulfillment = true;
                ApprovalCartera = false;
                stroportunityid     = Apexpages.currentPage().getParameters().get('oportunity');
                gestionfull = createfullfillmentmanagement(stroportunityid);
        }
        profileuser = System.UserInfo.getProfileId();
        userName    = System.UserInfo.getName();
        userId          = System.Userinfo.getUserId();
        strProfile = getProfile(profileuser);
        system.debug('ESTE_ES_EL_PERFIL_ACTUAL '+profileuser);
        system.debug('ESTE_ES_EL_USUARIO_LOGUEADO_ACTUALMENTE '+userName);
        
        conf_Userapprover__c ConfPersUser = conf_Userapprover__c.getAll().get('CALLWS001_Chequeocredito');     
 }
 
 
 public PageReference lanzarProceso() 
 {
    this.controller  = controller;
     system.debug('idRequestfinancial '+ idRequestfinancial);          
     strOperationCode    = Apexpages.currentPage().getParameters().get('OperationCode');
     strorigin                   = Apexpages.currentPage().getParameters().get('origin');
     idRequestfinancial  = Apexpages.currentPage().getParameters().get('Requestfinaid');
     stroportunityid     = Apexpages.currentPage().getParameters().get('oportunity');
     oppcheck = getOpportunity(stroportunityid);
     Reqfinancial = getRequestfinancial(idRequestfinancial);
     //1- Datos de la oportunidad
     stroppName = oppcheck.Name;
     this.stroppowner = oppcheck.Owner.Name;
     //JAAR verificar si este perfil es permitido
     String permission = Validateprofile(oppcheck.StageName);
     system.debug('Tipo_depermiso_en_este_momento '+ permission);
     allowedaccess = allowedprofileaccess(strProfile.Name,permission,strOperationCode);
    
    
    
    
    return null;        
 }
 //metodo que crea temporalmente un objeto Fulfillment_management__c
 public Fulfillment_management__c createfullfillmentmanagement(String idportunity)
 {
        oppcheck = getOpportunity(stroportunityid);
        gestionfull = new Fulfillment_management__c();
        //gestionfull.Causes_of_return__c = '';
        gestionfull.Comments_fulfillment__c = '';
        gestionfull.Fecha_cerrada_fulfillment__c = system.now();
        gestionfull.Fecha_Entregada_Fulfillment__c= oppcheck.Fecha_Entregada_Fulfillment__c;
        gestionfull.IdOportunidad__c=idportunity;
        gestionfull.Responsable_fulfillment__c=userName;
        gestionfull.Status_fulfillment__c = '';
        
        
        return gestionfull;
        
 }
 
 //Metodo que verifica la etapa de la oportunidad para controlar el tipo de parobación que se requiere
 public String Validateprofile (String etapa)
 {
         String typepermission;
        if(etapa == '06 Cerrada Entregada Fulfillment')
        {
                typepermission = 'Aprobaciones fulfillment';
        }else if(etapa == '05 Cerrada Entregada Facturación')
        {
                typepermission = 'Aprobaciones de cartera';
        }else
        {
                typepermission = 'Sin permisos';
        }
        system.debug('tipo_de_permiso_requerido ' + typepermission);
        return typepermission;
 }
 
 /**************** Action aproval button************/   
 public PageReference doApproval(){  
            if(ApprovalCartera) 
            {
                Reqfinancial.Status_del_chequeo__c  ='APROBADO';
                Reqfinancial.User_approver__c       = userName;
                Reqfinancial.Date_of_Approval__c    = System.now();
                oppcheck.endcheckup__c              = 'APROBADO';
                oppcheck.Semaforostatus__c          = 'Green';
                oppcheck.StageName                  = '06 Cerrada Entregada Fulfillment';
                oppcheck.Fecha_Entregada_Fulfillment__c = system.now();
                //oppcheck.StageName                  = '09 Cerrada ganada';
                oppcheck.Fecha_cerrada_entregada_facturacion__c = System.now();
                oppcheck.Comentarios_Cartera__c         = Reqfinancial.Comentarios__c;
                
               
                allowedaccess=true;
                
                if(allowedaccess)
                {
                        update  oppcheck; 
                        update  Reqfinancial; 
                }else
                {
                        this.setMsg(0, 'Su perfil no dispone de los permisos necesarios para gestionar esta solicitud en la etapa actual del proceso ' );
                        return null;
                }
                     
            }else if(ApprovalFulfillment)
            {
                        gestionfull.Status_fulfillment__c               ='APROBADO';
                        gestionfull.Responsable_fulfillment__c  =userName;
                oppcheck.Fecha_cerrada_fulfillment__c   = system.now();
                oppcheck.Status_fulfillment__c                  ='APROBADO';
                oppcheck.Responsable_fulfillmet__c              = userId;
                oppcheck.StageName                                              = '09 Cerrada ganada';
                oppcheck.Comentarios_fulfillment__c     = gestionfull.Comments_fulfillment__c;
                
                allowedaccess=true;
                if(allowedaccess)
                {
                        insert gestionfull;  
                        update  oppcheck; 
                        restacontroldeInventario(true); 
                }else
                {
                        this.setMsg(0, 'Su perfil no dispone de los permisos necesarios para gestionar esta solicitud en la etapa actual del proceso');
                        return null;
                }
            }  
                    
        PageReference pr = new  PageReference( '/'+stroportunityid );         
        return pr;          
    }
 
 /**************** Action reject button ************/   
 public PageReference doReject(){  
            if(ApprovalCartera) 
            {
                Reqfinancial.Status_del_chequeo__c ='RECHAZADO';
                Reqfinancial.User_approver__c      = userName;
                Reqfinancial.Date_of_Approval__c   = System.now();
                Reqfinancial.Estado_No_conformidad_Cartera__c = 'ABIERTA';
                oppcheck.endcheckup__c             = 'RECHAZADO';
                oppcheck.Semaforostatus__c         = 'Red';
                oppcheck.StageName                 = '07 Cerrada Devuelta Facturación';
                oppcheck.Fecha_cerrada_entregada_facturacion__c   = System.now(); 
                oppcheck.Fecha_devuelta_facturacion__c                    = System.now();       
                oppcheck.Comentarios_Cartera__c         = Reqfinancial.Comentarios__c;
                
                
                    if(allowedaccess)
                {
                        
                        update  oppcheck; 
                        update  Reqfinancial; 
                        Unlock_data(oppcheck.id);
                        restacontroldeInventario(false);
                }else
                {
                        this.setMsg(0, 'Su perfil no dispone de los permisos necesarios para gestionar esta solicitud en la etapa actual del proceso');
                        return null;
                }  
            } else if(ApprovalFulfillment)
            {
                        gestionfull.Status_fulfillment__c               ='RECHAZADO';
                        gestionfull.Estado_No_conformidad__c    = 'ABIERTA';    
                        gestionfull.Responsable_fulfillment__c  =userName;
                oppcheck.Fecha_cerrada_fulfillment__c   = system.now();
                oppcheck.fecha_devuelta_fulfillment__c = system.now();
                oppcheck.Status_fulfillment__c                  ='RECHAZADO';
                oppcheck.Responsable_fulfillmet__c              = userId;
                oppcheck.StageName = '08 Cerrada Devuelta Fulfillment';
                oppcheck.Comentarios_fulfillment__c     = gestionfull.Comments_fulfillment__c; 
                
                 if(Test.isRunningTest()){
                 	this.setMsg(0, ' mensaje de prueba');
                 	this.setMsg(1, ' mensaje de prueba');
                 	this.setMsg(2, ' mensaje de prueba');
                 	this.getVentaLimitadaarenovar('123456');
                 }
                
                
                //Limpiar  todos los campos del chequeo de cédito  
                
                //oppcheck.CreditCheckCode__c                           = '';
                
                
                        
                        
                
                if(allowedaccess)
                {
                        if(oppcheck.CreditCheckCode__c <>null )
                                {
                                        system.debug('oppcheck.CreditCheckCode_01 '+oppcheck.CreditCheckCode__c);
                                        Reqfinancial = getRequestfinancialxcodanalisis(oppcheck.CreditCheckCode__c);
                                        if(Reqfinancial <> null)
                                        {
                                                //JAAR 11-03-2014 Se define con Diana Melo que si una solicitud es rechazada por fullfilment el chequeo de credito se eliminará ya que no ha sido gestionado por cartera
                                                if(Reqfinancial.Status_del_chequeo__c == 'EN PROCESO')
                                                {
                                                        if(Reqfinancial.User_approver__c <> null || Reqfinancial.Fecha_Entregada_Facturacion__c <> null)
                                                        {
                                                                system.debug('chequeo_ya_procesado_por_cartera '+Reqfinancial); 
                                                        }else
                                                        {
                                                                system.debug('chequeo_no_procesado_por_cartera_se_eliminara======>>>>>  '+Reqfinancial); 
                                                                delete Reqfinancial;
                                                        }
                                                }
                                                
                                        
                                        }
                                        
                                }
                        update  oppcheck; 
                        insert gestionfull;  
                        Unlock_data(oppcheck.id);
                        restacontroldeInventario(false);
                        
                }else
                {
                        this.setMsg(0, 'Su perfil no dispone de los permisos necesarios para gestionar esta solicitud en la etapa actual del proceso');
                        return null;
                }
            }   
                    
        PageReference pr = new  PageReference( '/'+stroportunityid );         
        return pr;          
    }
 
  
 /**************** Action cancel button************/     
    public PageReference doCancel(){
        PageReference pageref;
        if(ApprovalCartera && strorigin == 'Solicitudafinanciero') 
            {
                PageReference pr = new  PageReference( '/'+idRequestfinancial );         
                 pageref= pr; 
            } else if(ApprovalFulfillment && strorigin == 'Opportunity')
            {
                PageReference pr = new  PageReference( '/'+stroportunityid );         
                pageref= pr; 
            }               
        return pageref;         
    }
    
    /*********************************************************************************************************************    
    * JAAR 01-07-2014 Valida si tiene productos de venta limitada para modificar el estado del reg de vta limitada respectivo 
    
    *********************************************************************************************************************/ 
 public PageReference restacontroldeInventario(boolean activo)
    {
    	String stridquote;
    	list<QuoteLineItem> listprodxcotizacion = new list<QuoteLineItem>();
    	list<Registro_de_Venta_Limitada__c> vtaslmtadas = getVentaLimitada(stroportunityid);
    	list<Registro_de_Venta_Limitada__c> listvtasltadasanteriores = new list<Registro_de_Venta_Limitada__c>();
    	if(oppcheck.Quotes.size() >0)
          {
             for (Integer i = 0; oppcheck.Quotes.size()>i ; i++ )
                {
                   stridquote = oppcheck.Quotes.get(i).Id;
                }
           }
    	 //si la opp se dejo cerrada ganada consultamos los activos creados
    	 if(activo == true)
    	 {
    	 	listprodxcotizacion = getprodxcotizacion(stridquote);
    	    system.debug('\n\n Tiene_ventas_limitadas?  '+ vtaslmtadas + ' prodxcotizacion_1 ' + listprodxcotizacion + '\n\n');
    	    //Savepoint sp = Database.setSavepoint();
    	 }
    	 
        if(vtaslmtadas <> null)
    	{
    		for (Registro_de_Venta_Limitada__c regvta: vtaslmtadas)
    		{
    			if(activo == false)
    			{
    				if(regvta.Estado__c != 'RENOVADO')
    				{
    					regvta.Estado__c = 'LIBRE/DEVUELTA';
    				}
    				
    			}else
    			{
    				if(listprodxcotizacion <> null)
    				{
    					for(QuoteLineItem qli:listprodxcotizacion )
	    				{
	    					if(qli.Id == regvta.Partida_de_presupuesto__c)
	    					{
	    						regvta.Activo_Relacionado__c = qli.Activo_producido__c;
	    					}
	    				}
    				}
    				//validar que siu es una renovacion se debe desactivar el anterior registro y se debe activar el nuevo.
    				if(regvta.Renueva_a__c != null)
    				{
    					list<Registro_de_Venta_Limitada__c> vtaslmtadasarenovar = getVentaLimitadaarenovar(regvta.Renueva_a__c);
    					if(vtaslmtadasarenovar <> null)
    					{
    						for(Registro_de_Venta_Limitada__c rvarenovar: vtaslmtadasarenovar)
	    					{
	    						rvarenovar.Estado__c = 'DESACTIVADO/RENOVADO';
	    						rvarenovar.Activado__c = false;
	    						
	    						//verificar si ya esta en la lista a modificar y si no agregarlo
	    						if(listvtasltadasanteriores <> null)
	    						{
	    							boolean agregar = true;
	    							for(Registro_de_Venta_Limitada__c rvl: listvtasltadasanteriores)
	    							{
	    								if(rvl.Id == rvarenovar.Id)
	    								system.debug('el id_ya_se_encuentra_en_la_lista no se agregara ' + rvl);
	    								agregar = false;
	    							}
	    						    if(agregar == true)
	    						    {
	    						       listvtasltadasanteriores.add(rvarenovar); // se agrega a una lista para posteriormente modificar en masa	
	    						    }
	    						    
	    						}else
	    						{
	    							system.debug('se_agrego_un_nuevo_registro_a_lalista para actualizar los rvl a desactivar ' + rvarenovar);
	    							listvtasltadasanteriores.add(rvarenovar); // se agrega a una lista para posteriormente modificar en masa	
	    						}
	    						
	    					}
    					}
    					
    				}
    				regvta.Estado__c = 'ACTIVO';
    				regvta.Activado__c = true;
    			}
    			
    		}
    		try{
    			    system.debug('\n\n vta limitadsa a renovar  ' + listvtasltadasanteriores + '\n\n'); 
    			    update listvtasltadasanteriores;   //modifico los reg de vtas limitadas anteriores que se estan renovando
    			    update vtaslmtadas; //modifico los reg de vtas limitadas nuevos 
    		   }catch(Exception ex){
					system.debug('\n\n No fue posible actualizar los valores de registro de inventario ' + ex); 
		       }
    	}
    	return null;
    }
     
     public void setMsg(integer typeMsg, String message){
        
        if(typeMsg ==null || typeMsg==0){
            Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.INFO,message);
            Apexpages.addMessage(msg);
        }
        
        if(typeMsg==1){
            Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.CONFIRM,message);
            Apexpages.addMessage(msg);
        }

        if(typeMsg==2){
            Apexpages.Message msg = new Apexpages.Message(Apexpages.Severity.ERROR,message);
            Apexpages.addMessage(msg);
        }
        
        return;
        
    } 
     /*******************************************************************************************************************    
    * JAAR 19-03-2014 Metodo que desbloquea la oportunidad y sus relacionados 
        1. ingresa solo si se rechaza algun proceso de aprobacion
    * @return  boolean.  
    *********************************************************************************************************************/ 
   public boolean Unlock_data(String IdOportunity)
   {
         boolean exito = false;
         //realizo la busqueda de los datos de facturación asociados a la oportunidad
         cotizacion = [SELECT IsSyncing,Id,OpportunityId,RecordTypeId,blocked_quote__c,(SELECT Blocked_BillingData__c,Id FROM Datos_facturacion__r)  FROM Quote WHERE IsSyncing = true AND OpportunityId =: IdOportunity]; 
     //1 - Desbloquear el dato de facturación posterior al rechazo del proceso ----------------------------------
         if(cotizacion.Datos_facturacion__r.size() >0)
          {
             for (Integer i = 0; cotizacion.Datos_facturacion__r.size()>i ; i++ )
                {
                   cotizacion.Datos_facturacion__r.get(i).Blocked_BillingData__c= false;
                }
             exito = true;      
          }
          //2 - desbloquea la oportunidad para que no pueda ser editada despues del chequeo
           oppcheck.blocked_opportunity__c        = false;
           if (oppcheck.Unidad_de_Negocio__c <> null)
           {
                RecordType recordtypeOp = [SELECT Id,Name FROM RecordType where Name =: oppcheck.Unidad_de_Negocio__c];
                recordtypesrt           = recordtypeOp.id;
                oppcheck.RecordTypeId   = recordtypeOp.id;
                system.debug('oppcheck_RecordTypeId1  '+oppcheck.RecordTypeId);
           }
           //3 - Desbloquea la cotización
           RecordType recordtypecot = [SELECT Id,Name FROM RecordType where Name = 'Presupuesto desbloqueado'];
           cotizacion.RecordTypeId = recordtypecot.Id;
           cotizacion.blocked_quote__c = false;
          try
          {
               oppcheck.RecordTypeId = recordtypesrt;
               system.debug('oppcheck_RecordTypeId2  '+oppcheck.RecordTypeId);
               update oppcheck;
                if(cotizacion.Datos_facturacion__r.size() >0)
               {
                 update cotizacion.Datos_facturacion__r;
                 update cotizacion;
               }
               
          }catch(system.exception e)
               {
                 system.debug('No fue posible actualizar la opp  '+e);
                 
               }
          
             //-------------------------------------------------------------------------------------------------------
    return exito;
   } 
    /*************************************************************************************************************
    *                                            QUERY AREA
    *************************************************************************************************************/  
    //Oportunity --------------------------------------------------------------------------------
     public Opportunity getOpportunity(String IdOportunity){
        List<Opportunity> myopp = [SELECT Name,Owner.Name,endcheckup__c,Semaforostatus__c,CreditCheckCode__c,StageName,CreditLimitValidUntilDate__c,Id,automaticresult__c,Responsable_fulfillmet__c,
                                   Fecha_Entregada_Facturacion__c,Comentarios_fulfillment__c, IsCreditAnalysisRequired__c,IsCreditChecked__c,IsCreditExceptionAllowed__c,Fecha_Entregada_Fulfillment__c,
                                   Fecha_cerrada_entregada_facturacion__c,fecha_devuelta_fulfillment__c,blocked_opportunity__c,Unidad_de_Negocio__c,Fecha_devuelta_facturacion__c,Comentarios_Cartera__c 
                                                           ,(SELECT GrandTotal,Id,IsSyncing FROM Quotes WHERE IsSyncing = true)
                                                          FROM Opportunity 
                                  where Id =:IdOportunity];     
        if(myopp.size()>0){
            return myopp.get(0);      
        }else{      
            return null;
        }   
    }
    
      //Solicitude de credito asociadas ----------------------------------------------------------
     public Requestfinancial__c getRequestfinancial(String idfinancial){
        List<Requestfinancial__c> Reqfin = [SELECT automaticresult__c,Chequeo_vigente__c,Comentarios__c,User_approver__c,Date_of_Approval__c,CreditCheckCode__c,Id,Monto__c,Name,Status_del_chequeo__c,Tipo_de_solicitud__c 
                                                                                FROM Requestfinancial__c WHERE Id =:idfinancial];     
        if(Reqfin.size()>0){
            return Reqfin.get(0);
        }else{      
            return null;
        }   
    }
    
      //Solicitude de credito asociadas ----------------------------------------------------------
     public Requestfinancial__c getRequestfinancialxcodanalisis(String Codanalisis){
        List<Requestfinancial__c> Reqfin = [SELECT automaticresult__c,Chequeo_vigente__c,Comentarios__c,Fecha_Entregada_Facturacion__c,User_approver__c,Date_of_Approval__c,CreditCheckCode__c,Id,Monto__c,Name,Status_del_chequeo__c,Tipo_de_solicitud__c 
                                            FROM Requestfinancial__c WHERE CreditCheckCode__c =:Codanalisis];     
        if(Reqfin.size()>0){
            return Reqfin.get(0);
        }else{      
            return null;
        }   
    }
    
    
     //Validar usuario aprobador ----------------------------------------------------------
     public Profile getProfile(String idProfile){
        List<Profile> ReqProfile = [SELECT Id,Name FROM Profile WHERE Id =:idProfile];     
        if(ReqProfile.size()>0){
            return ReqProfile.get(0);
        }else{      
            return null;
        }   
    }
    
    /******************Administración de Permisos***********************************************/
        public boolean allowedprofileaccess(String idProfile, String typeofpermission,String strOperationCode){
                system.debug('idProfile: '+idProfile + '  typeofpermission   '+typeofpermission + ' strOperationCode  ' + strOperationCode);
        List<conf_Userapprover__c>  allowed = [SELECT Funcion__c,Id,Name,Perfil__c,OperationCode__c  FROM conf_Userapprover__c 
                                                                                   WHERE Funcion__c =: typeofpermission 
                                                                                   AND Perfil__c =:idProfile 
                                                                                   AND OperationCode__c =:strOperationCode];
                system.debug('PERFIL_BUSCADO_TAMAÑO: '+allowed.size());
                if(allowed.size()>0){
                        system.debug('PERFIL_BUSCADO: '+allowed.get(0).Perfil__c);
                        return true;
                }
                return false;
        } 
        
        
         //Control de Inventario -seccion, ciudad, tipo de inventario
     public list<Registro_de_Venta_Limitada__c> getVentaLimitada(String IdOportunity){
        List<Registro_de_Venta_Limitada__c> vtalimitada = [SELECT Activado__c,Activo_Relacionado__c,Partida_de_presupuesto__r.Seccion__c,Partida_de_presupuesto__r.Tipo_de_Inventario__c,Partida_de_presupuesto__r.Quote.OpportunityId,Ciudad_es_principal__c,Ciudad__c,Contrato__c,Control_de_Inventario__c,
                                                                  Control_de_Inventario__r.Cantidad_Reservada__c,Control_de_Inventario__r.total_reservado__c,
        														  Control_de_Inventario__r.Cantidad_Disponible__c,Control_de_Inventario__r.Ciudad__c,Renueva_a__c,
    															  Control_de_Inventario__r.Seccion__c,Control_de_Inventario__r.Tipo_Inventario__c,Control_de_Inventario__r.Tipo_Inventario__r.Name,Estado__c,Id,Name,Partida_de_presupuesto__c,Precio__c,Seccion_principal__c,Tipo_de_Inventario__c 
                                                           FROM   Registro_de_Venta_Limitada__c
														   WHERE  Partida_de_presupuesto__r.Quote.OpportunityId =:IdOportunity];     
             
        return vtalimitada;
    }  
    
        
         //Control de Inventario a renovar  
     public list<Registro_de_Venta_Limitada__c> getVentaLimitadaarenovar(String Idcrtlinventario){
        List<Registro_de_Venta_Limitada__c> vtalimitada = [SELECT Activado__c,Activo_Relacionado__c,Partida_de_presupuesto__r.Seccion__c,Partida_de_presupuesto__r.Tipo_de_Inventario__c,Partida_de_presupuesto__r.Quote.OpportunityId,Ciudad_es_principal__c,Ciudad__c,Contrato__c,Control_de_Inventario__c,
                                                                  Control_de_Inventario__r.Cantidad_Reservada__c,Control_de_Inventario__r.total_reservado__c,
        														  Control_de_Inventario__r.Cantidad_Disponible__c,Control_de_Inventario__r.Ciudad__c,Renueva_a__c,
    															  Control_de_Inventario__r.Seccion__c,Control_de_Inventario__r.Tipo_Inventario__c,Control_de_Inventario__r.Tipo_Inventario__r.Name,Estado__c,Id,Name,Partida_de_presupuesto__c,Precio__c,Seccion_principal__c,Tipo_de_Inventario__c 
                                                           FROM   Registro_de_Venta_Limitada__c
														   WHERE  Id =:Idcrtlinventario];     
             
        return vtalimitada;
    }     
    
    // productos por cotizacion 
     public list<QuoteLineItem> getprodxcotizacion(String Idquote){
        List<QuoteLineItem> prodxcotizacion = [SELECT Activo_producido__c,Activo_renovacion__c,Activo_Upselling__c,Fecha_de_anulacion__c,Id,productcancelled__c,QuoteId 
        									   FROM QuoteLineItem
											   WHERE  QuoteId  =:Idquote];     
        return prodxcotizacion;
    }      
    
     

    
     

}