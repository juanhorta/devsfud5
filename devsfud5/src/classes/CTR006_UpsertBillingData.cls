/*
*   Controller for opportunity s3 file 
*   Version 1.0		15-01-2013 - Jairo Guzman - control new file creation into amazon S3 from opportunity 
*   Version 1.1 	17-02-2015 - JAAR           Se modificacion en el dato de facturación para que soporte diferentes tipos de facturación 
*   											por vigencias, por cuotas iguales y por cuotas especiales
*   Version 2.0	    02-04-2014 -  JAAR          Llamado al servicio de consulta de cliente unico a masterdata antes de guardar el dato de facturación
*   Version 2.0.1	11-04-2014 -  JAAR          Se incorpora la creación de tareas que se generan si la respuesta del llamado al servicio evidencia que no existe el cliente en masterdata 
*   Version 2.1.2   23-04-2014 -  JAAR 			Se agrega funcionalidad para que al crear dato de facturación se tome la informacion inicial de la identificación de la misma manera que al cambiar 
												la identificación en el dato el busque y complete la información faltante si es null excepto el cod unico que se modifica siempre que e modifique la identificación
*   Version 2.1.3   14-05-2014 -  JAAR 			Se agrega logica para realizar la validacion donde si un asesor modifica los datos de facturacion (direccion, telefono, ciudad )se envie tarea a rafael indicando que cambio la info con uso de facturacion
*   Version 2.1.3   21-05-2014 -  JAAR          Se agrega validación para asegurar que si se factura por codensa el nie diligenciado es valido para facturar
*/

public class CTR006_UpsertBillingData {
    
    /*Context properties*/
    
    private Dato_facturacion__c oCurrentBillingInfo; 
    public List<QuoteLineItem> loadnumcuotas;
    public boolean rendervigencias{get;set;}
        public boolean rendercuotas{get;set;}
        public boolean rendercespeciales{get;set;}
        public boolean rendervalores{get;set;}
        public boolean renderNie{get;set;}
        public boolean requiredNie{get;set;}
        public boolean requiredvigencias{get;set;}
        public boolean requiredcuotas{get;set;} 
        public Decimal numcuotprod{get;set;} 
        public boolean datofactok{get;set;}
        public boolean autocomplete{get;set;}
        public list<Account> myAccount{get;set;}
        public list<Account> OtheAccount{get;set;}
        public Identificaciones__c ident{get;set;}
        public String ErrorMessage{
	        get{
	                if(ErrorMessage==null || ErrorMessage=='')
	                        return '';
	                else
	                        return ErrorMessage;
	        }set;
	    }
    public Dato_facturacion__c CurrentBillingInfo{ 
        get {
            if(oCurrentBillingInfo == null){
                oCurrentBillingInfo = (Dato_facturacion__c)CtxController.getRecord();
            }
            return oCurrentBillingInfo;
        }
        set{
            oCurrentBillingInfo = value;
        }
    }

    private Quote oRelatedQuoteInfo;
    public Quote RelatedQuoteInfo{
        get{
            if(oRelatedQuoteInfo == null){
                //get related account info
                oRelatedQuoteInfo =
                    [select TotalPrice
                            ,Name
                            ,Opportunity.Account.Name
                            ,Opportunity.Account.Tipo_identificacion__c
                            ,Opportunity.Account.Codigo_cliente_unico__c
                            ,Opportunity.Account.Numero_identificacion__c
                            ,Opportunity.Account.Ciudad_facturacion__c
                            ,Opportunity.Account.Direccion_facturacion__c
                            ,Opportunity.Account.Telefono_facturacion__c
                            ,Opportunity.Account.Email_corporativo__c
                            ,Opportunity.Account.Identificacion__c
                    from    Quote
                    where   id =: CurrentBillingInfo.Presupuesto__c][0];
            }
            return oRelatedQuoteInfo; 
        }
        set{oRelatedQuoteInfo = value;}
    }
     
    private decimal oMaxBillingValue;
    public decimal MaxBillingValue{
        get{
            if(oMaxBillingValue == null){
            
                AggregateResult TotalBilling = null;
                
                if(CurrentBillingInfo.Id != null){
                    TotalBilling = 
                        [select sum(Valor_facturacion__c)Valor_facturacion__c
                        from    Dato_facturacion__c
                        where   Presupuesto__c =: CurrentBillingInfo.Presupuesto__c
                                and id !=: CurrentBillingInfo.id][0];
                }
                else{
                    TotalBilling = 
                        [select sum(Valor_facturacion__c)Valor_facturacion__c
                        from    Dato_facturacion__c
                        where   Presupuesto__c =: CurrentBillingInfo.Presupuesto__c][0];
                }
                
                
                if(TotalBilling != null && TotalBilling.get('Valor_facturacion__c') == null){
                    oMaxBillingValue = RelatedQuoteInfo.TotalPrice;
                }
                else if(TotalBilling != null && RelatedQuoteInfo.TotalPrice > (decimal)TotalBilling.get('Valor_facturacion__c')){
                    oMaxBillingValue = RelatedQuoteInfo.TotalPrice - (decimal)TotalBilling.get('Valor_facturacion__c');
                }           
            }
            return oMaxBillingValue;
        }
        set{oMaxBillingValue = value;}
    }   
    
    
    public string DisplayQuote{
        get{
            if(CurrentBillingInfo.Id != null){
                return '';
            } 
            else{
                return 'none';
            }
        }
    }
    
    ApexPages.StandardController CtxController;
    public CTR006_UpsertBillingData(ApexPages.StandardController stdController) {
        CtxController = stdController;
        autocomplete = false; // JAAR 23-04-2014 check que permite autocompletar a partir de la identificación.
        oCurrentBillingInfo = (Dato_facturacion__c)CtxController.getRecord();
        if(oCurrentBillingInfo.id == null)
        {
            rendervalores = true;
	        requiredcuotas = true;
	        rendercuotas = true;
	        oCurrentBillingInfo.billing_type__c = 'Facturación por cuotas iguales';
	        oCurrentBillingInfo.Numero_cuotas__c = 1;
	        oCurrentBillingInfo.Cuota_normalizada__c = true;
	        requiredNie = false; 
        }else
        {
	        if(oCurrentBillingInfo.billing_type__c == 'Facturación por cuotas iguales')
	        {
	        	rendervalores = true;
	        	requiredcuotas = true;
	        	rendercuotas = true;
	        }else if(oCurrentBillingInfo.billing_type__c == 'Facturación Especial')
	        {
	        	requiredcuotas = true;
	        	rendercuotas = true;
	        	rendercespeciales = true;
	        	oCurrentBillingInfo.Cuota_normalizada__c = false;
	        }else
	        {
	        	requiredvigencias = true;
	        	rendervigencias = true;
	        	
	        }
	        if(oCurrentBillingInfo.Agente_recaudo__c == 'CODENSA')
	        {
	        	requiredNie = true; 
	        	renderNie = true;
	        	
	        }else
	        {
	        	requiredNie = false; 
	        	renderNie = false;
	        }
        }    
    }
    
    /*load page*/
    public pageReference LoadPage() {
        
        try{
            if(CurrentBillingInfo.Id == null){
            	
            	//23-04-2014 -  JAAR 	Se agrega funcionalidad para que al crear dato de facturación se tome la informacion inicial de la identificación
                ident = getIdentificacionesByaccount(RelatedQuoteInfo.Opportunity.Account.Identificacion__c);
                system.debug('identificacion_relacionada  ' + ident);
                if(ident <> null)
                {
                	CurrentBillingInfo.Tipo_identificacion__c = ident.Tipo_identificacion__c ;
	                CurrentBillingInfo.Numero_identificacion__c = ident.Numero_identificacion__c;
	                CurrentBillingInfo.Direccion_facturacion__c = ident.Direccion_facturacion__c;
	                CurrentBillingInfo.Telefono_contacto_financiero__c = ident.Telefono_facturacion__c;
	                CurrentBillingInfo.Codigo_Cliente_Unico__c  = ident.Cliente_unico__c;
	                if(ident.Ciudad_facturacion__c <> null)
	                {
	                   	CurrentBillingInfo.Ciudad_facturacion__c = ident.Ciudad_facturacion__c;
        				CurrentBillingInfo.Ciudad_telefono_facturacion__c = ident.Ciudad_facturacion__c;	
	                }else
	                {
	                	CurrentBillingInfo.Ciudad_facturacion__c = RelatedQuoteInfo.Opportunity.Account.Ciudad_facturacion__c;
	            		CurrentBillingInfo.Ciudad_telefono_facturacion__c = RelatedQuoteInfo.Opportunity.Account.Ciudad_facturacion__c;
	                }
	                if(ident.Email_Facturacion__c <> null)
	                {
	                	CurrentBillingInfo.Correo_facturacion__c = ident.Email_Facturacion__c;
	                }else
	                {
	                	CurrentBillingInfo.Correo_facturacion__c = RelatedQuoteInfo.Opportunity.Account.Email_corporativo__c;
	                }
	                
                }else
                {
                	CurrentBillingInfo.Tipo_identificacion__c = RelatedQuoteInfo.Opportunity.Account.Tipo_identificacion__c;
	                CurrentBillingInfo.Numero_identificacion__c = RelatedQuoteInfo.Opportunity.Account.Numero_identificacion__c;
	                CurrentBillingInfo.Direccion_facturacion__c = RelatedQuoteInfo.Opportunity.Account.Direccion_facturacion__c;
	                CurrentBillingInfo.Telefono_contacto_financiero__c = RelatedQuoteInfo.Opportunity.Account.Telefono_facturacion__c;
	                CurrentBillingInfo.Correo_facturacion__c = RelatedQuoteInfo.Opportunity.Account.Email_corporativo__c;
	                CurrentBillingInfo.Ciudad_facturacion__c = RelatedQuoteInfo.Opportunity.Account.Ciudad_facturacion__c;
	            	CurrentBillingInfo.Ciudad_telefono_facturacion__c = RelatedQuoteInfo.Opportunity.Account.Ciudad_facturacion__c;
	            	CurrentBillingInfo.Codigo_Cliente_Unico__c  = RelatedQuoteInfo.Opportunity.Account.Codigo_cliente_unico__c;
                }
                //valores fijos en el dato de facturación
                CurrentBillingInfo.Razon_social__c = RelatedQuoteInfo.Opportunity.Account.Name;
                CurrentBillingInfo.Valor_facturacion__c = MaxBillingValue;
	            CurrentBillingInfo.Name = RelatedQuoteInfo.Name + ' ' + String.valueOf(system.today());
	            CurrentBillingInfo.Fecha_primera_cuota__c  = Date.valueof(system.now().addDays(1));
            }
        }catch(Exception er){
             
             ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, er.getMessage());
             ApexPages.addMessage(errorMsg);
             this.ErrorMessage=er.getMessage();
        }
        return null;
    }   
    /****************************************METODO QUE AUTOCOMPLETA LA INFO DEL DATO  ********************************************************
	JAAR 23-04-2014 
	1- Autocompleta la información del dato de facturación a partir de la identificación marcando el check de autocompletar
	**********************************************************************************************************************************/ 
    
    public PageReference autocompleteinf()
    {
     if(autocomplete == true)
      {
      	  system.debug('entro_autocompleteinf');
      	  if(CurrentBillingInfo.Numero_identificacion__c <> null && CurrentBillingInfo.Tipo_identificacion__c <> null )
    	{
	       Identificaciones__c identnumber =  getIdentificacionesBynumber(CurrentBillingInfo.Numero_identificacion__c,CurrentBillingInfo.Tipo_identificacion__c);
     	   system.debug('identificacion_relacionada_autocomplete al guardar  con el num ' + CurrentBillingInfo.Numero_identificacion__c + 'y el CurrentBillingInfo.Tipo_identificacion__c ' +CurrentBillingInfo.Tipo_identificacion__c + '  igual a: ' + identnumber);
		   if(identnumber <> null)
            {
            	
            	CurrentBillingInfo.Tipo_identificacion__c = identnumber.Tipo_identificacion__c ;
                CurrentBillingInfo.Numero_identificacion__c = identnumber.Numero_identificacion__c;
                CurrentBillingInfo.Direccion_facturacion__c = identnumber.Direccion_facturacion__c;
                CurrentBillingInfo.Telefono_contacto_financiero__c = identnumber.Telefono_facturacion__c;
                CurrentBillingInfo.Codigo_Cliente_Unico__c  = identnumber.Cliente_unico__c;
                Account accname =  getAccountByIdident(identnumber.id);
                if(accname <> null)
                {
                	CurrentBillingInfo.Razon_social__c = accname.Name;
                }else
                {
                	CurrentBillingInfo.Razon_social__c = '';
                }
                
                CurrentBillingInfo.Ciudad_facturacion__c = identnumber.Ciudad_facturacion__c;
    			CurrentBillingInfo.Ciudad_telefono_facturacion__c = identnumber.Ciudad_facturacion__c;	
               
                if(identnumber.Email_Facturacion__c <> null)
                {
                	CurrentBillingInfo.Correo_facturacion__c = identnumber.Email_Facturacion__c;
                }else
                {
                	CurrentBillingInfo.Correo_facturacion__c = '';
                }
                
            }else
            {
            	system.debug('no_se_encontraron_datos_en_identificaciones');
            	CurrentBillingInfo.Direccion_facturacion__c = '';
                CurrentBillingInfo.Telefono_contacto_financiero__c = '';
                CurrentBillingInfo.Codigo_Cliente_Unico__c  = null;
                CurrentBillingInfo.Razon_social__c = null;
                CurrentBillingInfo.Ciudad_facturacion__c = null;
    			CurrentBillingInfo.Ciudad_telefono_facturacion__c = null;	
                CurrentBillingInfo.Correo_facturacion__c ='';
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO,  + 'Para autocompletar debe diligenciar por lo menos la identificación y el tipo de identificación ');
                ApexPages.addMessage(errorMsg);
                this.ErrorMessage ='Para autocompletar debe diligenciar por lo menos la identificación y el tipo de identificación ';
                return null;
                
            }
    	}else
    	{
    		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO,  + 'Para autocompletar debe diligenciar por lo menos la identificación y el tipo de identificación ');
            ApexPages.addMessage(errorMsg);
            this.ErrorMessage ='Para autocompletar debe diligenciar por lo menos la identificación y el tipo de identificación ';
            return null;
    	}
      }
    	
    	
    	
    	
    	return null;
    }
    
    /*modify billing info*/
    public pageReference UpsertBillingInfo() {

        try{
        	datofactok = false;
        	if(autocomplete == false)
        	{
        		   //JAAR - 23-04-2014 Se agrega validación para que siempre se valide antes de guradar que el CU sea el correspondiente con la identificación
        		   Identificaciones__c identnumber =  getIdentificacionesBynumber(CurrentBillingInfo.Numero_identificacion__c,CurrentBillingInfo.Tipo_identificacion__c);
		     	   system.debug('Identificacion_relacionada_autocomplete_igual_a_false ' + CurrentBillingInfo.Numero_identificacion__c + 'y el CurrentBillingInfo.Tipo_identificacion__c ' +CurrentBillingInfo.Tipo_identificacion__c + '  igual a: ' + identnumber);
				   if(identnumber <> null)
		            { 
		            	CurrentBillingInfo.Codigo_Cliente_Unico__c  = identnumber.Cliente_unico__c;
		            }else
		            {
		            	CurrentBillingInfo.Codigo_Cliente_Unico__c = null;
		            }
		    }
        	//JAAR 21-05-2014  Se agrega validación para asegurar que el nie solicitado es valido si se factura por codensa
        	if(CurrentBillingInfo.Agente_recaudo__c == 'CODENSA' && CurrentBillingInfo.NIE__c != null)
        	{
        		if(!validaNie(String.valueof(CurrentBillingInfo.NIE__c)))
		        {
		         ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'No fue posible guardar el dato de facturación, El NIE Diligenciado no es válido ');
	             ApexPages.addMessage(errorMsg);
	             this.ErrorMessage = 'No fue posible guardar el dato de facturación, El NIE Diligenciado no es válido';
	             datofactok = false;
	             return null;
		        }
        	} 
        	
        	if(!Completdata())
	        {
	        	system.debug('\n\n no_supero_la_validacion_de_datos');
	        	
	        	 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'No fue posible guardar el dato de facturación la información está incompleta ');
	             ApexPages.addMessage(errorMsg);
	             this.ErrorMessage = 'No fue posible guardar el dato de facturación la información está incompleta ';
	             datofactok = false;
	             return null;
	        	
	       } 
        	
            //JAAR - 17-02-2015 -------------FACTURACION POR CUOTAS IGUALES O ESPECIAL --------------------------------------------------------
         if(CurrentBillingInfo.billing_type__c == 'Facturación por cuotas iguales'||CurrentBillingInfo.billing_type__c =='Facturación Especial')
         {
            if(CurrentBillingInfo.Numero_cuotas__c > 0){

                //JAAR 17-02-2015 Verificar que ninguno de los productos de la cotización tengan el campo Numero_cuotas_maximo__c null o en cero antes de iniciar el proceso.
                   loadnumcuotas = [SELECT Id,QuoteId,PricebookEntry.Product2.Numero_cuotas_maximo__c ,PricebookEntry.Product2.Name FROM QuoteLineItem WHERE QuoteId =: CurrentBillingInfo.Presupuesto__c];
                   if(loadnumcuotas.size()<1)
                   {
                   	  ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Antes de crear el dato de facturación verifique que su cotización tenga al menos un producto: ');
                                            ApexPages.addMessage(errorMsg);
                                            this.ErrorMessage='Antes de crear el dato de facturación verifique que su cotización tenga al menos un producto: ';
                                            return null;
                   }
                   for(QuoteLineItem qli: loadnumcuotas)
                   {
                        if(qli.PricebookEntry.Product2.Numero_cuotas_maximo__c <> null)
                        {
                                if(qli.PricebookEntry.Product2.Numero_cuotas_maximo__c < 1)
                                {
                                        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'El número de cuotas maximo configurado en el producto: ' + qli.PricebookEntry.Product2.Name + ' debe ser mayor a cero (0).');
                                            ApexPages.addMessage(errorMsg);
                                             this.ErrorMessage='El número de cuotas maximo configurado en el producto: ' + qli.PricebookEntry.Product2.Name + ' debe ser mayor a cero (0).';
                                            return null;
                                }
                        }else
                        {
                                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'El número de cuotas maximo configurado en el producto: ' + qli.PricebookEntry.Product2.Name + ' debe tener valor numerico');
                                        ApexPages.addMessage(errorMsg);
                                        this.ErrorMessage='El número de cuotas maximo configurado en el producto: ' + qli.PricebookEntry.Product2.Name + ' debe tener valor numerico';
                                        system.debug('Este_es_mi_ErrorMessage' + ErrorMessage);
                                        return null;
                        }
                   }
                
                //JAAR 14-05-2014 Se agrega logica para realizar la validacion donde si un asesor modifica los datos de facturacion (direccion, telefono, email )se envie tarea a gestion de datos indicando que cambio la info con uso de facturacion
                if(CurrentBillingInfo.Id == null){
                	system.debug('\n\n mi_identificacion_1===============>>>>>>  '+ident);
                }else
                {
                	
                	ident =  getIdentificacionesBynumber(CurrentBillingInfo.Numero_identificacion__c, CurrentBillingInfo.Tipo_identificacion__c);
                	
                	//getIdentificacionesByaccount(RelatedQuoteInfo.Opportunity.Account.Identificacion__c);
                	system.debug('\n\n mi_identificacion_2===============>>>>>>  '+ident);
                }
                //si encontro alguna identificacion de masterdata relacionada
                if(ident <> null)
                {
                	system.debug('Requiere_Masterdata_al_inicio  '+ ident.Direccion_facturacion__c + 'tel ' + ident.Telefono_facturacion__c + 'ciudad  '+ ident.Ciudad_facturacion__c);
                	system.debug('Requiere_Masterdata_al_inicio  '+ CurrentBillingInfo.Requiere_Masterdata__c);
                	if((ident.Direccion_facturacion__c == null || ident.Direccion_facturacion__c == '' || ident.Direccion_facturacion__c == '0')&& (ident.Telefono_facturacion__c == null || ident.Telefono_facturacion__c == '' || ident.Telefono_facturacion__c == '0')&& ident.Ciudad_facturacion__c == null)
                	{
                		system.debug('MD_NO_devolvio_informacion_en_tel_dir_y_ciudad');
                		CurrentBillingInfo.Requiere_Masterdata__c = true;
                		CurrentBillingInfo.Tipo_de_solicitud_Masterdata__c = 'SIN USO DE FACTURACIÓN EN MASTERDATA';
                	}else if(ident.Direccion_facturacion__c == null || ident.Direccion_facturacion__c == '' || ident.Direccion_facturacion__c == '0')
                	{
                		CurrentBillingInfo.Requiere_Masterdata__c = true;
                		CurrentBillingInfo.Tipo_de_solicitud_Masterdata__c = 'SIN DIRECCIÓN EN MASTERDATA';
                	}else if(ident.Telefono_facturacion__c == null || ident.Telefono_facturacion__c == '' || ident.Telefono_facturacion__c == '0')
                	{
                		CurrentBillingInfo.Requiere_Masterdata__c = true;
                		CurrentBillingInfo.Tipo_de_solicitud_Masterdata__c = 'SIN TELÉFONO EN MASTERDATA';
                	}else if(ident.Ciudad_facturacion__c == null)
                	{
                		CurrentBillingInfo.Requiere_Masterdata__c = true;
                		CurrentBillingInfo.Tipo_de_solicitud_Masterdata__c = 'SIN CIUDAD EN MASTERDATA';
                	}else 
                	{
                		//si llega a este punto la identificación llego bien desde masterdata ahora se valida si fue cambiada desde el dato de facturación
                		if(CurrentBillingInfo.Tipo_identificacion__c != ident.Tipo_identificacion__c || CurrentBillingInfo.Numero_identificacion__c != ident.Numero_identificacion__c)
	                    {
	                    	system.debug('\n\n cambio_tipo_id ');
	                    	CurrentBillingInfo.Requiere_Masterdata__c = true;
	                    	CurrentBillingInfo.Tipo_de_solicitud_Masterdata__c = 'CREACIÓN DE TERCERO';
	                    }else if(CurrentBillingInfo.Direccion_facturacion__c != ident.Direccion_facturacion__c )
	                    {
	                    	system.debug('\n\n cambio_Direccion_facturacion__c ');
	                    	CurrentBillingInfo.Requiere_Masterdata__c = true;
	                    	CurrentBillingInfo.Tipo_de_solicitud_Masterdata__c = 'MODIFICACIÓN DE DIRECCIÓN';
	                    }else if(CurrentBillingInfo.Telefono_contacto_financiero__c != ident.Telefono_facturacion__c)
	                    {
	                    	system.debug('\n\n cambio_Telefono_facturacion__c ');
	                    	CurrentBillingInfo.Requiere_Masterdata__c = true;
	                    	CurrentBillingInfo.Tipo_de_solicitud_Masterdata__c = 'MODIFICACIÓN DE TELÉFONO';
	                    }else if(ident.Ciudad_facturacion__c <> null)
	                    {
	                    	
	                    		if(CurrentBillingInfo.Ciudad_facturacion__c != ident.Ciudad_facturacion__c)
	                    		{
	                    			CurrentBillingInfo.Requiere_Masterdata__c = true;
	                    			CurrentBillingInfo.Tipo_de_solicitud_Masterdata__c = 'MODIFICACIÓN DE CIUDAD';
	                    			system.debug('\n\n cambio_Ciudad_facturacion__c ');
	                    		}else
	                    		{
	                    			
	                    		}system.debug('Ciudad_no_cambio');
	                    	
	                    }  
                		
                		
                	}
                	//se valida si ya el dato de facturacion tiene una tarea en curso para no crearle mas 
                	if(CurrentBillingInfo.Id != null){
                	 	Dato_facturacion__c midato = [SELECT Id,Requiere_Masterdata__c,Status_Masterdata__c,Tipo_de_solicitud_Masterdata__c FROM Dato_facturacion__c
                	                                  WHERE Id =: CurrentBillingInfo.Id ];
                	 
                	   CurrentBillingInfo.Status_Masterdata__c = midato.Status_Masterdata__c;
                	 }
                	
                	system.debug('Requiere_Masterdata_esta_marcado2?' + CurrentBillingInfo);
                	if(CurrentBillingInfo.Requiere_Masterdata__c == true)
                    {
                    	system.debug('\n\n Requiere_Masterdata_si ' + CurrentBillingInfo.Requiere_Masterdata__c + 'Status_Masterdata__actual  ' +CurrentBillingInfo.Status_Masterdata__c);
                    	if(CurrentBillingInfo.Status_Masterdata__c <> null)
            		    {
            		      system.debug('\n\n Requiere_Masterdata__c ' + CurrentBillingInfo.Requiere_Masterdata__c + 'Status_Masterdata__actual  ' +CurrentBillingInfo.Status_Masterdata__c);
            		      if(CurrentBillingInfo.Status_Masterdata__c   == 'ENVIADO')
	            		    {
	            		    	
	            		    	CurrentBillingInfo.Status_Masterdata__c   = 'EN PROCESO';
	            		    }else if(CurrentBillingInfo.Status_Masterdata__c   == 'FINALIZADO')
	            		    {
	            		    	CurrentBillingInfo.Status_Masterdata__c   = 'ENVIADO';
	            		    }	
            		    }else 
            		    {
	            		   CurrentBillingInfo.Status_Masterdata__c   = 'ENVIADO';
            		    }
                    }
                  system.debug('\n\n Requiere_Masterdata_si3 ' + CurrentBillingInfo.Requiere_Masterdata__c + 'Status_Masterdata__actual  ');
                  system.debug('\n\n Dato_de_facturacion_cambio_su_informacion_de_facturacion_11  ' + CurrentBillingInfo.Requiere_Masterdata__c);  
                }
            //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
           
                
                if(CurrentBillingInfo.Id == null){
                    
                    CL006_BillingRules CurrentBillingRules = new CL006_BillingRules(CurrentBillingInfo);
                                
                    //create billing
                    CurrentBillingRules.CreateBillingRecord();
                }
                else{
                    //update billing
                    system.debug('\n\n Es_una_modificacion_del_dato' + Apexpages.currentPage().getParameters().keySet() );
                    //create an object with request params
                    List<Cuota_facturacion__c> lstQuoteToUpdate = new List<Cuota_facturacion__c>();
                    map<Decimal,Date> lstQuoteDate = new map<Decimal,Date>();
                    
                    
                    //verificar si ademas se necesita una condicion adicional para fact por vigencias
                    if(CurrentBillingInfo.billing_type__c =='Facturación Especial')
                    {
	                    for(string strQuoteId:Apexpages.currentPage().getParameters().keySet())
	                    {
	                        system.debug('strQuoteId===>>> '+strQuoteId);
	                        if(strQuoteId.contains('QuoteObjectId')){
	                            
	                            Cuota_facturacion__c upq = new Cuota_facturacion__c(Dato_facturacion__c = CurrentBillingInfo.id);
	                            
	                            upq.Id = Apexpages.currentPage().getParameters().get(strQuoteId);
	                            upq.Valor_cuota__c = decimal.valueOf(Apexpages.currentPage().getParameters().get(strQuoteId.replace('QuoteObjectId','Field_QuoteValue')).replace('.','').replace(',','.'));
	                            upq.Partida_de_presupuesto__c = Apexpages.currentPage().getParameters().get(strQuoteId.replace('QuoteObjectId','QuoteLineItemId'));
	                            upq.No_Cuota__c = Integer.valueof(Apexpages.currentPage().getParameters().get(strQuoteId.replace('QuoteObjectId','QuoteNumber')));
	                            system.debug('upq_Valor_cuota__c_new'+upq.Valor_cuota__c);
	                            if(!lstQuoteDate.containsKey(upq.No_Cuota__c)){
	                                lstQuoteDate.put(upq.No_Cuota__c,
	                                    getTimeInFormat(Apexpages.currentPage().getParameters().get(strQuoteId.replace('QuoteObjectId','Field_QuoteDate'))));
	                            }
	                            upq.Fecha_cuota__c = lstQuoteDate.get(upq.No_Cuota__c);
	                                                                                    
	                            lstQuoteToUpdate.add(upq);
	                        }           
	                    }
                    }else
                    {
                    	lstQuoteToUpdate = getQuoteInfo();
                        system.debug('lstQuoteToUpdate============>>>  '+lstQuoteToUpdate);
                    }
                    
                    //update billing information
                    CL006_BillingRules CurrentBillingRules = new CL006_BillingRules(CurrentBillingInfo.Id);
                    CurrentBillingRules.UpdateBillingRecord(CurrentBillingInfo,lstQuoteToUpdate);
                   
                }
                
                
            
            }
            else{
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'El número de cuotas debe ser mayor a cero (0).');
                ApexPages.addMessage(errorMsg);
                this.ErrorMessage = 'El número de cuotas debe ser mayor a cero (0).';
                return null;
            }
            
         } 
         
       //fact vigencia
       datofactok = true;
              
      }catch(Exception er){
      	    system.debug('\n\n ERROR_PRESENTADO == \n' +'Linea:: ' + string.valueof(er.getLineNumber()) + '::' +  
                'Linea:: ' +  string.valueof(er.getStackTraceString()) + '::' +
                er.getMessage()+'\n');
                
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO,  + 'No fue posible guardar el dato de facturación ' + er.getMessage());
            ApexPages.addMessage(errorMsg);
            this.ErrorMessage ='No fue posible guardar el dato de facturación ' + er.getMessage();
        }
        
         
        system.debug('\n\n datofactok=====>' + datofactok);
        return null;    
    }
   
    public boolean Completdata() {
    	
    	boolean complet = true;
    	
    	if(CurrentBillingInfo.Tipo_identificacion__c <> null && CurrentBillingInfo.Numero_identificacion__c <> null && CurrentBillingInfo.Razon_social__c <> null)
    	{}else
    	{
    		complet = false;
    	}
    	if(CurrentBillingInfo.Direccion_facturacion__c <> null && CurrentBillingInfo.Telefono_contacto_financiero__c <> null && currentBillingInfo.Correo_facturacion__c <> null)
        {}else
    	{
    		complet = false;
    	}
        if(CurrentBillingInfo.Ciudad_facturacion__c <> null && CurrentBillingInfo.Ciudad_telefono_facturacion__c <> null )
        {}else
    	{
    		complet = false;
    	}
        if(CurrentBillingInfo.Valor_facturacion__c <> null && CurrentBillingInfo.Name <> null )
    	{}else
    	{
    		complet = false;
    	}
      
       system.debug('\n\n validacion_de_datos  ' +complet );
    	return complet;
    }
   
    /****************************************VALIDACION DE NIE ********************************************************
	JAAR 21-05-2014 
	1- VERIFICA SI EL NIE DILIGENCIADO ES VALIDO 
	**********************************************************************************************************************************/  
   public boolean validaNie(String Nieactual)
   {
   	 boolean niecorrecto = false;
   	 system.debug('Entro_a_validaNie');
   	  try
	   {
	   	 list<NieValidos__c> Nielist = [SELECT Id,Name,NIE__c,Restriccion__c,TipoCliente__c,Tipo_de_restriccion__c FROM NieValidos__c
	   	 								WHERE NIE__c =:Nieactual AND Restriccion__c = false];
	   	 if(Nielist != null)
	   	 {
	   	 	if(Nielist.size() > 0)
	   	 	{
	   	 		system.debug('El_nie_digitado_es_valido');
	   	 	    niecorrecto = true;
	   	 	}
	   	 	
	   	 }else
	   	 {
	   	 	system.debug('11_El_nie_digitado_No_es_valido');
	   	 }								
	   }catch(Exception er){
	   	  system.debug('Se presentaron inconvenientes en la validacion realizada con el NIE de codensa');
	   }
   	 return niecorrecto;
   }
   
   
   
   
   /****************************************CONTROL AL SERVICIO DE MASTERDATA ********************************************************
	JAAR 02-04-2014 
	1- VERIFICA SI ES NECESARIO REALIZAR EL LLAMADO AL SERVICIO 
	**********************************************************************************************************************************/ 
   public pagereference SWMasterdata()
   {
   	  boolean Masterdatago = false;
   	  system.debug('Entro_a_SWMasterdata');
   	    try
	   {
   	  		list<Dato_facturacion__c> Datfact = [SELECT Presupuesto__r.Opportunity.Account.Identificacion__c,Presupuesto__r.Opportunity.Account.Codigo_cliente_unico__c,Presupuesto__r.Opportunity.Account.Tipo_identificacion__c,Presupuesto__r.Opportunity.Account.Numero_identificacion__c,
	    								         	Presupuesto__r.Opportunity.AccountId,Ciudad_facturacion__c,Ciudad_telefono_facturacion__c,Correo_facturacion__c,Direccion_facturacion__c,
	    										    Id,Numero_identificacion__c,Tipo_identificacion__c,Tipo_identificacion__r.Name 
	    								         FROM Dato_facturacion__c WHERE ID =: CurrentBillingInfo.Id];
	    								     
   	  		list<Identificaciones__c> idd = [SELECT Cliente_unico__c,datesyncMasterdata__c,Direccion_facturacion__c,Email_Facturacion__c,Id,Name,Numero_identificacion__c,
	        						  Pendiente_pago__c,Telefono_facturacion__c,Tipo_identificacion__c 
	        						  FROM Identificaciones__c WHERE Id =: Datfact[0].Presupuesto__r.Opportunity.Account.Identificacion__c ];
         
	     if(Datfact.size()> 0)
	      {
	      	if(idd.size() >0)
		      {
		      	if(Datfact[0].Numero_identificacion__c <> Datfact[0].Presupuesto__r.Opportunity.Account.Numero_identificacion__c || Datfact[0].Tipo_identificacion__c <> Datfact[0].Presupuesto__r.Opportunity.Account.Tipo_identificacion__c)
			      {
			      	//El numero o tipo de identificacion cambio 
			      	UpdateDataidentification();
			      	Masterdatago = true;
			      }else
			      {
			      	 system.debug('Tiene_identificacion_ se actualizara el servicio');
			      	UpdateDataidentification();
			      	Masterdatago = true;
			      }
		      }else
		      {
		      	UpdateDataidentification();
		      	Masterdatago = true;
		      }
	      }
	     
	   }catch(Exception er){
	   	  system.debug('Se presentaron inconvenientes en el llamado del servicio Masterdata');
	   }   
	     
	  return null;    
	      
   }
   
    
    /****************************************LLAMADO AL SERVICIO DE MASTERDATA UpdateDataidentification********************************
	JAAR 02-04-2014 
	1- Devuelve el cliente unico, direccion telefono, email de un nit enviado
	@param  Identificación, tipo de identificación y se envia por defecto 2 para pais = Colombia
	**********************************************************************************************************************************/
        	
    public boolean UpdateDataidentification()
    {
    	boolean Founddata = false;
    	Switch_ServicioMasterdata__c OFFSWMasterdata = Switch_ServicioMasterdata__c.getAll().get('Dato_facturación');
    	
    	if(OFFSWMasterdata.OFF_SWMasterdata__c == false) 
    	{
    		CAllOUT002_MD_GetClienteUnico SwMasterdata = new CAllOUT002_MD_GetClienteUnico();
	        Dato_facturacion__c DatfactMd = [SELECT Presupuesto__r.Opportunity.Account.Identificacion__c,Presupuesto__r.Opportunity.Account.Requiere_Masterdata__c,Presupuesto__r.Opportunity.Account.Codigo_cliente_unico__c,Presupuesto__r.Opportunity.Account.Tipo_identificacion__c,Presupuesto__r.Opportunity.Account.Numero_identificacion__c,
	    								         	Presupuesto__r.Opportunity.AccountId,Ciudad_facturacion__c,Ciudad_telefono_facturacion__c,Correo_facturacion__c,Direccion_facturacion__c,
	    										    Id,Numero_identificacion__c,Tipo_de_solicitud_Masterdata__c,Tipo_identificacion__c,Tipo_identificacion__r.Name,Requiere_Masterdata__c,Status_Masterdata__c 
	    								     FROM Dato_facturacion__c WHERE ID =: CurrentBillingInfo.Id];
        	//LLAMADO AL SW DE MASTERDATA							     
    		SwMasterdata.invoke(SwMasterdata.fnWrapperIdentificationInfo(CurrentBillingInfo.Numero_identificacion__c,DatfactMd.Tipo_identificacion__r.Name,'2'));
            
	        if(SwMasterdata.uniqueCustomer <> null)
	        {
	            if(SwMasterdata.uniqueCustomer <> 0)
	            {
		            Founddata = true;
		            //Si el servicio responde satisfactoriamente actualizamos el objeto Identificacion de salesforce
		            list<Identificaciones__c> IdentificationData = new list<Identificaciones__c>();
		            IdentificationData = [SELECT Cliente_unico__c,datesyncMasterdata__c,Direccion_facturacion__c,Email_Facturacion__c,Id,Name,Numero_identificacion__c,
		        						  Pendiente_pago__c,Telefono_facturacion__c,Tipo_identificacion__c 
		        						  FROM Identificaciones__c WHERE Cliente_unico__c =:SwMasterdata.uniqueCustomer];
		            
		            if(IdentificationData.size()>0)
		            {
		            	system.debug('\n\n Registro_encontrado_en_identificaciones');
		            	//Si existe el objeto Identificaciones__c se actualizará informacion--------------------------
		            	IdentificationData[0].datesyncMasterdata__c    = System.now();
		            	IdentificationData[0].Cliente_unico__c 		  = SwMasterdata.uniqueCustomer;
		            	IdentificationData[0].Numero_identificacion__c = DatfactMd.Numero_identificacion__c;
		            	IdentificationData[0].Tipo_identificacion__c   = DatfactMd.Tipo_identificacion__c;
		            	if(SwMasterdata.cityOriginId <> null)
		            	{
		            		Ciudad__c ciud = getCiudadBycod(SwMasterdata.cityOriginId);
		            	    IdentificationData[0].Ciudad_facturacion__c    = ciud.Id;
		            	}
		            	
		            	if(SwMasterdata.address<> null)
		            	{
		            		IdentificationData[0].Direccion_facturacion__c = SwMasterdata.address;	
		            	}else
		            	{
		            		system.debug ('no se encontro direccion  ');
		            	}
		            	if(SwMasterdata.emailMasterdata<> null)
		            	{
		            		IdentificationData[0].Email_Facturacion__c = SwMasterdata.emailMasterdata;	
		            	}else
		            	{
		            		system.debug ('no se encontro email para actualizar  ');
		            	}
		            	if(SwMasterdata.telephoneNumber<> null)
		            	{
		            		IdentificationData[0].Telefono_facturacion__c = String.valueOf(SwMasterdata.telephoneNumber);	
		            	}else
		            	{
		            		system.debug ('no se encontro Telefono para actualizar  ');
		            	}
		            	update IdentificationData;
		            	
		            	
		            	//-----------------------------------------------------------------------------------------------
		            }else
		            {
		            	//1- Crear el objeto Identificaciones__c en salesforce con la informacion del servicio
		            	system.debug('\n\n Registro_no_existe_en_identificaciones');
		            	Identificaciones__c Insertidentification      = new Identificaciones__c();
		            	Insertidentification.datesyncMasterdata__c    = System.now();
		            	Insertidentification.Cliente_unico__c 		  = SwMasterdata.uniqueCustomer;
		            	Insertidentification.Numero_identificacion__c = DatfactMd.Numero_identificacion__c;
		            	Insertidentification.Tipo_identificacion__c   = DatfactMd.Tipo_identificacion__c;
		            	if(SwMasterdata.cityOriginId <> null)
		            	{
		            		Ciudad__c ciud = getCiudadBycod(SwMasterdata.cityOriginId);
		            	    Insertidentification.Ciudad_facturacion__c    = ciud.Id;
		            	}
		            	
		            	
		            	DatfactMd.Requiere_Masterdata__c 			  = false;// desmarco para no activar mas el flujo	
	            	    if(DatfactMd.Status_Masterdata__c <> null)
	            	    {
	            	       DatfactMd.Status_Masterdata__c   		  = 'FINALIZADO';
	            	    }
	            	    
		            	//Si el nit pertencece a la cuenta se relaciona 
		            	if(DatfactMd.Numero_identificacion__c == DatfactMd.Presupuesto__r.Opportunity.Account.Numero_identificacion__c && DatfactMd.Tipo_identificacion__c == DatfactMd.Presupuesto__r.Opportunity.Account.Tipo_identificacion__c)
		            	{
		        		   system.debug('nit pertencece a_la_cuenta_relacionada ');
		        		   /*Insertidentification.cuenta__c				  = DatfactMd.Presupuesto__r.Opportunity.AccountId;*/
		        		   //ACTUALIZO EL CU DE LA CUENTA 
		        		   myAccount = [SELECT Identificacion__c,
		        		   Requiere_Masterdata__c,Status_Masterdata__c,Id,Name,Numero_identificacion__c,Tipo_identificacion__c,Codigo_cliente_unico__c,Telefono_facturacion__c,Direccion_facturacion__c,Email_corporativo__c  FROM Account 
		            							   WHERE Numero_identificacion__c =: DatfactMd.Numero_identificacion__c AND  Tipo_identificacion__c =: DatfactMd.Tipo_identificacion__c ];
		        		   if(myAccount.size()>0)
		            		{
		            			//JAAR recorre las cuentas con la misma identificacion y las actualiza
		            			for(Account acc:myAccount)
		            			{
		            				 acc.Codigo_cliente_unico__c		= SwMasterdata.uniqueCustomer;
			            			 acc.Telefono_facturacion__c		= String.valueOf(SwMasterdata.telephoneNumber);
			            			 acc.Direccion_facturacion__c		= SwMasterdata.address;
			            			 acc.Email_corporativo__c			= SwMasterdata.emailMasterdata;
			            			 acc.Requiere_Masterdata__c 		= false;
			            			 
			            			 if(acc.Status_Masterdata__c <> null)
			            			 {
			            			 	 acc.Status_Masterdata__c   		= 'FINALIZADO';
			            			 }
		            			}
		            			 
		            			
		            		}
		        		   //JAAR no va aqui update myAccount;
		        		}else
		            	{
		            		system.debug('nit_no_pertencece_a_la_cuenta_relacionada ');
		            		OtheAccount = [SELECT Requiere_Masterdata__c,Identificacion__c,Status_Masterdata__c,Id,Name,Numero_identificacion__c,Tipo_identificacion__c,Codigo_cliente_unico__c,Telefono_facturacion__c,Direccion_facturacion__c,Email_corporativo__c 
		            									 FROM Account 
		            							         WHERE Numero_identificacion__c =: DatfactMd.Numero_identificacion__c AND  Tipo_identificacion__c =: DatfactMd.Tipo_identificacion__c ];
		            		
		            		if(OtheAccount.size()>0)
		            		{
		            		  
		            		  for(Account acc:OtheAccount)
		            			{
		            			   acc.Codigo_cliente_unico__c		= SwMasterdata.uniqueCustomer;
			            		   acc.Telefono_facturacion__c		= String.valueOf(SwMasterdata.telephoneNumber);
			            		   acc.Direccion_facturacion__c     = SwMasterdata.address;
			            		   acc.Email_corporativo__c 		= SwMasterdata.emailMasterdata;
			            		   acc.Requiere_Masterdata__c 		= false;
			            		   if(acc.Status_Masterdata__c <> null)
			            			 {
			            			 	 acc.Status_Masterdata__c   	= 'FINALIZADO';
			            			 }
		            			}
		            		   
		            			 
		            		   update OtheAccount;
		            		}
		        	    }
		            	     
		            	if(SwMasterdata.address<> null)
		            	{
		            		Insertidentification.Direccion_facturacion__c = SwMasterdata.address;	
		            	}else
		            	{
		            		system.debug ('no se encontro direccion  ');
		            	}
		            	if(SwMasterdata.emailMasterdata<> null)
		            	{
		            		Insertidentification.Email_Facturacion__c = SwMasterdata.emailMasterdata;	
		            	}else
		            	{
		            		system.debug ('no se encontro email para actualizar  ');
		            	}
		            	if(SwMasterdata.telephoneNumber<> null)
		            	{
		            		Insertidentification.Telefono_facturacion__c = String.valueOf(SwMasterdata.telephoneNumber);	
		            	}else
		            	{
		            		system.debug ('no se encontro Telefono para actualizar  ');
		            	}
		            	
		            	update DatfactMd;
		            	insert Insertidentification;
		            	system.debug ('my_Accountes=====>>>  '+ myAccount + ' OtheAccount ' + OtheAccount +' mi identificacion_es '+ Insertidentification.id);
		            	if(myAccount<>null)
		            	{
		            		if(myAccount.size()>0)
		            		{
		            			for(Account acc:myAccount)
			            			{
			            				acc.Identificacion__c				= Insertidentification.Id;
			            			}
		            			
		            			update myAccount;
		            		}
		            	}
		            	if(OtheAccount<>null)
		            	{
		            		system.debug ('OtheAccount_size ' + OtheAccount.size());
			            	if(OtheAccount.size()>0)
			            	{
			            		system.debug('se_modificara_OtheAccount ' + OtheAccount);
			            		for(Account acc:OtheAccount)
			            			{
			            				acc.Identificacion__c			= Insertidentification.Id;
			            			}
			            		
			            		update OtheAccount;
			            	}
		            	}
	            		
		            }                      
	                system.debug ('mi_cliente_unico_es  ' + SwMasterdata.uniqueCustomer);
		            system.debug ('mi_address_es  ' + SwMasterdata.address);
		            system.debug ('mi_billing_es  ' + SwMasterdata.billing);
		            system.debug ('emailMasterdata  ' + SwMasterdata.emailMasterdata);	
	            }else
	            {
	            	system.debug('\n\n Registro no encontrado en Masterdata\n\n');
	            	//JAAR 11-04-2014 acciones a realizar para gestionar la creación del cliente en MD 
	            	//ACTUALIZO EL CU DE LA CUENTA 
        		   list<Account> myAccount = [SELECT Id,Name,Numero_identificacion__c,Requiere_Masterdata__c,Status_Masterdata__c,Tipo_identificacion__c,Codigo_cliente_unico__c,Telefono_facturacion__c,Direccion_facturacion__c,Email_corporativo__c  FROM Account 
            							      WHERE Numero_identificacion__c =: DatfactMd.Numero_identificacion__c AND  Tipo_identificacion__c =: DatfactMd.Tipo_identificacion__c ];
        		   // 1 - Si la cuenta existe es marcada para disparar el flujo que crea la tarea y envia mail
        		   if(myAccount.size()>0)
            		{
            			myAccount[0].Requiere_Masterdata__c = true;
            			//verificacion del estado de la solicitu a mastardata para el envio de la tarea
            			if(myAccount[0].Status_Masterdata__c   <> null)
            		    {
            		      if(myAccount[0].Status_Masterdata__c   == 'ENVIADO')
	            		    {
	            		    	system.debug('	Status_Masterdata__actual   ' + myAccount[0].Status_Masterdata__c);
	            		    	myAccount[0].Status_Masterdata__c   = 'EN PROCESO';
	            		    }else if(myAccount[0].Status_Masterdata__c   == 'FINALIZADO')
	            		    {
	            		    	myAccount[0].Status_Masterdata__c   = 'ENVIADO';
	            		    }	
            		    }else 
            		    {
	            		   myAccount[0].Status_Masterdata__c   = 'ENVIADO';
            		    }
            			update myAccount;
            		}else
            		{
            			// 2 - Si el NIT o CC  a la que se hace referencia junto con su tipo no existe en salesforce como cuenta se deja la marca en el dato de facturación para para disparar el flujo que crea la tarea y envia mail
            		    // 3 - Solo se disparará la tarea una vez, se controla que si realiza modificaciones posteriores no envie la tarea.
            		    DatfactMd.Requiere_Masterdata__c = true;
            		    DatfactMd.Tipo_de_solicitud_Masterdata__c = 'CREACIÓN DE TERCERO';
            		    if(DatfactMd.Status_Masterdata__c   <> null)
            		    {
            		      if(DatfactMd.Status_Masterdata__c   == 'ENVIADO')
	            		    {
	            		    	system.debug('	Status_Masterdata__actual   ' + DatfactMd.Status_Masterdata__c);
	            		    	DatfactMd.Status_Masterdata__c   = 'EN PROCESO';
	            		    }else if(DatfactMd.Status_Masterdata__c   == 'FINALIZADO')
	            		    {
	            		    	DatfactMd.Status_Masterdata__c   = 'ENVIADO';
	            		    }	
            		    }else 
            		    {
	            		   DatfactMd.Status_Masterdata__c   = 'ENVIADO';
            		    }
            		    update DatfactMd;
            		    system.debug('	Status_Masterdata__actual_post   ' + DatfactMd.Status_Masterdata__c);
            		}
            		
	            	
	            }
	            
	            
        	}
    	}else
    	{
    		 system.debug ('\n\n EL SW Masterdata ClienteUnico se encuentra apagado desde Salesforce\n\n ' );
    		 Founddata = true;	
    	}
    
    	return Founddata;
    }
    
      public PageReference MSGerror()
    {
    	 system.debug('Se_generó_un_mensaje de error' + this.ErrorMessage);
    	 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+this.ErrorMessage));
    	 return null;
    }
    
    /*
    **** JAAR 17-02-2015 Metodo que muestra u oculta los campos necesarios para el agente de recaudo codensa
    */
     public Pagereference renderagrecaudo(){
     	system.debug('entro_a_renderagrecaudo');
     	if(CurrentBillingInfo.Agente_recaudo__c == 'CODENSA') 
     	{
     		renderNie = true;
     		requiredNie = true;
     	}
     	if(CurrentBillingInfo.Agente_recaudo__c == 'FACTURA DIRECTA')
     	{
     		renderNie = false;
     		requiredNie = false;
     		CurrentBillingInfo.NIE__c = null; //si se selecciona esta opcion se borra el nie ya que no es requerido ni aplica
     	}
     	
     	return null;
     }
     
     public pageReference renderpage() {
                    //JAAR 17-02-2015 mostrar o ocultar la seccion de vigencias -----------------------------------------------
                system.debug('entro_a_renderpage');
                //1 - visualizacion de facturacion por vigencias
                if(CurrentBillingInfo.billing_type__c == 'Facturación por vigencia')
                 {
                        rendervigencias = true;
                        CurrentBillingInfo.Cuota_normalizada__c = true;
                        system.debug('dato_por__vigencias  ' + CurrentBillingInfo.billing_type__c + ' ' + rendervigencias);
                        
                        //CurrentBillingInfo.Numero_cuotas__c = 1; //pend ***********************************************
                        requiredcuotas = false;
                        requiredvigencias = true;
                 }else
                 {
                        rendervigencias = false;
                        requiredcuotas = true; 
                        requiredvigencias = false;
                        system.debug('dato_por_de_vigencias' + CurrentBillingInfo.billing_type__c + rendervigencias);
                 }
                 //2- visualizacion de facturacion por cuotas
                 if(CurrentBillingInfo.billing_type__c == 'Facturación por cuotas iguales')
                 {
                        rendercuotas = true;
                        CurrentBillingInfo.Cuota_normalizada__c = true;
                        requiredvigencias = false;
                 }else
                 {
                        rendercuotas = false;
                 }
                    //2- visualizacion de facturacion por cuotas especiales
                 if(CurrentBillingInfo.billing_type__c == 'Facturación Especial')
                 {
                        rendercespeciales = true;
                        rendervalores = false;
                        rendercuotas = true;
                        requiredvigencias = false;
                        CurrentBillingInfo.Cuota_normalizada__c = false; // JAAR - se deja editable para que el asesor pueda acomodar los valores a su parecer
                 }else
                 {
                        rendercespeciales = false;
                        rendervalores = true;
                 }
                     
                
                 return null;
         }
        
    
    
    
    private Date getTimeInFormat(string strToParse){

        Date oRetorno = date.newinstance
            (Integer.valueOf(strToParse.split('/')[2]),
            Integer.valueOf(strToParse.split('/')[1]),
            Integer.valueOf(strToParse.split('/')[0])); 
    
        return oRetorno;
    }

    
      //JAAR 17-02-2015 Se realiza modificacion para qwue el darto de facturación soporte varios tipos de facturación
  //devuelbe lista de productos por cotización
  public List<QuoteLineItem> getQuoteLineIteminf() {
          List<QuoteLineItem> qlitem = [SELECT Id,QuoteId,Numberquota__c,PricebookEntry.Product2.ProductCode,PricebookEntry.Product2.Name,Quantity,TotalPrice FROM QuoteLineItem
                                        WHERE  QuoteId =:CurrentBillingInfo.Presupuesto__c ];  
         
           if(qlitem.size()>0){
                system.debug('getQuoteLineIteminf_Retorno_LOS_PRODUCTOS--> '+qlitem);
            return qlitem;
        }else{
                system.debug('getQuoteLineIteminf_Retorno null--> ');
            return null;
        }
        
        
  } 
    
    
    /*get related quote info*/
    public List<Cuota_facturacion__c> getQuoteInfo(){
        
        List<Cuota_facturacion__c> oRetorno = new List<Cuota_facturacion__c>();
        
        if(CurrentBillingInfo.Id != null){
            
            oRetorno = 
                [select id
                        ,No_Cuota__c
                        ,Partida_de_presupuesto__c
                        ,Valor_cuota__c
                        ,Fecha_cuota__c
                        
                        ,Dato_facturacion__c
                        ,Estado__c
                        ,Partida_de_presupuesto__r.LineNumber
                        ,Partida_de_presupuesto__r.PricebookEntry.Product2.Name
                        ,Partida_de_presupuesto__r.PricebookEntry.Product2.ProductCode
                         ,Partida_de_presupuesto__r.PricebookEntry.Product2.Numero_cuotas_maximo__c
                from    Cuota_facturacion__c
                where   Dato_facturacion__c =: CurrentBillingInfo.Id
                order by No_Cuota__c,Partida_de_presupuesto__r.LineNumber];

        }
       
        return oRetorno; 
    }
    
     /*******************************Info-cuenta por IdIdentitificación *******************************************/
    public Account getAccountByIdident(String IdentityId){
    	list<Account> accid = [SELECT Identificacion__c,
							   Requiere_Masterdata__c,Status_Masterdata__c,Id,Name,Numero_identificacion__c,Tipo_identificacion__c,Codigo_cliente_unico__c,Telefono_facturacion__c,Direccion_facturacion__c,Email_corporativo__c  
							   FROM Account   where Identificacion__c =:IdentityId];
    
    if(accid.size()>0){
            return accid.get(0);      
        }else{      
            return null;
        } 
    } 
    
    /*******************************Info-Identificacion por cuenta *******************************************/
    public Identificaciones__c getIdentificacionesByaccount(String IdentityId){
    	list<Identificaciones__c> idd = [SELECT Cliente_unico__c,Ciudad_facturacion__c,Direccion_facturacion__c,Email_Facturacion__c,Id,Name,Numero_identificacion__c,Pendiente_pago__c,Telefono_facturacion__c,Tipo_identificacion__c 
    									 FROM Identificaciones__c  where Id =:IdentityId];
    
    if(idd.size()>0){
            return idd.get(0);      
        }else{      
            return null;
        } 
    }
    
    
    /*******************************Info-Ciudad  por codigo Agcod *******************************************/
    public Ciudad__c getCiudadBycod(String codigoac){
    	system.debug('codigo agustin _c  '+codigoac );
    	list<Ciudad__c> ciudad = [SELECT Codigo_ciudad__c,Id,Name FROM Ciudad__c  where Codigo_ciudad__c =:codigoac];
    
    if(ciudad.size()>0){
            return ciudad.get(0);      
        }else{      
            return null;
        } 
    }  
  
   /*******************************Info-Identificacion por id *******************************************/
    public Identificaciones__c getIdentificacionesBynumber(String Identificacion, id tipo){
    	list<Identificaciones__c> idd = [SELECT Cliente_unico__c,Ciudad_facturacion__c,Direccion_facturacion__c,Email_Facturacion__c,Id,Name,Numero_identificacion__c,Pendiente_pago__c,Telefono_facturacion__c,Tipo_identificacion__c 
    									 FROM Identificaciones__c where Numero_identificacion__c =:Identificacion AND Tipo_identificacion__c =:tipo];
    
    if(idd.size()>0){
            return idd.get(0);      
        }else{      
            return null;
        } 
    }   
  
    
}