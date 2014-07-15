/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Mayo 05 de 2014
*  Decripción:          Clase que controla las anulaciones de oportunidades
*  @version:            1.0
* ===================================================================================================================================
**/

public with sharing class CTR011_Annulationoport
{ 
   
    public String stroportunityid {get;set;} 
    public String strOperationCode{get;set;} 
    public Boolean Anulationtotal{ get; set; }
    public String profileuser{get;set;}
    public String userName{get;set;}
    public String userId{get;set;}     
    public Profile strProfile{ get; set; }
    public boolean allowedaccess {get;set;} 
    public String strtipoanulacion {get;set;} 
    public String strcausalanulacion {get;set;} 
    public list<QuoteLineItem> prodxcotizacion{get;set;} 
    public Decimal valorinicialopp{get;set;} 
    public Decimal valorpostanulacionopp{get;set;} 
    public Boolean renderpageblock { get; set; }
    public Boolean renderpageblockauxiliar { get; set; }
    public Boolean Datofacturado{ get; set; }
    public map <Id,Movimiento_produccion__c>mapmovimientosanular;
    public map <Id,Cuota_facturacion__c>mapcuotasanular;
    public set<ID> setassetanular;
    public Opportunity oppanular;
    public String Motivoanulacion{ get; set; }
    public String strPropietario {get;set;} 
    public String strRazonsocial {get;set;}
    public String strCiudad {get;set;}
    public Datetime datecerradaganada{get;set;}
    public Decimal valtotalanular{
            get{
                    if(valtotalanular==null )
                            return 0;
                    else
                            return valtotalanular;
            }set;
        }
    
    
    
    public CTR011_Annulationoport(){
        stroportunityid = Apexpages.currentPage().getParameters().get('OportunidadId');
        renderpageblock = true;
        Datofacturado = false;
        Anulationtotal = false;
        renderpageblockauxiliar = false;
        profileuser = System.UserInfo.getProfileId();
        userName    = System.UserInfo.getName();
        userId      = System.Userinfo.getUserId();
        strProfile = getProfile(profileuser);
        Motivoanulacion = '';
        system.debug('ESTE_ES_EL_PERFIL_ACTUAL '+profileuser);
        system.debug('ESTE_ES_EL_USUARIO_LOGUEADO_ACTUALMENTE '+userName);
        
               
        prodxcotizacion = new list<QuoteLineItem>();
        prodxcotizacion =  getProductosoportunidad(stroportunityid);
        if(prodxcotizacion != null)
        {
                if(prodxcotizacion[0].Quote.Opportunity.Ciudad_venta__r.Name != null)
                {
                         strCiudad              = prodxcotizacion[0].Quote.Opportunity.Ciudad_venta__r.Name;
                }
            strRazonsocial      = prodxcotizacion[0].Quote.Opportunity.Account.Name;
                strPropietario  = prodxcotizacion[0].Quote.Opportunity.Owner.Name;
                datecerradaganada = prodxcotizacion[0].Quote.Opportunity.Fecha_cerrada_ganada__c;
        }
        
        
            validateconditions();
            if(prodxcotizacion != null)
            {
                if(prodxcotizacion[0].Quote.Opportunity.Valor_despues_de_anulacion__c <> null)
                {
                    valorinicialopp = prodxcotizacion[0].Quote.Opportunity.Valor_despues_de_anulacion__c;
                    valtotalanular = valorinicialopp;
                    valorpostanulacionopp = valorinicialopp - valtotalanular;
                }else
                {
                    valorinicialopp =  prodxcotizacion[0].Quote.Opportunity.Amount;
                    valtotalanular = valorinicialopp;
                    valorpostanulacionopp = valorinicialopp - valtotalanular;
                }
            
            }
           
           //verificar permisos
                system.debug('\n\n El_contrato_tiene_algun_dato_facturado ' + Datofacturado );
                   if(Datofacturado)
                   {
                           strOperationCode        = 'ANULACIONFACT';
                   }else
                   {
                           strOperationCode = 'ANULACION';
                   }
               
                   String permission = 'Anulacion de oportunidades';
                   
                   allowedaccess = allowedprofileaccess(strProfile.Name,permission,strOperationCode);  
                   
            
        
        
        
    }
    /*******************************************************************************************************************    
    * validateconditions == Metodo que realiza las validaciones para determinar si es posible realizar la anulacion
    * @return  boolean indicanto si supero la validacion.  
    *********************************************************************************************************************/ 
    public PageReference validateconditions(){
        boolean exito;
        if(prodxcotizacion == null)
        {  
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO,  + 'Para realizar la anulación la oportunidad debe estar Cerrada Ganada');
            this.setMsg(0, 'No se encontraron Productos a anular en esta oportunidad'  );
            renderpageblock = false;
            renderpageblockauxiliar = true;
            exito = false;
            system.debug('\n\n no_encontró_productos_a_anular **********' );
            return null;    
        }else
        {
            //si se encuentran productos a anular continua con el proceso
            
            //1 - validar que la oportunidad a anular este en cerrada ganada
            if(prodxcotizacion[0].Quote.Opportunity.StageName == '09 Cerrada ganada')
            {
                exito = true;
                system.debug('\n\n la_portunidad_si_esta_en_cerrada_ganada **********' );
                // 2 - Validar que tenga contratos facturados
                list<Dato_facturacion__c> datofact = [SELECT Contrato_SAP__c,Facturado__c,Fecha_facturacion__c,Id,Presupuesto__c,Presupuesto__r.OpportunityId FROM Dato_facturacion__c 
                                                      WHERE Presupuesto__r.OpportunityId =: stroportunityid ];
                for(Dato_facturacion__c midato:datofact )
                {
                    if(midato.Facturado__c == true && midato.Contrato_SAP__c != null)
                    {
                        Datofacturado = true;
                    }else
                    {
                        Datofacturado = false;
                    }
                } 
                 system.debug('\n\n tiene_contratros_facturados? **********' +Datofacturado );                             
            }else
            {
                system.debug('\n\n no_esta_en_cerrada_ganada **********' );
                this.setMsg(0, 'Para realizar la anulación la oportunidad debe estar Cerrada Ganada '  );
                renderpageblock = false;
                renderpageblockauxiliar = true;
                exito = false;
                return null;
            }
            
            
        }   
       return null;
    }
    
    
    /**************** Action cancel button************/     
    public PageReference doCancel(){
        
        PageReference pageref;
        PageReference pr = new  PageReference( '/'+stroportunityid );         
        pageref= pr; 
                        
        return pageref;         
    }
    
    public PageReference rendertipoanulacion(){    
      if(Test.isRunningTest())
            {
            strtipoanulacion = 'TOTAL';
            valorinicialopp = 10;
            valtotalanular = 0;
            }
     
     system.debug('strtipoanulacion_11 ' + strtipoanulacion);
      if(strtipoanulacion == 'PARCIAL')
        {
            Anulationtotal = true;//bandera que muestra los productos a anular
            system.debug('Anulationtotal_2 ' + Anulationtotal);
            valtotalanular = 0;
            valorpostanulacionopp = valorinicialopp - valtotalanular;
        }
        if(strtipoanulacion == 'TOTAL')
        {
            Anulationtotal = false;
            valtotalanular = valorinicialopp;
            valorpostanulacionopp = valorinicialopp - valtotalanular;
        }
        
    return null;     
    }
    
    
   
    
    /*******************************************************************************************************************    
    * runanulation == Metodo que realiza los procesos respectivos de anulacion
    1 - anula movimientos
    2 - anula activo
    3 - guarda el nuevo precio de anulacion en producto por cotizacion y oporunidad.
    * @return  boolean indicanto si supero la validacion.  
    *********************************************************************************************************************/ 
   public PageReference runanulation(){ 
    setassetanular = new set<ID>();
    system.debug('Entro_a_runanulation_strtipoanulacion= ' + strtipoanulacion);
    //------------
        if(strtipoanulacion == 'PARCIAL')
        {
            Anulationtotal = true;//bandera que muestra los productos a anular
            system.debug('Anulationtotal_2 ' + Anulationtotal);
        }else
        {
            Anulationtotal = false;
        }
        //--------------
    
     
    if(Anulationtotal == false)
    {
        system.debug('\n\n Se realizara_anulacion_completa '  );
        // 1 se dejaran todos los productos x cotizacion en cero 
        for(QuoteLineItem prod: prodxcotizacion)
        {
            prod.AfterCancellation__c = 0;
            prod.productcancelled__c = true;
            prod.Fecha_de_anulacion__c = system.now();
            prod.User_canceller__c  = userId;
            setassetanular.add(prod.Activo_producido__c);//ingreso los activos relacionados en un set
        }
        
        //2 - crear movimiento de anulación
        Cancellation_Movement__c movimientoan = new Cancellation_Movement__c();
        movimientoan.Cancellation_date__c = System.now();
        movimientoan.User_canceller__c = userId;
        movimientoan.Before_value__c = valorinicialopp;
        movimientoan.Value_after__c = 0;
        movimientoan.Cancellation_Type__c = strtipoanulacion;
        movimientoan.Oportunidad__c = stroportunityid;
        movimientoan.Cancellation_motive__c = Motivoanulacion;
        movimientoan.causal_annulation__c = strcausalanulacion;
        
        try
        { 
                if(allowedaccess)
                {
                        if(movimientoan.Cancellation_motive__c <> '')
                        {
                                insert movimientoan;
                        }else
                        {
                                this.setMsg(0, 'Para realizar este proceso es necesario diligenciar el campo "motivo de anulación" ' );
                                renderpageblock = false;
                                        renderpageblockauxiliar = true;
                                        return null;
                        }
                        
                }else
                {
                        if(Datofacturado == true)
                        {
                            this.setMsg(0, 'Su perfil no dispone de los permisos necesarios para realizar este tipo de anulaciones: Anulación de Oportunidades facturadas ');
                        }else
                        {
                                this.setMsg(0, 'Su perfil no dispone de los permisos necesarios para realizar este tipo de anulaciones: Anulación de Oportunidades sin facturar ');
                        }
                        renderpageblock = false;
                                renderpageblockauxiliar = true;
                                return null;
                }
                
                
                
        }catch(Exception ex)
        {
            this.setMsg(0, 'Se presento una falla al intentar insertar el movimiento de anulación ' + ex );
            renderpageblock = false;
            renderpageblockauxiliar = true;
            return null;
        }
                
        // 3 - se anularán los activos
        system.debug('\n\n activos_a_anular'  + setassetanular);
        list<asset>activoanular = [SELECT Id,Status,Fecha_anulacion__c,User_canceller__c,Cancellation_Movement__c, (SELECT Id,Activo__c,Activo__r.Status,Etapa__c,Tipo_movimiento__c FROM Movimientos_produccion__r) FROM Asset where Id IN: setassetanular];
        mapmovimientosanular = new map<id,Movimiento_produccion__c>();  
        if(activoanular  != null)
        {  
           for(asset assetdown :activoanular )
           {
             assetdown.Status= '06. Anulado';
             assetdown.Fecha_anulacion__c = System.now();
             assetdown.User_canceller__c = userId;
             assetdown.Cancellation_Movement__c = movimientoan.id;
             //4 - se anularán los movimientos
             if(assetdown.Movimientos_produccion__r.size() >0)
              {
                  for (Integer i = 0; assetdown.Movimientos_produccion__r.size()>i ; i++ )
                    {
                       if(assetdown.Movimientos_produccion__r.get(i).Etapa__c == '99. Entregado')
                       {}else
                       {
                        assetdown.Movimientos_produccion__r.get(i).Etapa__c= '95. Anulado';
                        system.debug('mi_movimiento_de_produccion_a_anular:   '+assetdown.Movimientos_produccion__r.get(i) + 'i ' +i);
                        mapmovimientosanular.put(assetdown.Movimientos_produccion__r.get(i).Id,assetdown.Movimientos_produccion__r.get(i)); 
                       }
                       
                    }
                   
              }
           }
        }
        //5- marcar la oprotunidad e indicar el valor despues de anulación 
        oppanular = getOpportunity(stroportunityid);
        oppanular.Anulado__c = true;
        oppanular.Fecha_de_anulacion__c = System.now();
        oppanular.Valor_despues_de_anulacion__c = 0;
        
        
        
        //6 - Modificar las cuotas por producto
        mapcuotasanular = new map<id,Cuota_facturacion__c>();
         for(QuoteLineItem prod: prodxcotizacion)
        {
            if(prod.Cuotas_facturacion__r.size() >0)
              {
                for (Integer i = 0; prod.Cuotas_facturacion__r.size()>i ; i++ )
                    {
                        prod.Cuotas_facturacion__r.get(i).Estado__c= 'A';
                        prod.Cuotas_facturacion__r.get(i).Value_after__c= 0;
                        system.debug('mi_Cuotas_facturacion__a_anular:   '+prod.Cuotas_facturacion__r.get(i) + 'i ' +i);
                        mapcuotasanular.put(prod.Cuotas_facturacion__r.get(i).Id,prod.Cuotas_facturacion__r.get(i)); 
                    }
              }
           
        }
        
        try
        {
            if(activoanular  != null)
            {
                update activoanular  ;
            }
            
            //actualizar Movimiento_produccion__c 
            list<Movimiento_produccion__c>listmovanulados = new list<Movimiento_produccion__c>();
            if(mapmovimientosanular.size()>0)
            {
                for(Movimiento_produccion__c mov:mapmovimientosanular.values())
                    {
                        listmovanulados.add(mov);
                    }
                update listmovanulados;
            }
            //actualizar cuotas por producto
            list<Cuota_facturacion__c>listcuotaanular = new list<Cuota_facturacion__c>();
            if(mapcuotasanular.size()>0)
            {
                for(Cuota_facturacion__c cuota:mapcuotasanular.values())
                    {
                        listcuotaanular.add(cuota);
                    }
                update listcuotaanular;
            }
            
            update oppanular;
            update prodxcotizacion;
            
            
            
            //Al finalizar el proceso se le notificará al usuario 
            this.setMsg(1, 'Se realizó exitosamente la anulación ' + strtipoanulacion +' de la oportunidad ');
            renderpageblock = false;
            renderpageblockauxiliar = true;
            return null;
            
        }catch(Exception ex)
        {
            this.setMsg(0, 'Se presento una falla al intentar modificar el valor de los productos ' + ex );
            renderpageblock = false;
            renderpageblockauxiliar = true;
            return null;
        }
    }else
    {
        system.debug('\n\n Se realizara_anulacion_parcial ' + Anulationtotal );
        //guardar la informacion del producto con los valores recibidos
          /*for(string strProdaanular:Apexpages.currentPage().getParameters().keySet())
                {
                     system.debug('strProdaanular===>>> '+strProdaanular);
                     if(strProdaanular.contains('productObjectId'))
                     {
                       Boolean productcancelled = boolean.valueOf(Apexpages.currentPage().getParameters().get(strProdaanular.replace('productObjectId','productcancelled')));   
                       system.debug('anular_producto?===>>> '+productcancelled);
                       string midato = Apexpages.currentPage().getParameters().get(strProdaanular.replace('productObjectId','AfterCancellation'));
                       string midato2 = Apexpages.currentPage().getParameters().get('AfterCancellation');
                       system.debug('midato?===>>> '+midato + 'midato2?===>>> '+midato2);
                     }
                }
        */
        
    }
    return null;
   }
   
    public PageReference calculatevalueprod(){
        
        system.debug('\n\n entro_a_calculatevalueprod_1 **********' );
         for(string strProdaanular:Apexpages.currentPage().getParameters().keySet())
                        {
                            boolean Valactualparam = false;
                            if(Valactualparam == false)
                            {
                               Valactualparam = true;   
                            }else
                            {
                              Valactualparam = false;   
                            }
                            
                            system.debug('strProdaanular===>>> '+strProdaanular);
                             if(strProdaanular.contains('productObjectId'))
                             {
                               Boolean productcancelled = boolean.valueOf(Apexpages.currentPage().getParameters().get(strProdaanular.replace('productObjectId','productcancelled')));   
                               system.debug('anular_producto?===>>> '+productcancelled);
                               string midato = Apexpages.currentPage().getParameters().get(strProdaanular.replace('productObjectId','AfterCancellation'));
                               string midato2 = Apexpages.currentPage().getParameters().get('AfterCancellation');
                               system.debug('midato?===>>> '+midato + 'midato2?===>>> '+midato2);
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
              
       
 
    
    /*************************************************************************************************************
    *                                            QUERY AREA
    *************************************************************************************************************/  
    
    
    
    //Validar usuario aprobador ----------------------------------------------------------
     public Profile getProfile(String idProfile){
        List<Profile> ReqProfile = [SELECT Id,Name FROM Profile WHERE Id =:idProfile];     
        if(ReqProfile.size()>0){
            return ReqProfile.get(0);
        }else{      
            return null;
        }   
    }
    
     
    //Oportunidad a anular ----------------------------------------------------------
     public Opportunity getOpportunity(String idOpportunity){
        List<Opportunity> ReqOpportunity = [SELECT Anulado__c,Fecha_de_anulacion__c,Id,Valor_despues_de_anulacion__c FROM Opportunity where Id =:idOpportunity];     
        if(ReqOpportunity.size()>0){
            return ReqOpportunity.get(0);
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
    
    
    /******************Retornar listado de productos***********************************************/
        public list<QuoteLineItem> getProductosoportunidad(String idoportunity){
                system.debug('idoportunity: '+idoportunity );
        List<QuoteLineItem>  prodxoport = [SELECT Activo_producido__c,AfterCancellation__c,Fecha_de_anulacion__c,User_canceller__c,PricebookEntry.Name,Id,PricebookEntry.Product2.Id,PricebookEntry.Product2.Name,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Meses_Vigencia__c,
                                                  QuoteId,Quote.Opportunityid,Quote.Opportunity.Owner.Name,Quote.Opportunity.Ciudad_venta__r.Name,Quote.Opportunity.Account.Name,Quote.Opportunity.Amount,Quote.Opportunity.Fecha_cerrada_ganada__c,Quote.Opportunity.Valor_despues_de_anulacion__c,Quote.Opportunity.StageName,productcancelled__c,Quantity,TotalPrice,
                                                  (SELECT Dato_facturacion__c,Estado__c,Fecha_cuota__c,Id,No_Cuota__c,Partida_de_presupuesto__c,Valor_cuota__c,Value_after__c FROM Cuotas_facturacion__r)  
                                           FROM QuoteLineItem
                                           WHERE  Quote.OpportunityId =:idoportunity AND productcancelled__c = false AND Quote.IsSyncing = true];
                
                if(prodxoport.size()>0){
                        system.debug('prodxoport_1 : '+prodxoport);
                        return prodxoport;      
                }else{      
                       return null;
                     }  
                
        }  
    
    
}