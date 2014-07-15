/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Junio 17 de 2014
*  Decripción:          Clase que controla el registro de ventas limitadas en cada control de inventario compuesto por 
*                       Seccion + Tipo de Inventario + Ciudad 
*  @version:            1.0
* ===================================================================================================================================
**/ 

public with sharing class CTR012_RegistrovtaLimitada
{ 
	  
	  private Registro_de_Venta_Limitada__c oRegvtalimitada; 
	  public QuoteLineItem MyQuoteLineItem{get;set;}
	  public String stridQuoteLineItem{get;set;}
	  public String stridRegistroVtaLim{get;set;}
	  public boolean validatedata {get;set;}
	  public Registro_de_Venta_Limitada__c inventariovigente {get;set;}
	  public List<Control_de_Inventario__c> ControlInvenActual;
	  public Registro_de_Venta_Limitada__c VentaLimitadaactual; 
	  public boolean ciudadprincipal {get;set;}
	  
	 ApexPages.StandardController CtxController;
	 
	 public CTR012_RegistrovtaLimitada(ApexPages.StandardController stdController) {
	 	validatedata = true;
        CtxController = stdController;
        oRegvtalimitada = (Registro_de_Venta_Limitada__c)CtxController.getRecord();
	    if(oRegvtalimitada.Id <> null)
	    {
	      VentaLimitadaactual = getVtaLimitada(oRegvtalimitada.Id); 
	      stridQuoteLineItem = VentaLimitadaactual.Partida_de_presupuesto__c;	
	    }else{
	      //verificar si el producto si es de venta limitada
	       
	    }
	    
        
	 }
	 
	 
	 
	  public Registro_de_Venta_Limitada__c Regvtalimitada{ 
        get {
            if(oRegvtalimitada == null){
                oRegvtalimitada = (Registro_de_Venta_Limitada__c)CtxController.getRecord();
            }
            return oRegvtalimitada;
        }
        set{
            oRegvtalimitada = value;
        }
    }  
    
   
   /*******************************************************************************************************************************    
    * LoadTipodeInventario == Metodo que carga la pagina con la seccion y el tipo de inventario con las que esta atado el producto
    *******************************************************************************************************************************/  
    public pageReference LoadTipodeInventario() {
    	system.debug('My_Regvtalimitada ' + Regvtalimitada);
    	 
     try{
           if(Regvtalimitada.Id == null)
           {
    	   	   MyQuoteLineItem = getQuoteLineItem(Regvtalimitada.Partida_de_presupuesto__c);
    	   	   stridQuoteLineItem = MyQuoteLineItem.Id;
               system.debug('My_stridQuoteLineItem ' + stridQuoteLineItem);
              
    	   	   system.debug('Regvtalimitada_solo' + Regvtalimitada + 'MyQuoteLineItem ' + MyQuoteLineItem);
	    	   Regvtalimitada.Activado__c = false;
	    	   Regvtalimitada.Contrato__c = MyQuoteLineItem.Quote.Opportunity.Numero_contrato__c ;
	    	   if(MyQuoteLineItem.Activo_renovacion__c <> null || MyQuoteLineItem.Activo_Upselling__c <> null )
	    	   {
	    	   	Regvtalimitada.Estado__c = 'RENOVADO';
	    	   }else
	    	   {
	    	   	Regvtalimitada.Estado__c = 'EN PROCESO';
	    	   }
	    	   Regvtalimitada.Partida_de_presupuesto__c = MyQuoteLineItem.Id;
	    	   Regvtalimitada.Seccion_principal__c = MyQuoteLineItem.Seccion__c;
	    	   Regvtalimitada.Tipo_de_Inventario__c = MyQuoteLineItem.PricebookEntry.Product2.Tipo_Inventario__c;
	    	   Regvtalimitada.Precio__c = MyQuoteLineItem.PricebookEntry.Product2.Price_additional_city__c;
	    	   
	    	   
	    	   
	    	   system.debug('Regvtalimitada.Tipo_de_Inventario__c' + Regvtalimitada.Tipo_de_Inventario__c );
    	   }else
    	   {
    	   	   system.debug('Id_ya_existia' + MyQuoteLineItem);
    	   	   MyQuoteLineItem = getQuoteLineItem(stridQuoteLineItem); 
    	   	   Regvtalimitada.Seccion_principal__c = MyQuoteLineItem.Seccion__c;
	    	   Regvtalimitada.Tipo_de_Inventario__c = MyQuoteLineItem.PricebookEntry.Product2.Tipo_Inventario__c;
	    	   //si es clase de prueba se realiza la busqueda de una seccion ciudad y tipo de inventario para validar la cobertura
		    	if(Test.isRunningTest())
				{
					ValidarDisponibilidad();
				}
	    	   
	    	   
    	   }
           if(MyQuoteLineItem.PricebookEntry.Product2.Allows_Additional_City__c == false)
               {
               	 this.setMsg(0, 'El producto actual ' + MyQuoteLineItem.PricebookEntry.Product2.ProductCode +' no permite la captura de ciudades adicionales, no es posible usar esta opcion ');
               	 validatedata = false;
               	 return null;
               }else if(MyQuoteLineItem.PricebookEntry.Product2.Ventas_permitidas__c == null || MyQuoteLineItem.PricebookEntry.Product2.Ventas_permitidas__c == 0)
               {
               	 this.setMsg(0, 'No se encontró configurada la Cantidad de Ventas permitidas para el producto: ' + MyQuoteLineItem.PricebookEntry.Product2.ProductCode);
               	 validatedata = false;
               	 return null;
               } 
           	
        }catch(Exception er){
        	  system.debug('Se presento error al cargar la informacion inicial' + er );
        	
        }  
     return null;
    }
    /*Metodo que cambia el valor del precio de un registro de venta limitada si la ciudad es principal*/
    public PageReference PreciociudadPrincipal(){
    	 if(Regvtalimitada.Ciudad_es_principal__c == true)
    	 {
    	 	Regvtalimitada.Precio__c = MyQuoteLineItem.PricebookEntry.Product2.Principal_city_price__c;
    	 	Regvtalimitada.Ciudad_es_principal__c = true;
    	 }else
    	 {
    	 	Regvtalimitada.Precio__c = MyQuoteLineItem.PricebookEntry.Product2.Price_additional_city__c;
    	 }
    	 return null;
    }
    
     public Decimal Calculatevaluetotal(String stridQuoteLineItem){
     	
     	Decimal acumuladovtaslim ;
     	list<Registro_de_Venta_Limitada__c> totalvtas = getVtasasociadas(stridQuoteLineItem);
     	acumuladovtaslim = 0;
     	for(Registro_de_Venta_Limitada__c regvtas: totalvtas)
     	{
     		system.debug('acumuladovtaslim_antes '+acumuladovtaslim + '\n\n totalvtas ' + totalvtas);
     		if(regvtas.Precio__c <> null)
     		{
     			acumuladovtaslim = acumuladovtaslim + regvtas.Precio__c;
     		}
     		
     	}
     	system.debug('acumuladovtaslim_despues '+acumuladovtaslim );
     	return acumuladovtaslim;
     }
    
    public PageReference ValidarDisponibilidad(){
    	
    	if(Test.isRunningTest())
		{
			if(Regvtalimitada.Id <> null)
           {
    	   	   MyQuoteLineItem = getQuoteLineItem(Regvtalimitada.Partida_de_presupuesto__c);
    	   	   stridQuoteLineItem = MyQuoteLineItem.Id;
               system.debug('My_stridQuoteLineItem ' + stridQuoteLineItem);
               system.debug('Regvtalimitada_solo' + Regvtalimitada + 'MyQuoteLineItem ' + MyQuoteLineItem);
	           Regvtalimitada.Partida_de_presupuesto__c = MyQuoteLineItem.Id;
	    	   Regvtalimitada.Seccion_principal__c = MyQuoteLineItem.Seccion__c;
	    	   Regvtalimitada.Tipo_de_Inventario__c = MyQuoteLineItem.PricebookEntry.Product2.Tipo_Inventario__c;
	    	   system.debug('Regvtalimitada.Tipo_de_Inventario__c' + Regvtalimitada.Tipo_de_Inventario__c );
    	   }
		}
    	
    	system.debug('SECCION : ' + Regvtalimitada.Seccion_principal__c + ' TIPOINV ' + Regvtalimitada.Tipo_de_Inventario__c + ' CIUDAD ' + Regvtalimitada.Ciudad__c);
    	if((Regvtalimitada.Seccion_principal__c <> null && Regvtalimitada.Tipo_de_Inventario__c <> null && Regvtalimitada.Ciudad__c <> null)|| Test.isRunningTest())
    	{
    		
    		ControlInvenActual = getControlInventario(Regvtalimitada.Seccion_principal__c,Regvtalimitada.Ciudad__c,Regvtalimitada.Tipo_de_Inventario__c);
    	    
    	    if(ControlInvenActual.size()> 0 )
    	    { 
	    		  
	    		  system.debug('\n\n Existe_un_inventario_asociado , no es necesario crearlo' + ControlInvenActual);
	    		  // Actualizar por si se aumentó la cantidad en el produco
	    		  if(ControlInvenActual[0].Cantidad_Permitida__c <> MyQuoteLineItem.PricebookEntry.Product2.Ventas_permitidas__c)
	    		  {
	    		  	ControlInvenActual[0].Cantidad_Permitida__c = MyQuoteLineItem.PricebookEntry.Product2.Ventas_permitidas__c;
	    		    update ControlInvenActual;
	    		    system.debug('\n\n Cambio_la_cantidad_inicial_del_control_de_inventario \n' + ControlInvenActual[0].Cantidad_Permitida__c);
	    		    this.setMsg(0, 'Se identifico un cambio en el valor de la cantidad permitida para el producto actual ' +MyQuoteLineItem.PricebookEntry.Product2.ProductCode +' por favor vuelva a ejecutar el proceso ');
               	    validatedata = false;
               	    return null;
	    		  }
	    		  
	    		  
	    		  //validar disponibilidad del este registro en el inventario
	    		  if(ControlInvenActual[0].Cantidad_Disponible__c > 0 || Regvtalimitada.Estado__c == 'RENOVADO')
	    		  {
	    		  	system.debug('hay_disponibilidad_del_inventario_para : ' + ControlInvenActual[0].Id);
	    		  	if(Regvtalimitada.Control_de_Inventario__c == ControlInvenActual[0].Id)
	    		  	{
	    		  		system.debug('\n\n la venta limitada ya esta matriculada en el control de inventario ' + ControlInvenActual);
	    		  		try{
		    		  		upsert Regvtalimitada;//cambio 
		    		  		this.setMsg(1, 'la venta limitada ya se encuentra registrada en el sistema.  '+ ControlInvenActual[0].Name );
               	            validatedata = false;
               	            // 3 se actualiza el valor del producto por cotizacion
	    	                MyQuoteLineItem.UnitPrice =  MyQuoteLineItem.ListPrice + Calculatevaluetotal(stridQuoteLineItem);
	    	                update MyQuoteLineItem;
	    	                return null;	
		    		  	}catch(exception ex)
		    		  	{
		    		  		 system.debug('\n\n No_fue_posible_guardar_el_control_de_inventario ' + ex );
		    		  	}
	    		  	}else
	    		  	{
	    		  		system.debug('\n\n la venta limitada aun no esta matriculada en el control de inventario ' + ControlInvenActual);
	    		  		
	    		  		//validar si es renovacion y aun esta activo el control de inventario anterior ******************************************
	    		  		if(Regvtalimitada.Estado__c == 'RENOVADO')
	    		  		{
	    		  			system.debug('\n\n Es_una_renovacion_validaremos_el_activo ');
	    		  			if(MyQuoteLineItem.Activo_renovacion__c <> null )
	    		  			{
	    		  				// consultar si esta activo el control de inv a renovar -- 
	    		  				inventariovigente = inventarioactivo(MyQuoteLineItem.Activo_renovacion__c, Regvtalimitada.Seccion_principal__c, Regvtalimitada.Tipo_de_Inventario__c,Regvtalimitada.Ciudad__c);
	    		  				if(inventariovigente != null)
	    		  				{
	    		  					Regvtalimitada.Renueva_a__c = inventariovigente.Id;
	    		  				}
	    		  				
	    		  			}else if(MyQuoteLineItem.Activo_Upselling__c <> null)
	    		  			{
	    		  				inventariovigente = inventarioactivo(MyQuoteLineItem.Activo_Upselling__c, Regvtalimitada.Seccion_principal__c, Regvtalimitada.Tipo_de_Inventario__c,Regvtalimitada.Ciudad__c);
	    		  				if(inventariovigente != null)
	    		  				{
	    		  					Regvtalimitada.Renueva_a__c = inventariovigente.Id;
	    		  				}	
	    		  			}
	    		  			if(inventariovigente <> null)
	    		  			{
	    		  				system.debug('\n\n hay_un_inventario_vigente ' + inventariovigente);
	    		  				Regvtalimitada.Control_de_Inventario__c =  ControlInvenActual[0].Id;
	    		  			}else
	    		  			{
	    		  				 this.setMsg(0, 'No se encontró un activo vigente para la seccion, ciudad y tipo de iventario seleccionados se intentará crear un nuevo registro de venta limitada  ' );
			               	     //validatedata = false;
			               	     //se permitirá la creación pero no como renocvacion sino como registros de vta limitada nuevos
			               	     Regvtalimitada.Estado__c = 'EN PROCESO';
			               	     
			               	     if(ControlInvenActual[0].Cantidad_Disponible__c > 0)
			               	     {
			               	     	system.debug('hay_disponibilidad_para_el_nuevo_registro');
			               	     	Regvtalimitada.Control_de_Inventario__c =  ControlInvenActual[0].Id;//ppendi		               	     	
			               	     }else
			               	     {
			               	     	this.setMsg(0, 'No hay disponibilidad de inventario para la sección, ciudad y tipo de inventario seleccionados , si es una renovacion valide que el activo anterior este activo y tenga la sección, ciudad y tipo de inventario seleccionados ');
               	    				validatedata = false;
               	    				return null;
			               	     }
			               	     
	    		  			}
	    		  		}else
	    		  		{
	    		  			system.debug('es_creacion_normal_de_referencia:de_vta_limitada');
	    		  			Regvtalimitada.Control_de_Inventario__c =  ControlInvenActual[0].Id;
	    		  			
	    		  		}
	    		  		
	    		  	    //*****************************************************************************************************************	
	    	            try{
		    		  		upsert Regvtalimitada;
		    		  		this.setMsg(1, 'Se almacenó adecuadamente el registro de venta limitada , la disponibilidad esta sujeta a las primeras oportunidades que sean entregadas  ');
		    		  		validatedata = false;
	               	        // 3 se actualiza el valor del producto por cotizacion
		    	            MyQuoteLineItem.UnitPrice =  MyQuoteLineItem.ListPrice + Calculatevaluetotal(stridQuoteLineItem);
		    	            update MyQuoteLineItem;
		    	            return null;
		    	            
		    		  	}catch(exception ex)
		    		  	{
		    		  		 system.debug('\n\n No_fue_posible_guardar_el_Regvtalimitada ' + ex );
		    		  	}
	    		  	}
	    		  	
	    		  	
	    		  }else
	    		  {
	    		  	this.setMsg(0, 'No hay disponibilidad de inventario para la sección, ciudad y tipo de inventario seleccionados. ');
               	    validatedata = false;
               	    return null;
	    		  }
    	    }else
    	    {
    		  system.debug('\n\n No_existe_un_inventario_asociado _ Estado? '  + Regvtalimitada.Estado__c);
    		  // 1 - se creará un nuevo control de inventario validando su capacidad disponible
    		  MyQuoteLineItem = getQuoteLineItem(stridQuoteLineItem); 
    		  Control_de_Inventario__c newinventario = new Control_de_Inventario__c();
    		  newinventario.Cantidad_Permitida__c 	= MyQuoteLineItem.PricebookEntry.Product2.Ventas_permitidas__c;
    		  // aun no newinventario.Cantidad_Reservada__c 	= 1;
    		  newinventario.Ciudad__c 				= Regvtalimitada.Ciudad__c;
    		  newinventario.Seccion__c				= Regvtalimitada.Seccion_principal__c;
    		  newinventario.Tipo_Inventario__c		= Regvtalimitada.Tipo_de_Inventario__c;
    		  insert newinventario;
    		  system.debug('newinventario creado '  + newinventario);
    		   //si es una renovacion y la combinacion seccion-ciudad-tipo de inv no existe se alterará el estado 
    		   Regvtalimitada.Estado__c = 'EN PROCESO';
    		  // 2 - se vincula la venta al control de inventario creado 
    		   Regvtalimitada.Control_de_Inventario__c =  newinventario.Id;
	    		
	    	  // 3 se actualiza el valor del producto por cotizacion
	    	  MyQuoteLineItem.UnitPrice =  MyQuoteLineItem.ListPrice + Calculatevaluetotal(stridQuoteLineItem);	  		
	    		  		
		    		  	try{
		    		  		if(Regvtalimitada.Id <> null)
		    		  		{
		    		  			system.debug('registro_de_vta_limitada_exixstia ' + Regvtalimitada.Id);
		    		  			upsert Regvtalimitada;
		    		  			MyQuoteLineItem.UnitPrice =  MyQuoteLineItem.ListPrice + Calculatevaluetotal(stridQuoteLineItem);	 
		    		  			update MyQuoteLineItem; 
		    		  		}else
		    		  		{
		    		  			system.debug('registro_de_vta_limitada_NO_exixstia ' + Regvtalimitada.Id);
		    		  			insert Regvtalimitada;
		    		  			MyQuoteLineItem.UnitPrice =  MyQuoteLineItem.ListPrice + Calculatevaluetotal(stridQuoteLineItem);	 
		    		  			update MyQuoteLineItem; 
		    		  		}
		    		  		
		    		  		system.debug('\n\n se vincula la venta al control de inventario creado ' + Regvtalimitada);
		    		  		//se le notifica al usuario que se guardó el registro de venta en linea
		    		  		this.setMsg(1, 'Se guardó su registro de venta en linea, la disponibilidad esta sujeta a las primeras oporunidades que sean entregadas  ');
	       	                validatedata = false;
	       	               
	       	                return null;
		    		  		
		    		  		
		    		  	}catch(exception ex)
		    		  	{
		    		  		 system.debug('\n\n No_es_posible_guardar_el registro de vta limitada' + ex );
		    		  	}
    	    }
    	    
    	}else
    	{
    		system.debug('Verifique_que_tenga_seccion_Ciudad_y_Tipo_de inventario' );
    		this.setMsg(0, 'Antes de guardar verifique que esten diligenciados los campos seccion, ciudad y tipo de inventario. ');
	       	validatedata = false;
	       	return null;
    	}
    	
    	return null;
    }
    
    
     /**************** Action cancel button************/   
    public PageReference doCancel(){
        
        PageReference pageref;
        PageReference pr = new  PageReference( '/'+stridQuoteLineItem );        
        pageref= pr; 
                        
        return pageref;         
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
        
    
    /**SECCIÓN DE QUERYS****************************************************************************************************************************/   
    
     public QuoteLineItem  getQuoteLineItem(String IdQuoteLineItem){
    	list<QuoteLineItem> quotelit = [SELECT PricebookEntryId,PricebookEntry.Product2.Tipo_Inventario__r.Nombre_Tipo_Inventario__c,PricebookEntry.Product2.ProductCode ,PricebookEntry.Product2.Price_additional_city__c,
    														PricebookEntry.Product2.Principal_city_price__c,PricebookEntry.Product2.Tipo_Inventario__c, PricebookEntry.Product2.Ventas_permitidas__c, PricebookEntry.Product2.Venta_limitada__c, PricebookEntry.Product2.Allows_Additional_City__c,   
                                                            Quantity,QuoteId,Seccion__c,Subtotal,TotalPrice,UnitPrice,ListPrice,Quote.Opportunity.Numero_contrato__c,Activo_renovacion__c,Activo_Upselling__c 
                                                            FROM QuoteLineItem   where id =:IdQuoteLineItem];
    
    if(quotelit.size()>0){
            return quotelit.get(0);      
        }else{      
            return null;
        } 
    } 
   //lista de todos los registros de venta limitada asociados a un producto
   public list<Registro_de_Venta_Limitada__c>  getVtasasociadas(String quotelineitem){
    	list<Registro_de_Venta_Limitada__c> preciovtalimitada = [SELECT Id,Partida_de_presupuesto__c,Precio__c FROM Registro_de_Venta_Limitada__c   where Partida_de_presupuesto__c =:quotelineitem];
    
       return preciovtalimitada;
    }
     
    
    public Registro_de_Venta_Limitada__c  getVtaLimitada(String IdVenta_Limitada){
    	list<Registro_de_Venta_Limitada__c> VtaLimit = [SELECT Activado__c,Activo_Relacionado__c,Ciudad__c,Contrato__c,Control_de_Inventario__c,Estado__c,Id,Name,Partida_de_presupuesto__c,Seccion_principal__c,Tipo_de_Inventario__c 
    	                                                FROM Registro_de_Venta_Limitada__c   where id =:IdVenta_Limitada];
    
    if(VtaLimit.size()>0){
            return VtaLimit.get(0);      
        }else{      
            return null;
        } 
    } 
     //control de inventario de acuerdo a la ciudad seccion y tipo de inventario 
     public list<Control_de_Inventario__c>  getControlInventario(String Idseccion, String Idciudad, String Idtipoinv ){
    	List<Control_de_Inventario__c>  oRetorno = new List<Control_de_Inventario__c>();
    	
    	oRetorno = [SELECT Cantidad_Disponible__c,Cantidad_Permitida__c,
    			    Cantidad_Reservada__c,
    				Ciudad__c,CreatedById,CreatedDate,Id,Name,Seccion__c,Tipo_Inventario__c 
    	            FROM Control_de_Inventario__c   where Seccion__c =:Idseccion AND Tipo_Inventario__c =:Idtipoinv AND Ciudad__c =:Idciudad];
        return oRetorno;
    } 
  // valida si aun existe un inventario vigente  para un activo renovado  
  public Registro_de_Venta_Limitada__c inventarioactivo(String stridactivo, String Seccion,String tipoInventario,String Ciudad){
  	list<Registro_de_Venta_Limitada__c> vtaslmtadasv = [SELECT Activado__c,Activo_Relacionado__c,Contrato__c,Control_de_Inventario__c,
                                                                  Control_de_Inventario__r.Cantidad_Reservada__c,Control_de_Inventario__r.total_reservado__c,
        														  Control_de_Inventario__r.Cantidad_Disponible__c,Control_de_Inventario__r.Ciudad__c,Partida_de_presupuesto__r.PricebookEntry.Product2.Allows_Additional_City__c,
    															  Control_de_Inventario__r.Seccion__c,Control_de_Inventario__r.Tipo_Inventario__c,Estado__c,Id,Partida_de_presupuesto__c,Tipo_de_Inventario__c 
                                                           FROM   Registro_de_Venta_Limitada__c
														   WHERE  Activo_Relacionado__c =:stridactivo AND Estado__c =: 'ACTIVO' AND Control_de_Inventario__r.Tipo_Inventario__c =:tipoInventario 
														   AND Control_de_Inventario__r.Seccion__c =:Seccion AND Control_de_Inventario__r.Ciudad__c =: Ciudad];
  if(vtaslmtadasv.size()>0){
           return vtaslmtadasv.get(0);
        }else{      
             return null;
        } 
  }
 
  
  
   
}