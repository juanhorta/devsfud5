/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Enero 30 de 2013
*  Decripción:          Controlador de la pagina PG008_SendCreditCheck que genera el chequeo de crédito
*  @version:            1.0
*  @version:            1.1  26-02-2014 JAAR Se realiza modificacion para permitir que sea posible laconsulta del chequeo con o sin datos
                                                                                     de facturtación
*  @version:            2.0  26-06-2014 JAAR Se agrega método SumacontroldeInventario el cual valida si tiene productos de venta limitada para sumar en el control de inventario respectivo 
*  @version:            2.0  07-07-2014 JAAR Se agrega validacion al momento de enviar a aprobacion una oportunidad para verificar que exista el  Autorizante y Contacto Encargado Web donde la Unidad de Negocio sea Soluciones digitales 
* ===================================================================================================================================
**/

public with sharing class CTR008_SendCreditCheck {
    
    public String Codigocuenta { get; set; }
    public String Namecuenta { get; set; }
    public String Clienteunico { get; set; }
    public String identification{ get; set; }
    public Boolean billingdata{ get; set; }
    public Boolean isok{ get; set; }
    public Boolean invoked { get; set; }                //JDHC 19-03-2014 variable para controlar si el servicio es invocado
    public Boolean BlnMessage{ get; set; }
    public String StrMessage{ get; set; }
    public String IdOportunity { get; set; }
    public Quote cotizacion{ get; set; }
    public Opportunity oppcheck{ get; set; }
     public Account opAccount{ get; set; }              //JDHC 19-03-2014
    public list<Requestfinancial__c>Reqfinancial{ get; set; }
    public list<CL008_Sap_ConsCupoCredit_ObjectsSF.DescripcionMsgRs> Msgchequeo{ get; set; }
    public Switch_ServicioMasterdata__c OFFSWMasterdata { get; set; } //JAAR controla que el llamado al SW masterdata este prendido o apagado
    public Boolean ExitoMasterdata{ get; set; }//valida que el sw de masterdata retorno un cliente unico
    public Boolean Vtalimitadaok{ get; set; }//valida si todos los productos (seccion, ciudad y tipo de inventario ) estan disponibles 
    public String  strbillingdata{ 
        get{
             if(billingdata)
                 return 'COMPLETA CON DATOS DE FACTURACION'; 
             else
                         return 'INCOMPLETA SIN DATOS DE FACTURACION'; 
           }  
         set; }
    public String strTittlePage {get;set;} //variable que contiene el título de la página visualforce
    public Boolean requestFromsimulation{get;set;} //booleano para indicar si es una simulacion de la cotizacion
    public Boolean requestcupo{get;set;} //JAAR 21-04-2014 booleano para indicar si la consulta proviene de una cuenta o lead
    public String strAccion {get;set;}      //cotizazcion o oportunidad
    public ApexPages.Standardcontroller controller;
    public List<CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness> listCreditWorthiness {get;set;}
    public List<CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness> resultDetalle{get;set;}
    public List<CL008_Sap_ConsCupoCredit_ObjectsSF.Producto> detallecotizacion{get;set;}//intento 
    public String message {get; set;}
    public Boolean nonconformitiesrequest { get; set; }
    public boolean ChequeoApagado{get;set;}
    public Boolean display { get; set; }
    public String idOperation {get; set;}
    public String severity {get; set;}    
    public String OpportunityId {get;set;}
    public String CotizacionId {get;set;}
    public String OperationCode {get;set;}
    public String ProposalDocumentId {get;set;}
    public String requestFrom{get;set;}
    public String accion{get;set;}
    public String nameCotizacion{get;set;}
    public boolean completeQuote{get;set;}
    public boolean CU{get;set;}
    public boolean completeCU{get;set;}
    public Boolean actualizaID { get; set; } 
    public String  Nameident { get; set; } 
    public String selection {get;set;}
    public CL009_SAPlogicCreditCheck scmc;
    public map<ID,CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos> mapRsChequearCred {get;set;}
    public List<CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness> listResult {get;set;}
    //public SAP_CreditManagementClient scmc;
    Quote ValCotizacion;
    Account Valcuenta;
    Lead Vallead;
    

 public CTR008_SendCreditCheck(){
               this.billingdata  = false; //JAAR validacionurgente
              Utils_Chequeocredito__c Utilschequeo = Utils_Chequeocredito__c.getAll().get('Colombia');
              OFFSWMasterdata = Switch_ServicioMasterdata__c.getAll().get('SWMasterdata desde Chequeo');
              nonconformitiesrequest = Utilschequeo.Validar_no_conformidades__c;
              ChequeoApagado             = Utilschequeo.Chequeo_Apagado__c;
              system.debug('Validar_No_conformidades?  '+ nonconformitiesrequest + 'ChequeoApagado ' + ChequeoApagado); 
              
              isok = true;
              invoked = true;           //JHDC 19-03-2014
             BlnMessage = false;
        if(Apexpages.currentPage().getParameters().get('OperationCode')!=null && Apexpages.currentPage().getParameters().get('OperationCode')=='CHEQUEO'){
             system.debug('\n\n Apexpages.currentPage_getParameters_requestFrom'+ Apexpages.currentPage().getParameters().get('requestFrom'));  
            if(Apexpages.currentPage().getParameters().get('requestFrom')== 'COTIZACION')
            {
              strTittlePage='Simulación de Chequeo de crédito';
              requestFromsimulation = true;
              requestcupo = false;
            }
        else{
              strTittlePage='Chequeo de crédito';
              requestFromsimulation = false;
              requestcupo = false;
            }
            
        }else if(Apexpages.currentPage().getParameters().get('OperationCode')!=null && Apexpages.currentPage().getParameters().get('OperationCode')=='CUPO')
        {
                system.debug('\n\n request_desde_la_cuenta'); 
                if(Apexpages.currentPage().getParameters().get('requestFrom')== 'CUENTA' || Apexpages.currentPage().getParameters().get('requestFrom')== 'LEAD')
            {
            strTittlePage='Consulta de Cupo de Crédito';
            requestFromsimulation = true;
            requestcupo = true; //JAAR 21-04-2014
            }
                
        }    
        Map<String, String> mapValuesByKeyUrl = ApexPages.currentPage().getParameters();
        if( mapValuesByKeyUrl.containsKey( 'accion' ) )
           strAccion = mapValuesByKeyUrl.get( 'accion' );
 } 
//-------------------------------------------------------------------------------------------------------------------------------
public PageReference validarCU()
    {
        CU = false;
        actualizaID = false;
        system.debug('\n\n >>>>----entro_a_validarCU  ');
        OperationCode    = Apexpages.currentPage().getParameters().get('OperationCode');
        requestFrom      = Apexpages.currentPage().getParameters().get('requestFrom');
        accion           = Apexpages.currentPage().getParameters().get('accion');
        system.debug('OperationCode '+ OperationCode + ' requestFrom '+requestFrom+ ' accion '+accion);     
        //this.controller  = controller;
        if(requestFromsimulation)
                {
                    if(requestcupo == false)
                    {
                            CotizacionId     = Apexpages.currentPage().getParameters().get('PresupuestoId');
                    }else
                    {
                        if(requestFrom == 'CUENTA')
                        {
                            //JAAR 21-04-2014 trae la inf de la cuenta para llamar al servicio
                            CotizacionId     = Apexpages.currentPage().getParameters().get('CuentaId');
                        }else if(requestFrom == 'LEAD')
                        {
                            //la variable CotizacionId obtiene la info del lead 
                            CotizacionId     = Apexpages.currentPage().getParameters().get('LeadId');
                        }     
                            
                    }
                }
        system.debug('objeto_a_consultar '+ CotizacionId + ' requestFrom '+requestFrom);          
        
        
        //if(requestcupo == false)*******JAAR se comentarea para realizar la consulta de cupo desde la oportunidad******
            //{
                //JAAR 29-04*-2014 llamado al servicio de consulta de cliente unico para la oportunidad y la cotizacion
                
                
                
                //agregar las validaciones de la oportunidad y cotizacion para cliente unico
                //123
            //}else
            //{ 
              /*****************************Consulta de cupo realizada desde el Lead ************************************************
              *******************************************************************************************************************************/
              if(requestFrom == 'CUENTA')
              {
                this.Valcuenta =  this.getAccountById(CotizacionId);
              }else if(requestFrom == 'LEAD')
              {
                 system.debug('\n\n llamado_desde_el_lead');
                 this.Vallead = this.getLeadById(CotizacionId);
               
                    if(Test.isRunningTest())
                    {
                        OFFSWMasterdata.OFF_SWMasterdata__c = false;
                    }
                    
                    if(OFFSWMasterdata.OFF_SWMasterdata__c == false) 
                     {
                        try
                       {
                         //validar que tenga el nit correcto ---------------------------------------------------------
                          if(Vallead.Nit__c <>null)
                            {
                                for (Integer x=0;x<Vallead.Nit__c.length();x++)
                                 {
                                    //JAAR recorrer el nit y validar que no tenga el digito de verificacion guion 
                                    System.debug('numero '+ x + ' Caracter ' + Vallead.Nit__c.substring(x,x+1));
                                    if(Vallead.Nit__c.substring(x,x+1) =='-')
                                     {
                                        system.debug('lead tiene guion '+Vallead.Nit__c + ' se substraera '+ Vallead.Nit__c.substring(0,x));
                                        String newlead = Vallead.Nit__c.substring(0,x);
                                        Vallead.Nit__c = newlead;
                                        //se identifico que muchas cuentas traen la palabra NULL en lugar de la identificcacion;
                                     }else if(Vallead.Nit__c.substring(x,x+1)=='N')
                                     {
                                        system.debug('lead_contiene_tiene_letras'+Vallead.Nit__c );
                                        Vallead.Nit__c                  =null;
                                        Vallead.Status_Masterdata__c    = 'Número de identificación no válido';
                                        update Vallead;
                                     }
                                 }
                            
                             //-----Identificar el tipo de identificación si no tiene---------------------------------------
                             if(Vallead.Tipo_identificacion__c <>null)
                             {
                                actualizaID = false;
                                system.debug('Nit_ya_contiene_tipo_de_id '+Vallead.Nit__c + ' actualizaID ' + actualizaID );
                             }else
                             {
                               list<Tipo_identificacion__c> tipoid =[SELECT Id,Name FROM Tipo_identificacion__c ];
                               map<String,String>mapidentificacion = new map<String,String>();
                               for(Tipo_identificacion__c tide:tipoid)
                               {
                                 mapidentificacion.put(tide.Name,tide.Id);
                               }
                               
                               //si cumple las caracterisiticas de un NIT se le busca el id salesforce del tipo
                               if(Vallead.Nit__c <>null)
                               {
                                 if(Double.valueof(Vallead.Nit__c) >= 600000000 && Double.valueof(Vallead.Nit__c)  <= 999999999 )
                                      {
                                         Vallead.Tipo_identificacion__c = mapidentificacion.get('NIT');
                                          system.debug('/////////////////////////////////////////////////mi lead cambio nit' + Vallead);
                                          
                                      }else If((Double.valueof(Vallead.Nit__c)<= 99999999 && Double.valueof(Vallead.Nit__c)>= 1) || Double.valueof(Vallead.Nit__c)>= 1000000000 )
                                      {
                                              Vallead.Tipo_identificacion__c = mapidentificacion.get('CC');
                                          system.debug('**************************************************mi lead cambio CC' + Vallead);
                                          
                                      }else
                                      {
                                         system.debug('lead fuera de los rangos =======' + Vallead);  
                                      }
                               }
                                   
                             }
                           //-----------------------------------------------------------------------------------------------  
                         }
                         CAllOUT002_MD_GetClienteUnico SwMasterdata = new CAllOUT002_MD_GetClienteUnico();
                         SwMasterdata.invoke(SwMasterdata.fnWrapperIdentificationInfo(Vallead.Nit__c ,Vallead.Tipo_identificacion__r.Name,'2'));
                         
                         
                         
                         if(SwMasterdata.uniqueCustomer <> null)
                           {
                              if(SwMasterdata.uniqueCustomer <> 0)
                             {
                                Vallead.Codigo_cliente_unico__c         = SwMasterdata.uniqueCustomer;
                                Vallead.Status_Masterdata__c            = 'Cliente encontrado en Masterdata';
                                update Vallead;
                                CU = true;
                                ExitoMasterdata = true;  
                                system.debug('\n\n Codigo_cliente_unico__c_del_lead_postSW ' + Vallead.Codigo_cliente_unico__c );
                             }else
                             {
                                Vallead.Codigo_cliente_unico__c         = null;
                                Vallead.Status_Masterdata__c            = 'Cliente no existe en Masterdata';
                                //se limpian los campos del lead ya que el cliente unico actual no retorno información
                                Vallead.Fecha_Validez_limite__c         = null;
                                Vallead.Cliente_Bloqueado__c            = false;
                                Vallead.Tipo_de_Riesgo__c               = '';
                                Vallead.Cupo_Asignado__c                = null;
                                Vallead.Fecha_Validez_limite__c         = null;
                                Vallead.Saldo_Disponible__c             = null;
                                Vallead.Fecha_sincronizacion_SAP__c     = system.now(); 
                                
                                update Vallead;
                                ExitoMasterdata = false;
                                CU = false;
                                this.billingdata  = false;
                                this.BlnMessage   = true;
                                isok = false;
                                this.setMsg(1, 'Masterdata no encontro cliente unico para la identificación relacionada a este Lead '  );
                                this.billingdata  = false;
                                return null;
                             }  
                           }
                       }catch(Exception ex)
                       {
                         system.debug('\n\n Se_presento_error_al_consultar_a_masterdata desde el lead '+ ex);
                         ExitoMasterdata = false;
                         system.debug('\n\n La_llamada_al_SWMasterdata__c_fallo  '+ ex  );
                         CU = false;
                         this.billingdata  = false;
                       }
                     }
                 
              }else if(requestFrom == 'OPORTUNIDAD')
              {
                IdOportunity     = Apexpages.currentPage().getParameters().get('PresupuestoId');
                Opportunity oppaccount = [SELECT AccountId,Id FROM Opportunity WHERE Id=: IdOportunity];
                this.Valcuenta =  this.getAccountById(oppaccount.AccountId);
              }else if(requestFrom == 'COTIZACION')
              {
                CotizacionId     = Apexpages.currentPage().getParameters().get('PresupuestoId');
                Quote cotization =[SELECT Id,Opportunity.AccountId FROM Quote WHERE Id =:CotizacionId];
                this.Valcuenta =  this.getAccountById(cotization.Opportunity.AccountId);
              }
             
             if(requestFrom == 'LEAD')
             {              
             }else
             {
                /*****************************Consulta de cupo realizada desde la cuenta o cotizacion o oportunidad  ************************************************
                *******************************************************************************************************************************/
               //JAAR 19-05-2014 siempre se consulta el servicio para que traiga la informacion reciente de MD por eso se depreca la validacion 
               /*  if(Valcuenta.Codigo_cliente_unico__c != null)
                  {
                    system.debug('\n\n tiene_cod_cliente_unico');
                    CU = true;
                  }else
                  {
                 */   
                    if(OFFSWMasterdata.OFF_SWMasterdata__c == false) 
                    {
                        try
                        {
                           //validar que la cuenta tenga el nit correcto ---------------------------------------------------------
                           if(Valcuenta.Numero_identificacion__c <>null)
                            {
                                for (Integer x=0;x<Valcuenta.Numero_identificacion__c.length();x++)
                                 {
                                    //JAAR recorrer el nit y validar que no tenga el digito de verificacion guion 
                                    System.debug('numero '+ x + ' Caracter ' + Valcuenta.Numero_identificacion__c.substring(x,x+1));
                                    if(Valcuenta.Numero_identificacion__c.substring(x,x+1) =='-')
                                     {
                                        system.debug('cuenta tiene guion '+Valcuenta.Numero_identificacion__c + ' se substraera '+ Valcuenta.Numero_identificacion__c.substring(0,x));
                                        String newcuenta = Valcuenta.Numero_identificacion__c.substring(0,x);
                                        Valcuenta.Numero_identificacion__c = newcuenta;
                                        //se identifico que algunas cuentas traen la palabra NULL en lugar de la identificcacion;
                                     }else if(Valcuenta.Numero_identificacion__c.substring(x,x+1)=='N')
                                     {
                                        system.debug('cuenta_contiene_tiene_letras'+Valcuenta.Numero_identificacion__c );
                                        Valcuenta.Numero_identificacion__c                  =null;
                                        update Valcuenta;
                                     }
                                 }
                            
                             //-----Identificar el tipo de identificación si no tiene---------------------------------------
                             if(Valcuenta.Tipo_identificacion__c <>null)
                             {
                                system.debug('Nit_ya_contiene_tipo_de_id '+Valcuenta.Numero_identificacion__c + ' actualizaID '+actualizaID );
                             }else
                             {
                               list<Tipo_identificacion__c> tipoid =[SELECT Id,Name FROM Tipo_identificacion__c ];
                               map<String,String>mapidentificacion = new map<String,String>();
                               for(Tipo_identificacion__c tide:tipoid)
                               {
                                 mapidentificacion.put(tide.Name,tide.Id);
                               }
                               system.debug('mi_cuenta_ant ' + Valcuenta);
                               //si cumple las caracterisiticas de un NIT se le busca el id salesforce del tipo
                               if(Valcuenta.Numero_identificacion__c <>null)
                               {
                                  
                                 if(Double.valueof(Valcuenta.Numero_identificacion__c) >= 600000000 && Double.valueof(Valcuenta.Numero_identificacion__c)  <= 999999999 )
                                      {
                                          Valcuenta.Tipo_identificacion__c = mapidentificacion.get('NIT');
                                          system.debug('rastreo_01 ' + Valcuenta.Tipo_identificacion__c );
                                          //Valcuenta.Tipo_identificacion__r.Name= 'NIT';
                                          actualizaID = true;
                                          Nameident  = 'NIT';
                                          system.debug('/////////////////////////////////////////////////mi_CUENTA_cambio nit ' + Valcuenta);
                                      }else If((Double.valueof(Valcuenta.Numero_identificacion__c)<= 99999999 && Double.valueof(Valcuenta.Numero_identificacion__c)>= 1) || Double.valueof(Valcuenta.Numero_identificacion__c)>= 1000000000 )
                                      {
                                             system.debug('<= 99999999_es_cedula =======' + Valcuenta.Numero_identificacion__c);   
                                              Valcuenta.Tipo_identificacion__c = mapidentificacion.get('CC');
                                              //Valcuenta.Tipo_identificacion__r.Name= 'CC';
                                              actualizaID = true;
                                              Nameident  = 'CC';
                                          system.debug('\n\n mi_cuenta_cambio_CC ' + Valcuenta);
                                         
                                      }else
                                      {
                                         system.debug('Cuenta_fuera_de_los_rangos =======' + Valcuenta);  
                                      }
                               }
                                   
                             }
                           //-----------------------------------------------------------------------------------------------  
                         }
                            
                            
                           system.debug('\n\n actualizaID_antes_del_llamado_al_SW ' + actualizaID );
                            
                            CAllOUT002_MD_GetClienteUnico SwMasterdata = new CAllOUT002_MD_GetClienteUnico();
                            if(actualizaID == true)
                             {
                                
                                system.debug('\n\n CONSULTA_SERVICIO_actualizaID ' + Nameident );
                                //LLAMADO AL SW DE MASTERDATA SI EL SISTEMA MODIFICO EL TIPO DE IDENTIFICACION  
                                SwMasterdata.invoke(SwMasterdata.fnWrapperIdentificationInfo(Valcuenta.Numero_identificacion__c ,Nameident,'2'));
                             }else
                             {
                                system.debug('\n\n CONSULTA_SERVICIO_NORMAL ' + actualizaID );
                                //LLAMADO AL SW DE MASTERDATA   
                                 SwMasterdata.invoke(SwMasterdata.fnWrapperIdentificationInfo(Valcuenta.Numero_identificacion__c ,Valcuenta.Tipo_identificacion__r.Name,'2'));
                             }
                            
                            
                            
                            if(SwMasterdata.uniqueCustomer <> null)
                            {
                              if(SwMasterdata.uniqueCustomer <> 0)
                               {
                                system.debug('\n\n resultado_del_SW_de_masterdata' + SwMasterdata.uniqueCustomer);
                                //Si el servicio responde satisfactoriamente actualizamos el objeto Identificacion de salesforce
                                list<Identificaciones__c> IdentificationData = new list<Identificaciones__c>();
                                IdentificationData = [SELECT Cliente_unico__c,datesyncMasterdata__c,Direccion_facturacion__c,Email_Facturacion__c,Id,Name,Numero_identificacion__c,
                                                                              Pendiente_pago__c,Telefono_facturacion__c,Tipo_identificacion__c 
                                                                              FROM Identificaciones__c WHERE Cliente_unico__c =:SwMasterdata.uniqueCustomer];
                                 if(IdentificationData.size()>0)
                                    {
                                      system.debug('\n\n Registro_encontrado_en_identificaciones');
                                      Valcuenta.Identificacion__c                       = IdentificationData[0].Id;     
                                      Valcuenta.Codigo_cliente_unico__c                 = SwMasterdata.uniqueCustomer;
                                      update Valcuenta;
                                      //se actualizara la informacion de la identificacion  en cada consulta
                                        IdentificationData[0].datesyncMasterdata__c    = System.now();
                                        IdentificationData[0].Cliente_unico__c        = SwMasterdata.uniqueCustomer;
                                        
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
                                      //--------------------------------------------------------------------
                                      
                                      
                                      
                                      
                                      CU = true;                                                              
                                    }else
                                    {
                                        Valcuenta.Codigo_cliente_unico__c       = SwMasterdata.uniqueCustomer;
                                        Valcuenta.Requiere_Masterdata__c        = false;
                                        //1- Crear el objeto Identificaciones__c en salesforce con la informacion del servicio
                                        system.debug('\n\n Registro_no_existe_en_identificaciones');
                                        Identificaciones__c Insertidentification      = new Identificaciones__c();
                                        Insertidentification.datesyncMasterdata__c    = System.now();
                                        Insertidentification.Cliente_unico__c             = SwMasterdata.uniqueCustomer;
                                        Insertidentification.Numero_identificacion__c = Valcuenta.Numero_identificacion__c;
                                        Insertidentification.Tipo_identificacion__c   = Valcuenta.Tipo_identificacion__c;
                                        if(SwMasterdata.cityOriginId <> null)
                                        {
                                            Ciudad__c ciud = getCiudadBycod(SwMasterdata.cityOriginId);
                                            Insertidentification.Ciudad_facturacion__c    = ciud.Id;
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
                                        
                                        
                                        
                                        if(Valcuenta.Status_Masterdata__c <> null)
                                         {
                                                 Valcuenta.Status_Masterdata__c         = 'FINALIZADO';
                                         }
                                         
                                         insert Insertidentification;
                                         Valcuenta.Identificacion__c                              = Insertidentification.Id;
                                         update Valcuenta;
                                         CU = true;
                                    }
                                    ExitoMasterdata = true;     
                                    system.debug('\n\n Codigo_cliente_unico__c_de_la_cuenta_postSW ' + Valcuenta.Codigo_cliente_unico__c);
                                
                          
                              }else
                              {
                                    ExitoMasterdata = false;
                                    CU = false;
                                    this.billingdata  = false;
                                        this.BlnMessage   = true;
                                    isok = false;
                                    this.setMsg(1, 'Masterdata no encontro cliente unico para la identificación relacionada a esta cuenta '  );
                                    this.billingdata  = false;
                                    return null;
                              }
                           }
                        }catch(Exception ex)
                        {
                                ExitoMasterdata = false;
                                system.debug('\n\n La_llamada_al_SWMasterdata__c_fallo  '+ ex  );
                                CU = false;
                                this.billingdata  = false; 
                        }
                            
                    }
                
             
              // }
             }
             
            //------------------------------------------------------------------------------------------------------------------  
            system.debug('finaliza_la_validacion_de_cliente_unico_cotinua_con el proceso');
            //}3004
            return null;    
    }
    
    
    
public PageReference lanzarProceso()
    {
      system.debug('\n\n >>>>----strAccion    '+strAccion);   
          //if(requestFromsimulation) 
          //{
            //SIMULACION = COTIZACION
            system.debug('invoked::: '+invoked);
            this.controller  = controller;
            system.debug('\n\n >>>>----requestFromsimulation    '+requestFromsimulation + '>>>>----requestcupo   ' + requestcupo );   
            if(requestFromsimulation)
            {
                if(requestcupo == false)
                {
                        CotizacionId     = Apexpages.currentPage().getParameters().get('PresupuestoId');
                }else
                {
                        if(requestFrom == 'CUENTA')
                        {
                            //JAAR 21-04-2014 trae la inf de la cuenta para llamar al servicio
                            CotizacionId     = Apexpages.currentPage().getParameters().get('CuentaId');
                        }else if(requestFrom == 'LEAD')
                        {
                            //la variable CotizacionId obtiene la info del lead para realizar el llamado al servicio
                            CotizacionId     = Apexpages.currentPage().getParameters().get('LeadId');
                        } 
                }
                
            }else
            {
                IdOportunity     = Apexpages.currentPage().getParameters().get('PresupuestoId');
                oppcheck = getOpportunity(IdOportunity);
                //opAccount = [SELECT Id,Pendiente_pago__c from Account where Id =: oppcheck.AccountId];
                //system.debug('Idaccount: opaccount: ' + opAccount);
                system.debug('IdOportunity_12 '+ IdOportunity + oppcheck);
                if(oppcheck.SyncedQuoteId <> null)
                {
                  cotizacion = [SELECT IsSyncing,Id,OpportunityId,RecordTypeId,blocked_quote__c,(SELECT Blocked_BillingData__c,Id FROM Datos_facturacion__r)  FROM Quote WHERE IsSyncing = true AND OpportunityId =: IdOportunity]; 
                } else
                {
                                this.setMsg(2, 'No ha sincronizado ninguna cotización en esta oportunidad, por lo tanto no es posible continuar con el proceso ' );
                            this.billingdata  = false;
                            BlnMessage = true;
                                isok = false;
                            return null;
                }  
                
                CotizacionId = cotizacion.Id;
                if(oppcheck.CreditCheckCode__c <> null && (oppcheck.StageName == '06 Cerrada Entregada Fulfillment'||oppcheck.StageName == '05 Cerrada Entregada Facturación')  )
                {
                                 //gestiona aprbación de fulfillment
                                 
                                 this.BlnMessage = true;
                                 isok = false;
                                 this.billingdata  = false;
                                 this.setMsg(0, 'No es posible volver a ejecutar el chequeo de crédito, la oportunidad se encuentra en etapa: ' +oppcheck.StageName );
                             return null;
                }
            /* VERIFICACION DE NO CONFORMIDADES --------------------------------------------------------------------------------------------------------------------
             *JAAR 11-03-2014 Se realiza validacion para que no permita enviar aprovación si la oportunidad tiene asociada una no conformidad abierta o en proceso 
             *******************************************************************************************************************************************************/
                if(oppcheck.Estado_No_conformidad__c <>null) 
                {
                        //JAAR 20-03-2014 Se configura parametro desde donde se controla la obligatoriedad de la validacion de las no conformidades 
                        
                        if(nonconformitiesrequest <> null) 
                        {
                                if(nonconformitiesrequest == true)
                                {
                                        if(oppcheck.Estado_No_conformidad__c == 'EN PROCESO' || oppcheck.Estado_No_conformidad__c == 'ABIERTA')
                                                {
                                             this.billingdata  = false;
                                                 isok = false;
                                                 BlnMessage = true;
                                                 this.setMsg(0, 'No es posible enviar a aprobación si aun no ha cerrado la no conformidad por la que fue devuelta: '  );
                                             return null;
                                                }
                                }
                        }
                        
                }
                
                if(oppcheck.Estado_No_conformidad_Cartera__c <>null) 
                {
                        //JAAR 20-03-2014 Se configura parametro desde donde se controla la obligatoriedad de la validacion de las no conformidades 
                        if(nonconformitiesrequest <> null) 
                        {
                                if(nonconformitiesrequest == true)
                                {
                                        if(oppcheck.Estado_No_conformidad_Cartera__c  == 'EN PROCESO'||oppcheck.Estado_No_conformidad_Cartera__c  == 'ABIERTA')
                                                {
                                             this.billingdata  = false;
                                                 isok = false;
                                                 BlnMessage = true;
                                                 this.setMsg(0, 'No es posible enviar a aprobación si aun no ha cerrado la no conformidad por la que fue devuelta: '  );
                                             return null;
                                                }
                                }
                        }
                        
                }
            //JAAR 07-07-2014 realiza validacion al momento de enviar a aprobacion una oportunidad para verificar que exista el  Autorizante y Contacto Encargado Web donde la Unidad de Negocio sea Soluciones digitales    
            if(oppcheck.Unidad_de_Negocio__c == 'Soluciones digitales' )
            {
            	if(oppcheck.Autorizante__c != null && oppcheck.Contacto_Encargado_Web__c != null )  
	            {
	            	system.debug('Tiene_la informacion_correcta_ en Autorizante y Contacto Encargado Web');
	            }else
	            {
	            	 this.billingdata  = false;
			         isok = false;
			         BlnMessage = true;
			         this.setMsg(0, 'No es posible enviar a aprobación la oportunidad si aun no ha diligenciado los campos "Autorizante" y "Contacto Encargado Web" y su Unidad de Negocio es Soluciones digitales '  );
			     return null;
	            } 
            }
            
                
             /***********************VALIDACION DE VTAS VALOR CERO *******************************************************************************
            **JAAR 17-03-2014 Se realiza cambio para permitir que las oportunidades con valor cero no requieran paso por facturacion
            **
            ************************************************************************************************************************************/               
                if(oppcheck.Amount <>null) 
                {
                        if(oppcheck.Amount == 0)
                        {
                             //1 - Actualiza la marca de chequero de crédito de la oportunidad
                     oppcheck.IsCreditAnalysisRequired__c       =  false;
                     oppcheck.IsCreditExceptionAllowed__c       =  false;
                     
                         //Se iguala el  campo Fecha_cerrada_entregada_facturacion__c a Fecha_Entregada_Facturacion__c ya que pasa automaticamente a fulfillment 
                     oppcheck.Fecha_Entregada_Facturacion__c                    = system.now();
                     oppcheck.Fecha_cerrada_entregada_facturacion__c    = system.now();
                     oppcheck.Comentarios_fulfillment__c                                = '';
                     oppcheck.Comentarios_Cartera__c                                    = '';
                     //se limpian los campos de la gestion de fulfillment ya que iniciará nuevamente el flujo de aprobación
                     oppcheck.Responsable_fulfillmet__c                                 =null;
                     oppcheck.Semaforostatus__c                                                 =null;
                     oppcheck.Status_fulfillment__c                                             =null;
                         oppcheck.Comentarios_fulfillment__c                            ='';
                     oppcheck.Fecha_Entregada_Fulfillment__c                    =null;
                     oppcheck.Fecha_cerrada_fulfillment__c                              =null; 
                     oppcheck.Estado_No_conformidad__c                          =null;
                     oppcheck.Estado_No_conformidad_Cartera__c                  = null;
                             Requestfinancial__c checfin = new Requestfinancial__c();
                                //JAAR si el chequeo automatico fue aprobado ingresa directo a fulfillment
                         oppcheck.StageName                                     = '06 Cerrada Entregada Fulfillment';
                         oppcheck.Fecha_Entregada_Fulfillment__c        =system.now();
                         //JAAR no pasa por facturación la fecha de entrada y salida es la misma
                         oppcheck.Fecha_Entregada_Facturacion__c                                = system.now();
                                         oppcheck.Fecha_cerrada_entregada_facturacion__c                = System.now();
                                         checfin.Fecha_Entregada_Facturacion__c                         = system.now();
                                         checfin.Date_of_Approval__c                                            = system.now();
                                         oppcheck.automaticresult__c                    = 'APROBADO';
                         oppcheck.endcheckup__c                         = 'APROBADO';
                         oppcheck.Semaforostatus__c                     = 'Green';
                             oppcheck.CreditCheckCode__c                = 'VALOR CERO'; 
                             oppcheck.Comentarios_Cartera__c    = 'Oportunidad de valor cero aprobada automaticamente por el sistema';                  
                         //------CHEQUEO APROBADO---------------------------------------------------------
                         checfin.CreditCheckCode__c                     = 'VALOR CERO'; 
                     checfin.IsCreditAnalysisRequired__c        = false;
                     checfin.IsCreditExceptionAllowed__c        = false;
                     checfin.LastCreditCheck__c                 = system.now();
                     checfin.Idoportunity__c                            = IdOportunity;
                     checfin.Chequeo_vigente__c                         = true;
                     system.debug('relacion_quotes  '+oppcheck.Quotes);
                     checfin.Monto__c                                           = oppcheck.Quotes.get(0).GrandTotal;
                     checfin.Status_del_chequeo__c                      = 'APROBADO';
                     checfin.automaticresult__c                         = 'APROBADO';
                     checfin.User_approver__c                           = 'SISTEMA';
                     checfin.Tipo_de_solicitud__c                       = '';
                     checfin.Mensajes_Chequeo__c                        = 'Oportunidad de valor cero aprobada automaticamente por el sistema';  
                                             
                             Reqfinancial = getRequestfinancial(IdOportunity, checfin.CreditCheckCode__c );
                     if(Reqfinancial <> null)
                     {
                        for (Requestfinancial__c rf:Reqfinancial)
                             {
                                rf.Chequeo_vigente__c = false;
                             }
                     }
                     
                     // JAAR Bloquear el dato de facturación posterior al envio del chequeo --
                     Block_data();
                    
                     try{
                            update oppcheck;
                            if(Reqfinancial <> null)
                            {
                              update Reqfinancial;
                            }
                            insert checfin;     
                             
                        }catch(system.exception e)
                            {
                             system.debug('No fue posible actualizar la opp  '+e);
                            }
                                this.billingdata  = false;
                            this.BlnMessage   = true;
                        isok = false;
                        this.setMsg(1, 'Oportunidad de valor cero no requiere aprobación de cartera, pasará directamente a Gestión fulfillment '  );
                        //this.StrMessage = 'Oportunidad de valor cero no requiere aprobación de cartera pasará  directamente a Gestión fulfillment ';
                        return null;
                        }
                        
                }
             //====================================================== fin opp valor cero ==============================================     
                
                
            /***********************VALIDACION DE CLIENTE UNICO *******************************************************************************
            **JAAR 27-03-2014 Si el cliente asociado a la oportunidad no tiene clietne unico se pasara directamente a cartera para su verificacion 
            **
            ************************************************************************************************************************************/       
            if(oppcheck.Account.Codigo_cliente_unico__c <> null)
            {}else
            {
                rechazo_cartera('CUENTA SIN CLIENTE UNICO', 'Cliente nuevo aun no tiene código de cliente unico');
                this.billingdata  = false;
                    this.BlnMessage   = true;
                        isok = false;
                        this.setMsg(1, 'La cuenta no tiene Cliente_Unico , pasará directamente a cartera para su verificación '  );
                        return null;
            }
             
                        /***********************VALIDACION DE PENDIENTES DE PAGO *******************************************************************************
            **JDHC 19-03-2014 Se realiza validacion de 
            **
            ************************************************************************************************************************************/
            if(oppcheck.Account.Pendiente_pago__c == true){
                rechazo_cartera('CUENTA PENDIENTE DE PAGO', 'La cuenta está pendiente de pago'); 
                
                                this.billingdata  = false;
                            this.BlnMessage   = true;
                        isok = false;
                        this.setMsg(1, 'La cuenta se encuentra pendiente de pago, pasará directamente a cartera para su verificación '  );
                        return null;
            }
 
           
             
  
            /***********************VALIDACION DE TOKEN VTA ON LINE ****************************************************************************
            **JAAR 17-03-2014 solo se realiza en caso de que la venta se haya realizado desde fuente externa y se tenga un token para ingresar a 
            **la oportunidad en cuyo caso no requieran paso por facturacion
            ************************************************************************************************************************************/
            if(oppcheck.Token_venta_en_linea__c <>null) 
            {
                if(!validaRTextTokenonline(oppcheck.Token_venta_en_linea__c))
                 {
                   this.billingdata  = false; 
                           this.BlnMessage   = true;
                   isok = false;
                   this.setMsg(2, 'El token de venta ON-LINE ingresado en la oportunidad, no cumple con las caracteristicas especificadas, por favor verifiquelo y vuelva a intentarlo'  );
                   return null;  
                 }else
                 {
                   system.debug('Supero_la_validacion_del_token:online');
                    //1 - Actualiza la marca de chequero de crédito de la oportunidad
                    oppcheck.IsCreditAnalysisRequired__c        =  false;
                    oppcheck.IsCreditExceptionAllowed__c        =  false;
                    //2 - bloquea la oportunidad para que no pueda ser editada despues del chequeo
                        oppcheck.blocked_opportunity__c        = true;
                        oppcheck.RecordTypeId                              = '01240000000IYWbAAO';
                    //Se iguala el  campo Fecha_cerrada_entregada_facturacion__c a Fecha_Entregada_Facturacion__c ya que pasa automaticamente a fulfillment 
                    oppcheck.Fecha_Entregada_Facturacion__c                     = system.now();
                    oppcheck.Fecha_cerrada_entregada_facturacion__c     = system.now();
                    oppcheck.Comentarios_fulfillment__c                         = '';
                    oppcheck.Comentarios_Cartera__c                                     = '';
                    //se limpian los campos de la gestion de fulfillment ya que iniciará nuevamente el flujo de aprobación
                    oppcheck.Responsable_fulfillmet__c                                  =null;
                    oppcheck.Semaforostatus__c                                                  =null;
                    oppcheck.Status_fulfillment__c                                              =null;
                        oppcheck.Comentarios_fulfillment__c                             ='';
                    oppcheck.Fecha_Entregada_Fulfillment__c                     =null;
                    oppcheck.Fecha_cerrada_fulfillment__c                               =null;
                    oppcheck.Estado_No_conformidad__c                   =null;
                    oppcheck.Estado_No_conformidad_Cartera__c           = null;
                            Requestfinancial__c checfin = new Requestfinancial__c();
                                //JAAR si el chequeo automatico fue aprobado ingresa directo a fulfillment
                        oppcheck.StageName                                      = '06 Cerrada Entregada Fulfillment';
                        oppcheck.Fecha_Entregada_Fulfillment__c =system.now();
                        //JAAR no pasa por facturación la fecha de entrada y salida es la misma
                        oppcheck.Fecha_Entregada_Facturacion__c                         = system.now();
                                        oppcheck.Fecha_cerrada_entregada_facturacion__c         = System.now();
                                        checfin.Fecha_Entregada_Facturacion__c                          = system.now();
                                        checfin.Date_of_Approval__c                                             = system.now();
                                        oppcheck.automaticresult__c                     = 'APROBADO';
                        oppcheck.endcheckup__c                          = 'APROBADO';
                        oppcheck.Semaforostatus__c                      = 'Green';
                            oppcheck.CreditCheckCode__c                 = 'VENTA ON-LINE'; 
                            oppcheck.Comentarios_Cartera__c     = 'Posee token de Venta On-Line,Oportunidad aprobada automaticamente por el sistema';                   
                        //------CHEQUEO APROBADO---------------------------------------------------------
                        checfin.CreditCheckCode__c                      = 'VENTA ON-LINE'; 
                    checfin.IsCreditAnalysisRequired__c = false;
                    checfin.IsCreditExceptionAllowed__c = false;
                    checfin.LastCreditCheck__c                  = system.now();
                    checfin.Idoportunity__c                             = IdOportunity;
                    checfin.Chequeo_vigente__c                          = true;
                    system.debug('relacion_quotes  '+oppcheck.Quotes);
                    checfin.Monto__c                                            = oppcheck.Quotes.get(0).GrandTotal;
                    checfin.Status_del_chequeo__c                       = 'APROBADO';
                    checfin.automaticresult__c                          = 'APROBADO';
                    checfin.User_approver__c                            = 'SISTEMA';
                    checfin.Tipo_de_solicitud__c                        = '';
                    checfin.Mensajes_Chequeo__c                         = 'Posee token de Venta On-Line,Oportunidad aprobada automaticamente por el sistema';   
                            Reqfinancial = getRequestfinancial(IdOportunity, checfin.CreditCheckCode__c );
                     if(Reqfinancial <> null)
                     {
                        for (Requestfinancial__c rf:Reqfinancial)
                             {
                                rf.Chequeo_vigente__c = false;
                             }
                     }
                     // JAAR Bloquear el dato de facturación posterior al envio del chequeo --
                     Block_data();
                     
                     try{
                            update oppcheck;
                            if(Reqfinancial <> null)
                            {
                              update Reqfinancial;
                            }
                            insert checfin;     
                           
                        }catch(system.exception e)
                            {
                             system.debug('No fue posible actualizar la opp  '+e);
                            }
                                this.billingdata  = false;
                            this.BlnMessage   = true;
                        isok = false;
                        this.setMsg(1, 'Oportunidad con token de Venta On-Line, no requiere aprobación de cartera, pasará directamente a Gestión fulfillment '  );
                        return null;
                }
                 
            } 
            
            
            //=========================================================================================================================
                
            }
            
            system.debug('CotizacionId_1 '+ CotizacionId);          
            OperationCode    = Apexpages.currentPage().getParameters().get('OperationCode');
            requestFrom      = Apexpages.currentPage().getParameters().get('requestFrom');
            accion           = Apexpages.currentPage().getParameters().get('accion');
            object obj;
            object objrequest;
            selection='0';
            system.debug('requestFrom==>>>  '+ requestFrom);
            // Leer el registro de la Cotizacion del paraemtro enviado por URL o el de la cuenta o lead dependiendo el caso
            if(requestcupo == true)
            {
                //JAAR 29-04-2014 modificacion realizada para realizar la consulta desde el lead
                if(requestFrom == 'CUENTA')
                {
                  //Consulta realizada desde la cuenta ---------------------------------------------------------------------
                  this.Valcuenta =  this.getAccountById(CotizacionId);
                  this.Codigocuenta = Valcuenta.Codigo_cuenta__c;
                  this.Namecuenta = Valcuenta.Name;
                  if(Valcuenta.Codigo_cliente_unico__c != null)
                  {
                        system.debug('\n\n Codigo_cliente_unico__c_de_la_cuenta ' + Valcuenta.Codigo_cliente_unico__c);
                        this.Clienteunico  = String.valueof(Valcuenta.Codigo_cliente_unico__c);
                        this.identification = String.valueof(Valcuenta.Numero_identificacion__c);
                        completeCU = true;
                        completeQuote = true;//se deja para cuenta en true
                  }else
                  {
                        system.debug('\n\n Para_realizar_el_chequeo de credito la cuenta debe tener codigo de cliente Unico contacte al administrador');   
                        this.Clienteunico  = 'No se encontró información en salesforce';
                        this.identification = 'No se encontró información en salesforce';
                        completeCU = false;
                        this.nameCotizacion = 'Respuesta del chequeo de crédito para : ' + this.Valcuenta.Name;
                        this.billingdata  = false;
                        completeQuote = true;//se deja para cuenta en true para que permita realizar la consulta al SW
                  }
                }else if(requestFrom == 'LEAD')
                {
                  //Consulta realizada desde el lead ---------------------------------------------------------------------
                  this.Vallead =  this.getLeadById(CotizacionId);
                  this.Codigocuenta = '';
                  this.Namecuenta = Vallead.Name;
                  if(Vallead.Codigo_cliente_unico__c != null)
                  {
                        system.debug('\n\n Codigo_cliente_unico__c_del_lead ' + Vallead.Codigo_cliente_unico__c);
                        this.Clienteunico  = String.valueof(Vallead.Codigo_cliente_unico__c);
                        this.identification = String.valueof(Vallead.Nit__c);
                        completeCU = true;
                        completeQuote = true;//se deja para Lead en true
                  }
                } 
              
            //------------------------------------------------------------------------------------------------------------------  
           }else
            {
                this.ValCotizacion = this.getQuoteById(CotizacionId);  // Read Cotizacion 
                    this.Codigocuenta  =  ValCotizacion.Opportunity.Account.Codigo_cuenta__c;  
                    this.Namecuenta  =  ValCotizacion.Opportunity.Account.Name;
                    if(ValCotizacion.Opportunity.Account.Codigo_cliente_unico__c <> null)
                        {
                        system.debug('\n\n Codigo_cliente_unico__c_de_la_cotizacion  '+ ValCotizacion.Opportunity.Account.Codigo_cliente_unico__c ); 
                        this.Clienteunico  = String.valueof(ValCotizacion.Opportunity.Account.Codigo_cliente_unico__c);
                        this.identification = String.valueof(ValCotizacion.Opportunity.Account.Numero_identificacion__c);
                        completeCU = true;
                    }else
                    {
                         system.debug('\n\n Clienteunico_inicial  '+ Clienteunico +'CotizacionId_1  ' + CotizacionId ); 
                         
                        system.debug('\n\n Para realizar el chequeo de credito la cuenta debe tener codigo de cliente Unico contacte al administrador');   
                        this.Clienteunico  = 'No se encontró información en salesforce';
                        this.identification = 'No se encontró información en salesforce';
                        completeCU = false;
                    }
                this.nameCotizacion = 'Respuesta del chequeo de crédito para : ' + this.ValCotizacion.Name;
                 // Valida que la cotización tenga datos de facturación y productos para consumir el sw
                completeQuote=this.ValidateCotizacion(this.ValCotizacion,requestFromsimulation);     
            } 
            
            
            //***************JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ
            
            
             
             if (completeQuote==true && completeCU == true) 
             {
                //llamar clase que contiene la logica de la construccion del request del chequeo
                this.scmc = new cl009_saplogiccreditcheck(CotizacionId,OperationCode,requestFrom,requestFromsimulation,requestcupo); 
                system.debug('Entro_a_proccesCheckCreditscmc  '+scmc);
                try
                 {
                    system.debug('\n\n 1-Antes_proccesCheckCredit');
                    obj= this.scmc.proccesCheckCredit();
                    
                    system.debug('\n\n mi_obj======>>>'+obj);
                    
                   
                    
                 }catch(system.exception e)
                 {
                    system.debug('ver error 1 -->'+'Error_al_invocar_el_web service de chequeo de credito');
                    //this.setMsg(0, 'Error al invocar el web service de chequeo de credito'); 
                    BlnMessage = true;
                    isok = false;
                    invoked = false;            //JDHC 19-03-2014
                    this.billingdata  = false;
                    //return null;
                 }
                 
                 
                  //JDHC 19-03-2014 se evalua si el servicio fue invocado y si no es una simulacion
                  system.debug('invoked1::: '+invoked);
                   system.debug('rfs::: '+requestFromsimulation);
                 if (invoked == false && requestFromsimulation == false){               
                     oppcheck.IsCreditAnalysisRequired__c       =  false;
                     oppcheck.IsCreditExceptionAllowed__c       =  false;
                          //Se iguala el  campo Fecha_cerrada_entregada_facturacion__c a Fecha_Entregada_Facturacion__c ya que pasa automaticamente a fulfillment 
                    oppcheck.Fecha_Entregada_Facturacion__c                     = system.now();
                    oppcheck.Fecha_cerrada_entregada_facturacion__c             = null;
                    oppcheck.Comentarios_fulfillment__c                                 = '';
                    oppcheck.Comentarios_Cartera__c                                             = '';
                     //se limpian los campos de la gestion de fulfillment ya que iniciará nuevamente el flujo de aprobación
                    oppcheck.Responsable_fulfillmet__c                                  =null;
                    oppcheck.Semaforostatus__c                                                  =null;
                    oppcheck.Status_fulfillment__c                                              =null;
                        oppcheck.Comentarios_fulfillment__c                                     ='';
                    oppcheck.Fecha_Entregada_Fulfillment__c                             =null;
                    oppcheck.Fecha_cerrada_fulfillment__c                               =null;
                    oppcheck.Estado_No_conformidad__c                           =null;
                    oppcheck.Estado_No_conformidad_Cartera__c                   = null;
                            Requestfinancial__c checfin = new Requestfinancial__c();
                                //JAAR si el chequeo automatico fue aprobado ingresa directo a fulfillment
                        oppcheck.StageName                                                                      = '05 Cerrada Entregada Facturación';
                        oppcheck.Fecha_Entregada_Fulfillment__c                         =system.now();
                        //JAAR no pasa por facturación la fecha de entrada y salida es la misma
                        //oppcheck.Fecha_Entregada_Facturacion__c                               = system.now();
                                        
                                        checfin.Fecha_Entregada_Facturacion__c                          = system.now();
                                        //checfin.Date_of_Approval__c                                           = system.now();
                                        oppcheck.automaticresult__c                     = 'RECHAZADO';
                        oppcheck.endcheckup__c                          = 'EN PROCESO';
                        oppcheck.Semaforostatus__c                      = 'Yellow';
                            oppcheck.CreditCheckCode__c                 = 'ERROR DE CONEXION'; 
                            oppcheck.Comentarios_Cartera__c     = 'El sistema no se pudo conectar al servicio de chequeo';                      
                        //------CHEQUEO APROBADO---------------------------------------------------------
                        checfin.CreditCheckCode__c                      = 'ERROR DE CONEXION'; 
                    checfin.IsCreditAnalysisRequired__c = false;
                    checfin.IsCreditExceptionAllowed__c = false;
                    checfin.LastCreditCheck__c                  = system.now();
                    checfin.Idoportunity__c                             = IdOportunity;
                    checfin.Chequeo_vigente__c                          = true;
                    system.debug('relacion_quotes  '+oppcheck.Quotes);
                    checfin.Monto__c                                            = oppcheck.Quotes.get(0).GrandTotal;
                    checfin.Status_del_chequeo__c                       = 'EN PROCESO';
                    checfin.automaticresult__c                          = 'RECHAZADO';
                    checfin.User_approver__c                            = 'SISTEMA';
                    checfin.Tipo_de_solicitud__c                        = '';
                    checfin.Mensajes_Chequeo__c                         = 'El sistema no se pudo conectar al servicio de chequeo';      
                            Reqfinancial = getRequestfinancial(IdOportunity, checfin.CreditCheckCode__c );
                            
                     if(Reqfinancial <> null)
                     {
                        for (Requestfinancial__c rf:Reqfinancial)
                             {
                                rf.Chequeo_vigente__c = false;
                             }
                     }
                     // JAAR Bloquear el dato de facturación posterior al envio del chequeo --
                     Block_data();
                     
                     try{
                            update oppcheck;
                            if(Reqfinancial <> null)
                            {
                              update Reqfinancial;
                            }
                            insert checfin;     
                           
                        }catch(system.exception e)
                            {
                             system.debug('No fue posible actualizar la opp  '+e);
                            }
                                this.billingdata  = false;
                            this.BlnMessage   = true;
                        isok = false;
                        this.setMsg(1, 'Se presento error de conexion con el servicio, pasará directamente al area de cartera para ser validado de forma manual '  );
                        return null;
                 }
                                  
                 if (obj != null)
                 {
                    //almacena  la inf del obj en una lista para mostrar en la respuesta 
                    
                    detallecotizacion = scmc.listProducts;
                    system.debug('detallecotizacion_request '+ detallecotizacion );
                   
                   //-----------------------------------------------------------------------------
                   
                   /*
                    try
                    {
                      system.debug('@@obj--> '+obj);
                      Boolean respuesta=(Boolean)obj;
                      
                      if (respuesta==true)
                      {
                        try{
                             system.debug('@@this.ValCotizacion.id--> '+this.ValCotizacion.id);
                           } catch(Exception ex1)
                           {
                            system.debug('ex.getMessage(): '+ex1.getMessage());
                            this.setMsg(0, ex1.getMessage());
                           }  
                        //redireccióna depende de donde se haya hecho el llamado:SIMULACION o CHEQUEO
                         if (strAccion == 'SIMULACION')  
                            {                                  
                               return null;
                               // return this.InvokeFinancialValidation();       
                            }   
                          else if (strAccion == 'CHEQUEO')  
                          {
                                //pendiente
                          }                                            
                      
                     }                           
                  } catch(Exception ex)
                  {
                    system.debug('ver error 3-->'+'ERROR_CHQ');
                    this.setMsg(0, 'Error obteniendo respuesta');
                  }
                  */
                  //JAAR agrega el response al map para obtener respuesta directa 
                  mapRsChequearCred=(map<ID,CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos>)obj;
                  
                   system.debug('\n\n mapRsChequearCred====>>>>'+mapRsChequearCred);
               }else 
               {
                system.debug('\n\n ver_error_4-->'+'obj = null');
                this.setMsg(2, 'Error en el quequeo de credito');
               }
              
                listCreditWorthiness = this.getRespuestasChequeCredito();  
                system.debug('\n\n JAAR nuevo_mi_listCreditWorthiness_post  '+ listCreditWorthiness);
                
                if(listCreditWorthiness[0].creditLimit <> null)
                {}else
                {
                    //-----
                            if(!requestFromsimulation) 
                               {
                                /***********************CLIENTE NO EXISTE EN SAP *******************************************************************************
                                    **JAAR 22-03-2014 Si el cliente no existe en SAP envia la oportunidad al area de cartera para su validación 
                                    **
                                    ************************************************************************************************************************************/
                                    rechazo_cartera('CLIENTE NO EXISTE EN SAP', 'Posiblemente el cliente no existe en SAP'); 
                                     
                                                        this.billingdata  = false;
                                                    this.BlnMessage   = true;
                                                isok = false;
                                                this.setMsg(1, 'Posiblemente el cliente no existe en SAP, pasará directamente a cartera para su verificación '  );
                                                return null;
                                   }else
                               {
                                return null;
                               }
                          //-----
                }
              system.debug('valor_de_requestFromsimulation   '+requestFromsimulation);
              if(!requestFromsimulation) 
               { 
                        //JAAR Almacenar la respuesta del chequeo de crédito en salesforce *********************************************************
                        for(CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness response : listCreditWorthiness)
                        {
                                system.debug('response=====>>>   '+response);
                                system.debug('response_checkingDescription=====>>>   '+response.checkingDescription);
                                system.debug('response.parInfo_Adicional_CM   ' +response.parInfo_Adicional_CM);
                                system.debug('response.parInfo_Adicional_CM_permiteExcepcion   ' +response.parInfo_Adicional_CM.permiteExcepcion);
                                system.debug('response.parInfo_Adicional_CM_requiereEstudio   ' +response.parInfo_Adicional_CM.requiereEstudio);
                        
                                if(response.indicador != null )
                                {
                                        
                                if(response.checkingDescription                != null &&
                               response.indicador                          != null &&
                               response.permiteExcepcion                   != null &&
                               response.RequiereEstudio                    != null &&
                               response.riskClass.validityPeriod.endDate   != null)
                               {
                                     oppcheck = getOpportunity(IdOportunity);
                                     system.debug('oportunidad_a_mod '+oppcheck);
                                     
                                     //1 - Actualiza la marca de chequero de crédito de la oportunidad
                                     oppcheck.CreditCheckCode__c                        = response.checkingDescription;
                                     oppcheck.CreditLimitValidUntilDate__c      = response.riskClass.validityPeriod.endDate;
                                     oppcheck.IsCreditAnalysisRequired__c       = response.RequiereEstudio;
                                     oppcheck.IsCreditExceptionAllowed__c       = response.permiteExcepcion;
                                     oppcheck.LastCreditCheck__c            = system.now();  
                                     
                                     //2 - bloquea la oportunidad para que no pueda ser editada despues del chequeo
                                     oppcheck.blocked_opportunity__c        = true;
                                     
                                     oppcheck.Fecha_Entregada_Fulfillment__c  = null;
                                     //se borra el campo Fecha_cerrada_entregada_facturacion__c ya que si se realizo de nuevo el chequeo debe resetear el ANS
                                     oppcheck.Fecha_Entregada_Facturacion__c = system.now();
                                     oppcheck.Fecha_cerrada_entregada_facturacion__c = null;
                                     oppcheck.Comentarios_fulfillment__c                        = '';
                                     oppcheck.Comentarios_Cartera__c                            = '';
                                     //se limpian los campos de la gestion de fulfillment ya que iniciará nuevamente el flujo de aprobación
                                     oppcheck.Responsable_fulfillmet__c         =null;
                                     oppcheck.Semaforostatus__c                         =null;
                                     oppcheck.Status_fulfillment__c                     =null;
                                 oppcheck.Comentarios_fulfillment__c    ='';
                                     oppcheck.Fecha_Entregada_Fulfillment__c    =null;
                                    
                                     oppcheck.Fecha_cerrada_fulfillment__c              =null;
                                     oppcheck.Estado_No_conformidad__c          =null;
                                     oppcheck.Estado_No_conformidad_Cartera__c  = null;
                                     
                                     
                                     //JAAR Bloquear el dato de facturación posterior al envio del chequeo ----------------------------------
                                     Block_data();
                                     /*
                                     if(cotizacion.Datos_facturacion__r.size() >0)
                                     {
                                        for (Integer i = 0; cotizacion.Datos_facturacion__r.size()>i ; i++ )
                                        {
                                                cotizacion.Datos_facturacion__r.get(i).Blocked_BillingData__c= true;
                                        }
                                     }
                                     //-------------------------------------------------------------------------------------------------------
                                     */
                                     
                                     
                                     //*****Si el chequeo automático fue aprobado  crea la solicitud******************************
                                     Requestfinancial__c checfin = new Requestfinancial__c();
                                     if(!requestFromsimulation)
                                     
                                         //JAAR 21-03-2014 Validar si el chequeo de creditó esta apagado para controlar que todas las solictiudesp asen por cartera 
                                             if(response.indicador == false || (response.indicador == true && ChequeoApagado == true ) )
                                             {
                                                // 2- llena el historial de Solicitudes a financiero  
                                                     //Cambios si entra a facturación PENDIENTE
                                             oppcheck.StageName                                         = '05 Cerrada Entregada Facturación';
                                                     checfin.CreditCheckCode__c                         = response.checkingDescription;
                                                     checfin.CreditLimitValidUntilDate__c       = response.riskClass.validityPeriod.endDate;
                                                     checfin.IsCreditAnalysisRequired__c        = response.RequiereEstudio;
                                                     checfin.IsCreditExceptionAllowed__c        = response.permiteExcepcion;
                                                     checfin.LastCreditCheck__c                 = system.now();
                                                     checfin.Idoportunity__c                            = IdOportunity;
                                                     checfin.Chequeo_vigente__c                         = true;
                                                     checfin.Fecha_Entregada_Facturacion__c = system.now();
                                                     system.debug('relacion_quotes  '+oppcheck.Quotes);
                                                     checfin.Monto__c                                           = oppcheck.Quotes.get(0).GrandTotal;
                                                     checfin.Status_del_chequeo__c                      = 'EN PROCESO';
                                                     if(response.permiteExcepcion && response.RequiereEstudio)
                                                     {
                                                        checfin.Tipo_de_solicitud__c                    = 'Excepción';
                                                     }else if (response.permiteExcepcion && !response.RequiereEstudio)
                                                     {
                                                       checfin.Tipo_de_solicitud__c                     = 'Excepción';
                                                     }else if(!response.permiteExcepcion && response.RequiereEstudio)
                                                     {
                                                        checfin.Tipo_de_solicitud__c                    = 'Estudio de crédito';
                                                     }else
                                                     {
                                                        checfin.Tipo_de_solicitud__c                    = '';
                                                     }
                                                     
                                                     
                                                     
                                                     checfin.Mensajes_Chequeo__c                        ='';            
                                                     for (CL008_Sap_ConsCupoCredit_ObjectsSF.DescripcionMsgRs msg: response.listCheckingDescription)
                                                     {
                                                        checfin.Mensajes_Chequeo__c = checfin.Mensajes_Chequeo__c + '\n '+ msg.mensaje; 
                                                     }
                                                   
                                                     Reqfinancial = getRequestfinancial(IdOportunity, checfin.CreditCheckCode__c );
                                                     if(Reqfinancial <> null)
                                                     {
                                                        for (Requestfinancial__c rf:Reqfinancial)
                                                             {
                                                                rf.Chequeo_vigente__c = false;
                                                             }
                                                     }
                                                     
                                                     
                                                     if(response.RequiereEstudio || response.permiteExcepcion)
                                             {
                                                oppcheck.automaticresult__c                     = 'Requiere verificación de Cartera';
                                                checfin.automaticresult__c                      = 'Requiere verificación de Cartera';
                                                oppcheck.Semaforostatus__c                      = 'Yellow';
                                             }else
                                             {
                                                if(ChequeoApagado == true)
                                                {
                                                        //JAAR 21-03-2014 Validar si el chequeo de creditó esta apagado para controlar que todas las solictiudesp asen por cartera 
                                                        oppcheck.automaticresult__c                     = 'APROBADO - CHEQUEO AUTOMATICO-OFF';
                                                    checfin.automaticresult__c                  = 'APROBADO - CHEQUEO AUTOMATICO-OFF';
                                                    oppcheck.Semaforostatus__c                  = 'Yellow';
                                                }else
                                                {
                                                        oppcheck.automaticresult__c                     = 'Rechazado no superó la validación inicial';
                                                    checfin.automaticresult__c                  = 'Rechazado no superó la validación inicial';
                                                    oppcheck.Semaforostatus__c                  = 'Red';
                                                }
                                                
                                             }
                                                oppcheck.endcheckup__c                          = '';
                                             }else if(response.indicador == true &&  ChequeoApagado == false )
                                             {
                                                
                                                
                                                //JAAR si el chequeo automatico fue aprobado ingresa directo a fulfillment
                                                oppcheck.StageName                                      = '06 Cerrada Entregada Fulfillment';
                                                oppcheck.Fecha_Entregada_Fulfillment__c =system.now();
                                                //JAAR no pasa por facturación la fecha de entrada y salida es la misma
                                                oppcheck.Fecha_Entregada_Facturacion__c                         = system.now();
                                                        oppcheck.Fecha_cerrada_entregada_facturacion__c         = System.now();
                                                        checfin.Fecha_Entregada_Facturacion__c                          = system.now();
                                                        checfin.Date_of_Approval__c                                             = system.now();
                                                        
                                                oppcheck.Fecha_cerrada_fulfillment__c           =null;
                                                oppcheck.automaticresult__c                     = 'APROBADO';
                                                oppcheck.endcheckup__c                          = 'APROBADO';
                                                oppcheck.Semaforostatus__c                      = 'Green';
                                                
                                                //------CHEQUEO APROBADO---------------------------------------------------------
                                                 checfin.CreditCheckCode__c                     = response.checkingDescription;
                                                     checfin.CreditLimitValidUntilDate__c       = response.riskClass.validityPeriod.endDate;
                                                     checfin.IsCreditAnalysisRequired__c        = response.RequiereEstudio;
                                                     checfin.IsCreditExceptionAllowed__c        = response.permiteExcepcion;
                                                     checfin.LastCreditCheck__c                 = system.now();
                                                     checfin.Idoportunity__c                            = IdOportunity;
                                                     checfin.Chequeo_vigente__c                         = true;
                                                     system.debug('relacion_quotes  '+oppcheck.Quotes);
                                                     checfin.Monto__c                                           = oppcheck.Quotes.get(0).GrandTotal;
                                                     checfin.Status_del_chequeo__c                      = 'APROBADO';
                                                     checfin.automaticresult__c                         = 'APROBADO';
                                                     checfin.User_approver__c                           = 'SISTEMA';
                                                     if(response.permiteExcepcion && response.RequiereEstudio)
                                                     {
                                                        checfin.Tipo_de_solicitud__c                    = 'Excepción';
                                                     }else if (response.permiteExcepcion && !response.RequiereEstudio)
                                                     {
                                                       checfin.Tipo_de_solicitud__c                     = 'Excepción';
                                                     }else if(!response.permiteExcepcion && response.RequiereEstudio)
                                                     {
                                                        checfin.Tipo_de_solicitud__c                    = 'Estudio de crédito';
                                                     }else
                                                     {
                                                        checfin.Tipo_de_solicitud__c                    = '';
                                                     }
                                                     
                                                     
                                                     
                                                     checfin.Mensajes_Chequeo__c                        ='';            
                                                     for (CL008_Sap_ConsCupoCredit_ObjectsSF.DescripcionMsgRs msg: response.listCheckingDescription)
                                                     {
                                                        checfin.Mensajes_Chequeo__c = checfin.Mensajes_Chequeo__c + '\n '+ msg.mensaje; 
                                                     }
                                                   
                                                     Reqfinancial = getRequestfinancial(IdOportunity, checfin.CreditCheckCode__c );
                                                     if(Reqfinancial <> null)
                                                     {
                                                        for (Requestfinancial__c rf:Reqfinancial)
                                                             {
                                                                rf.Chequeo_vigente__c = false;
                                                             }
                                                     }
                                                     
                                                //-------------------------------------------------------------------------------
                                                
                                             }
                                             
                                            /* 
                                             if (response.indicador == true )
                                             {
                                                checfin.automaticresult__c                      = 'APROBADO';
                                                oppcheck.automaticresult__c                     = 'APROBADO';
                                                oppcheck.Semaforostatus__c                      = 'Green';
                                             }else
                                             {
                                                 if(response.RequiereEstudio || response.permiteExcepcion)
                                             {
                                                oppcheck.automaticresult__c                     = 'Requiere verificación de Cartera';
                                                checfin.automaticresult__c                      = 'Requiere verificación de Cartera';
                                                oppcheck.Semaforostatus__c                      = 'Yellow';
                                             }else
                                             {
                                                oppcheck.automaticresult__c                     = 'Rechazado no superó la validación inicial';
                                                checfin.automaticresult__c                      = 'Rechazado no superó la validación inicial';
                                                oppcheck.Semaforostatus__c                      = 'Red';
                                             }
                                             }
                                            */ 
                                             
                                             try{
                                                    update oppcheck;
                                                    if(Reqfinancial <> null)
                                                    {
                                                      update Reqfinancial;
                                                    }
                                                    
                                                    insert checfin;     
                                                    /* JAAR se guarda siemrpe el historial
                                                    if(response.indicador == false)
                                                    {
                                                      insert checfin;   
                                                    }
                                                    */
                                                    if(cotizacion.Datos_facturacion__r.size() >0)
                                                    {
                                                        update cotizacion.Datos_facturacion__r;
                                                    }
                                             }catch(system.exception e)
                                             {
                                                system.debug('No fue posible actualizar la opp  '+e);
                                             }
                                          
                                                   }
                                        
                                                   
                                }
                                        
                        }
             }else
             {
                //JAAR 29-04-2014 si el llamado se realizo desde un Lead y el chequeo fue aprobado se almacenará en el lead la información del chequeo
                
                 if(requestcupo == true)
                    {
                      if(requestFrom == 'LEAD')
                        {
                            for(CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness response : listCreditWorthiness)
                            {
                                system.debug('response=====>>>   '+response);
                                //se almacenara le response en el lead 
                                Vallead.Fecha_Validez_limite__c         = response.riskClass.validityPeriod.endDate;
                                if( response.debtorbartyBlockedIndicatorFv == 'SI')
                                {
                                    Vallead.Cliente_Bloqueado__c            = true;
                                }else
                                {
                                    Vallead.Cliente_Bloqueado__c            = false;
                                }
                                
                                Vallead.Tipo_de_Riesgo__c               = response.riskClass.code;
                                Vallead.Cupo_Asignado__c                = response.CreditLimit.amount;
                                Vallead.Fecha_Validez_limite__c         = response.CreditLimit.validityPeriod.endDate;
                                Vallead.Saldo_Disponible__c             = response.saldo;
                                Vallead.Fecha_sincronizacion_SAP__c     = system.now(); 
                                try
                                {
                                    update Vallead;
                                }catch(Exception ex)
                                {
                                    system.debug('\n\n actualizacion del response en el lead fallo  '+ ex);
                                }
                                system.debug('\n\n realizo_la_actualizacion_del_lead  '+ resultDetalle);
                            }
                            
                        }       
                    }
                
             } 
                //-------------------------JAAR 04-02-2014 MODIFICACION PARA LA PAGE------------------------------------
                resultDetalle = new  List<CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness>();
                     Integer indicador=0;
                     String indicadorStr='';
                     if(mapRsChequearCred == null) return null;
                     for(CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos i:mapRsChequearCred.values()) {
                        indicadorStr=String.valueOf(indicador+1);
                        system.debug('indicador '+ indicadorStr + 'selection  '+selection+ 'generando_resultDetalle_para la paginaVF  ' +resultDetalle);
                       
                            resultDetalle.add(i.parCreditWorthiness);                   
                       
                        indicador++;
                     }
                     system.debug('\n\n JAAR_resultDetalle  '+ resultDetalle);
                     if(this.requestcupo == true)
                     {
                        this.billingdata  = false;      
                     }
                //--------------------------------------------------------------------------------------------------------
            }else
            {
                system.debug('\n\n El_documento_no_esta_completo no es posible continuar');  
                this.billingdata  = false;
                    this.BlnMessage   = true;
                        isok = false;
                        this.setMsg(0, 'No es posible realizar la simulación del chequeo de crédito, la cuenta debe tener codigo de cliente unico '  );
                        return null;
            }
      // }else
      //{
             
      //}
     return null;   
    }
    /*******************************************************************************************************************    
    * JAAR 19-03-2014 RECHAZO-CARTERA == Metodo que crea las condiciones de la oportunidad y el chequeo de credito para 
    una oportunidad rechazada por cartera
    * @return  boolean.  
    *********************************************************************************************************************/ 
      //metodo para crear opp y solicitud a financiero RECHAZO - CARTERA
      public boolean rechazo_cartera(String CreditCheckCode, String Comentarios_Cartera)
      {
        boolean cartera = false;
       //1 - Actualiza la marca de chequero de crédito de la oportunidad
            oppcheck.IsCreditAnalysisRequired__c        =  false;
            oppcheck.IsCreditExceptionAllowed__c        =  false;
       //Se iguala el  campo Fecha_cerrada_entregada_facturacion__c a Fecha_Entregada_Facturacion__c ya que pasa automaticamente a fulfillment 
            oppcheck.Fecha_Entregada_Facturacion__c                     = system.now();
            oppcheck.Fecha_cerrada_entregada_facturacion__c     = null;
            oppcheck.Comentarios_fulfillment__c                         = '';
            oppcheck.Comentarios_Cartera__c                                     = '';
      //se limpian los campos de la gestion de fulfillment ya que iniciará nuevamente el flujo de aprobación
            oppcheck.Responsable_fulfillmet__c                                  =null;
            oppcheck.Semaforostatus__c                                                  =null;
            oppcheck.Status_fulfillment__c                                              =null;
                oppcheck.Comentarios_fulfillment__c                             ='';
            oppcheck.Fecha_Entregada_Fulfillment__c                     =null;
            oppcheck.Fecha_cerrada_fulfillment__c                               =null;
            oppcheck.Estado_No_conformidad__c                   =null;
            oppcheck.Estado_No_conformidad_Cartera__c           = null;
                    Requestfinancial__c checfin = new Requestfinancial__c();
                        oppcheck.StageName                                      = '05 Cerrada Entregada Facturación';
                oppcheck.Fecha_Entregada_Fulfillment__c                         =null;
                //JAAR debe pasar por facturación 
                oppcheck.Fecha_Entregada_Facturacion__c                         = system.now();
                        oppcheck.Fecha_cerrada_entregada_facturacion__c         = null;
                        checfin.Fecha_Entregada_Facturacion__c                          = system.now();
                        checfin.Date_of_Approval__c                                             = null;
                        oppcheck.automaticresult__c                     = 'Requiere verificación de Cartera';
                oppcheck.endcheckup__c                          = 'EN PROCESO';
                oppcheck.Semaforostatus__c                      = 'Yellow';
            oppcheck.CreditCheckCode__c                 =  CreditCheckCode; 
            oppcheck.Comentarios_Cartera__c     =  Comentarios_Cartera;                 
                //------CHEQUEO APROBADO---------------------------------------------------------
            checfin.CreditCheckCode__c                  =  CreditCheckCode; 
            checfin.IsCreditAnalysisRequired__c = false;
            checfin.IsCreditExceptionAllowed__c = false;
            checfin.LastCreditCheck__c                  = system.now();
            checfin.Idoportunity__c                             = IdOportunity;
            checfin.Chequeo_vigente__c                          = true;
            system.debug('relacion_quotes  '+oppcheck.Quotes);
            checfin.Monto__c                                            = oppcheck.Quotes.get(0).GrandTotal;
            checfin.Status_del_chequeo__c                       = 'EN PROCESO';
            checfin.automaticresult__c                          = 'Requiere verificación de Cartera';
            checfin.User_approver__c                            = 'SISTEMA';
            checfin.Tipo_de_solicitud__c                        = '';
            checfin.Mensajes_Chequeo__c                         = Comentarios_Cartera;  
            Reqfinancial = getRequestfinancial(IdOportunity, checfin.CreditCheckCode__c );
             if(Reqfinancial <> null)
             {
                for (Requestfinancial__c rf:Reqfinancial)
                     {
                        rf.Chequeo_vigente__c = false;
                     }
             }
             // JAAR Bloquear el dato de facturación posterior al envio del chequeo --
             Block_data();
             
             try{
                    update oppcheck;
                    if(Reqfinancial <> null)
                    {
                      update Reqfinancial;
                    }
                    insert checfin;     
                    cartera = true; 
                   
                }catch(system.exception e)
                    {
                     system.debug('No fue posible actualizar la opp  '+e);
                    }
                    
      return cartera;
      }             
     //---------------------------------------------------------------------  
 
    
    
      /*******************************************************************************************************************    
    * JAAR 19-03-2014 Metodo que bloquea la oportunidad y sus relacionados 
        1. ingresa solo si da clic en el boton enviar aprobacion y se ejecuta el proceso
    * @return  boolean.  
    *********************************************************************************************************************/ 
     public boolean Block_data()
   {
         boolean exito = false;
         /*-----------------------------------------------
         system.debug('\n\n punto_de_interrupcion');
         SumacontroldeInventario();
         if(!Vtalimitadaok)
         return null;
         ------------------------------------------------*/
         
          //1 - Bloquear el dato de facturación posterior al envio del chequeo ----------------------------------
             if(cotizacion.Datos_facturacion__r.size() >0)
             {
                for (Integer i = 0; cotizacion.Datos_facturacion__r.size()>i ; i++ )
                {
                        cotizacion.Datos_facturacion__r.get(i).Blocked_BillingData__c= true;
                }
             }
             //-------------------------------------------------------------------------------------------------------
         
          //2 - Bloquea la oportunidad para que no pueda ser editada despues del chequeo
         oppcheck.blocked_opportunity__c        = true;
         RecordType recordtypeOp = [SELECT Id,Name FROM RecordType where Name = 'Oportunidad bloqueada'];
         oppcheck.RecordTypeId                                  = recordtypeOp.id;
         
      //3 - Bloquea la cotización
             RecordType recordtypecot = [SELECT Id,Name FROM RecordType where Name = 'Presupuesto Bloqueado'];
         cotizacion.blocked_quote__c = true;
         cotizacion.RecordTypeId     = recordtypecot.Id; 
         
         
         try{
                 if(cotizacion.Datos_facturacion__r.size() >0)
                 {
                        update cotizacion.Datos_facturacion__r;
                        update oppcheck;
                        update cotizacion;
                        exito = true;
                 }
                }catch(system.exception e)
             {
                system.debug('No fue posible actualizar la opp  '+e);
             }
         
         
         return exito;
   } 
    
    
    /*********************************************************************************************************************    
    * JAAR 17-03-2014 Valida que el texto del token online este de acuerdo a lo solicitado 
        1. Es un campo alfanumérico de 8 caracteres.
        2. Contiene números del 0 al 9 y letras de la A a la F.
    * @return  boolean.  
    *********************************************************************************************************************/ 
 public Boolean validaRTextTokenonline(String Tokenonline)
    {
        Boolean validation;
        String caracteres = 'abcdefABCDEF0123456789';
        if(Tokenonline.length()== 8)
         {
            for(Integer i=0;i<Tokenonline.length();i++)
            {
               if(caracteres.indexOf(Tokenonline.substring(i,i+1)) == -1)
               {
                 validation= false; 
                 system.debug('El_token_no_contiene_caracteres_especificados== '+ Tokenonline.substring(i,i+1)); 
               }else
               {
                 validation= true; 
                 
               }        
            } 
         }else
         {
            system.debug('El_token_contiene_menos_de_8_caracteres'+ Tokenonline); 
            validation=  false;
         }
         return validation;   
     }
  
   /*********************************************************************************************************************    
    * JAAR 26-06-2014 Valida si tiene productos de venta limitada para sumar en el control de inventario respectivo 
        
    * @return  boolean.  
    *********************************************************************************************************************/ 
 public PageReference SumacontroldeInventario()
    {
    	list<Registro_de_Venta_Limitada__c> vtaslmtadas = getVentaLimitada(IdOportunity);
    	system.debug('\n\nTiene_ventas_limitadas?  '+ vtaslmtadas);
    	Savepoint sp = Database.setSavepoint();
    	Vtalimitadaok = true; // identifica que hay disponibilidad de todos los productos de la oportunidad
    	if(vtaslmtadas <> null)
    	{
    		Set<Id> setControlinventario = new Set<Id>();
    		for (Registro_de_Venta_Limitada__c regvta: vtaslmtadas)
    		{
    			if(regvta.Ciudad__c == regvta.Control_de_Inventario__r.Ciudad__c && regvta.Partida_de_presupuesto__r.Seccion__c == regvta.Control_de_Inventario__r.Seccion__c && regvta.Control_de_Inventario__r.Tipo_Inventario__r.Name == regvta.Partida_de_presupuesto__r.Tipo_de_Inventario__c  )
    			{
    				if(regvta.Control_de_Inventario__r.Cantidad_Disponible__c > 0)
	    			{
	    				setControlinventario.add(regvta.Control_de_Inventario__c);//agrego al set los ctrl de inventario a modificar
	    				if(regvta.Estado__c != 'RENOVADO')
	    				{
	    					system.debug('estado_diferente_a_renovado');
	    					regvta.Estado__c = 'RESERVADO';
	    				}
	    				
	    				
	    				/*
	    				if(regvta.Control_de_Inventario__r.Cantidad_Reservada__c <> null)
	    				{
	    					regvta.Control_de_Inventario__r.Cantidad_Reservada__c = regvta.Control_de_Inventario__r.Cantidad_Reservada__c + 1;
	    				}else
	    				{
	    					regvta.Control_de_Inventario__r.Cantidad_Reservada__c = 1;
	    				}*/
	    			}/*else{
	    				system.debug('\n\nUno de los productos selecionados no tiene disponibilidad  '+ regvta);
	    			    Vtalimitadaok = false;
	    			    //Database.rollback(sp);//jaar 26-06-2014
	    			    this.billingdata  = false;
                        isok = false;
                        BlnMessage = true;
                        this.setMsg(0, 'Uno de los productos selecionados no tiene disponibilidad  '  );
                        Vtalimitadaok = false;
                        return null;
                        break;   
	    			}*/
	    			
    			}else
    			{
    				system.debug('\n\nUno de los productos selecionados no coincide con su seccion + ciudad y tipo de inventario '+ regvta);
	    			Vtalimitadaok = false;
	    			this.billingdata  = false;
                    isok = false;
                    BlnMessage = true;
                    this.setMsg(0, 'Uno de los productos selecionados no coincide con su seccion + ciudad y tipo de inventario' );
                    Vtalimitadaok = false;
                    return null; 
 					break; 
    			}
    			
    		}
    		//actualizamos la informacion del registro de vta en linea y el control de inventario
    		try{
					system.debug('\n\n Vtalimitadaok? ' + Vtalimitadaok);
					if(Vtalimitadaok == true)
					{
						update vtaslmtadas; //modifico los reg de vtas limitadas
						//aqui for que recorra pregunte si la disponibilidad no es negativa y reollback
						list<Control_de_Inventario__c> updatectrl = new list<Control_de_Inventario__c>();
						updatectrl = getControldeinventario(setControlinventario); // consulto los control de inventario padres para actualizar la disponibilidad
						for(Control_de_Inventario__c ctinv: updatectrl)
						{
							if(ctinv.Cantidad_Disponible__c <> null)
							{
								if(ctinv.Cantidad_Disponible__c <0 )
								{
									system.debug('\n\n El control de inventario ' + ctinv + ' ya no tiene disponibilidad - se reversará la transaccion ' ); 
								    Database.rollback(sp);//jaar 26-06-2014 
								    this.billingdata  = false;
                                    isok = false;
                                    BlnMessage = true;
                                    this.setMsg(0, 'El control de inventario '  + ctinv.Name +' para la seccion ' + ctinv.Seccion__r.Name + ' y la ciudad ' + ctinv.Ciudad__r.Name +  ' ya no tiene disponibilidad - se reversará la transaccion '  );
                                     Vtalimitadaok = false;
                                    return null;
                                    break; 
								}
							}else
							{
								   system.debug('\n\n uno de los inventarios ' + ctinv + ' no almacenó la disponibilidad ' ); 
								   Database.rollback(sp);//jaar 26-06-2014 
								   this.billingdata  = false;
                                    isok = false;
                                    BlnMessage = true;
                                    this.setMsg(0, 'El control de inventario ' + ctinv + ' no almacenó la disponibilidad  '  );
                                    Vtalimitadaok = false;
                                    return null;  
                                    break; 
							}
						}
						if(isok == false)
						{
						   return null; 	
						}
						if( Vtalimitadaok = true)
						{
							update updatectrl;
						}
						
					}
				}catch(Exception ex){
					system.debug('\n\n No fue posible actualizar los valores de registro de inventario ' + ex); 
					Database.rollback(sp);//jaar 26-06-2014   
					Vtalimitadaok = false;
				}
    		
    	system.debug('\n\n paso la validacion de vta limitada ' + Vtalimitadaok);	
    	}
     return null;
    }
    
    
    /**************** Action regresar button************/ 
      
    public PageReference                  Regresar(){ 
                       
        PageReference pr = new  PageReference( '/'+Apexpages.currentPage().getParameters().get('PresupuestoId')  );         
        return pr;          
    }
    
    // 26-02-2014       JAAR Metodo que verifica si una cotización ya posee datos de facturacion y productos para poder invocar el chequeo de credito
    public Boolean ValidateCotizacion(Quote parQuote, boolean requestFromsimulation)
    {
        boolean Validate = false; 
        List<QuoteLineItem> prodbycotizacion =  [SELECT Id,LineNumber,ListPrice,Quantity,TotalPrice FROM QuoteLineItem 
                                                 WHERE QuoteId =: parQuote.id];
        
        List<Dato_facturacion__c> datosbycotizacion = [SELECT Fecha_primera_cuota__c,Id,Numero_cuotas__c,Presupuesto__c,Valor_facturacion__c FROM Dato_facturacion__c 
                                                       WHERE Presupuesto__c =: parQuote.id];
        if (prodbycotizacion <> null)
        {   
                system.debug('\n\n prodbycotizacion_diferente_de_null' + prodbycotizacion + ' para la cotizacion '+parQuote);   
            if(prodbycotizacion.size()>0)
            {
                system.debug('\n\n prodbycotizacion_size_mayor_a_cero');  
                //JAAR 25-02-2014 - Realizar la consulta del chequeo de crédito tenga o no un dato de facturación
                
                if(datosbycotizacion <> null)
                {
                    system.debug('\n\n tiene_datos_de_facturacion' + datosbycotizacion);  
                    if(datosbycotizacion.size() >0)
                    {
                        system.debug('\n\n tiene_datos_de_facturacion');  
                        Validate = true;
                        this.billingdata = true;
                    }else
                        {
                                //26-02-2014    JAAR si es una SIMULACION de chequeo de credito no necesita obligatoriamente los datos
                                this.billingdata  = false;
                                if(requestFromsimulation == true)
                                {
                                         system.debug('\n\n No_tiene_datos_de_facturacion_pero_es_simulacion');  
                                 Validate = true;
                                }
                        }
                }
                
            }
        }   
        
        return Validate;
    } 
    
    
     // aqui se debe tomar la lista de respuestas que esta a en SAP_CreditManagementClient           
    public List<CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness> getRespuestasChequeCredito() {
         listResult = new List<CL008_Sap_ConsCupoCredit_ObjectsSF.CreditWorthiness>();
         
                             
               
             if(mapRsChequearCred == null) return null;
             system.debug('\n\n mapRsChequearCred======>' + mapRsChequearCred);
             for(CL008_Sap_ConsCupoCredit_ObjectsSF.ResponseChequearCreditos i:mapRsChequearCred.values()) {
                listResult.add(i.parCreditWorthiness);
             }
         system.debug('\n\nlistResult======>' + listResult);
          return listResult;
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
    
    /*******************************************************************************
    *                               QUERY AREA
    *******************************************************************************/    
     public Quote getQuoteById(String CotizacionId){
        List<Quote> Quot = [SELECT Ciudad_venta__c,GrandTotal,Id,Name,OpportunityId,Opportunity.Account.Codigo_cuenta__c,
                                Opportunity.Account.Codigo_cliente_unico__c,Opportunity.Account.Name,Opportunity.Account.Numero_identificacion__c,TotalPrice 
                                FROM Quote 
                                where Id =:CotizacionId];     
        if(Quot.size()>0){
            return Quot.get(0);      
        }else{      
            return null;
        }   
    }
    
    //Control de Inventario -seccion, ciudad, tipo de inventario
     public list<Registro_de_Venta_Limitada__c> getVentaLimitada(String IdOportunity){
        List<Registro_de_Venta_Limitada__c> vtalimitada = [SELECT Activado__c,Activo_Relacionado__c,Partida_de_presupuesto__r.Seccion__c,Partida_de_presupuesto__r.Tipo_de_Inventario__c,Partida_de_presupuesto__r.Quote.OpportunityId,Ciudad_es_principal__c,Ciudad__c,Contrato__c,Control_de_Inventario__c,
                                                                  Control_de_Inventario__r.Cantidad_Reservada__c,Control_de_Inventario__r.total_reservado__c,
        														  Control_de_Inventario__r.Cantidad_Disponible__c,Control_de_Inventario__r.Ciudad__c,
    															  Control_de_Inventario__r.Seccion__c,Control_de_Inventario__r.Tipo_Inventario__c,Control_de_Inventario__r.Tipo_Inventario__r.Name,Estado__c,Id,Name,Partida_de_presupuesto__c,Precio__c,Seccion_principal__c,Tipo_de_Inventario__c 
                                                           FROM   Registro_de_Venta_Limitada__c
														   WHERE  Partida_de_presupuesto__r.Quote.OpportunityId =:IdOportunity];     
             
        return vtalimitada;
    }
    
      //Control de Inventario 
     public list<Control_de_Inventario__c> getControldeinventario(set<ID> setIdctrlinventario){
        List<Control_de_Inventario__c> ctrlinventario = [SELECT Cantidad_Disponible__c,Cantidad_Permitida__c,
        													    Cantidad_Reservada__c,Ciudad__c,Ciudad__r.Name,total_reservado__c,
        													      Id,
        												        Name,Seccion__c,Seccion__r.Name,Tipo_Inventario__c 
        												 FROM   Control_de_Inventario__c where Id IN : setIdctrlinventario];     
     return ctrlinventario;
    }
    
    
    //cuenta --------------------------------------------------------------
    public Account getAccountById(String Accountid){
        list<Account> acc = [SELECT AccountNumber,BillingCity,BillingCountry,Ciudad__c,Codigo_cliente_unico__c,Codigo_cuenta__c,CreatedById,CreatedDate,Id,Industry,Name,Numero_identificacion__c,OwnerId,Tipo_identificacion__c,Tipo_identificacion__r.Name,Identificacion__c,Requiere_Masterdata__c,Status_Masterdata__c 
                                                 FROM Account where id =:Accountid];
    
    if(acc.size()>0){
            return acc.get(0);      
        }else{      
            return null;
        } 
    }
    
      //Lead --------------------------------------------------------------
    public Lead getLeadById(String Leadid){
        list<Lead> mylead = [SELECT Status_Masterdata__c,Fecha_sincronizacion_SAP__c,Cliente_Bloqueado__c,Cupo_Asignado__c,Fecha_Validez_limite__c,Saldo_Disponible__c,Tipo_de_Riesgo__c,Name,Codigo_cliente_unico__c,Id,Nit__c,Tipo_identificacion__c,Tipo_identificacion__r.Name FROM Lead where id =:Leadid];
    
    if(mylead.size()>0){
            return mylead.get(0);      
        }else{      
            return null;
        } 
    } 
    
    //Oportunity ----------------------------------------------------------
     public Opportunity getOpportunity(String IdOportunity){
        List<Opportunity> myopp = [SELECT CreditCheckCode__c,Amount,Token_venta_en_linea__c,blocked_opportunity__c,RecordTypeId,StageName,CreditLimitValidUntilDate__c,Id,automaticresult__c,Fecha_Entregada_Fulfillment__c,IsCreditAnalysisRequired__c,IsCreditChecked__c,Unidad_de_Negocio__c,
                                                                          IsCreditExceptionAllowed__c,Fecha_cerrada_entregada_facturacion__c,Comentarios_fulfillment__c,Responsable_fulfillmet__c,Semaforostatus__c,Status_fulfillment__c,Account.Pendiente_pago__c,
                                                                          fecha_devuelta_fulfillment__c,Fecha_cerrada_fulfillment__c,SyncedQuoteId,Estado_No_conformidad__c,Estado_No_conformidad_Cartera__c,Comentarios_Cartera__c,Account.Codigo_cliente_unico__c,Autorizante__c,Contacto_Encargado_Web__c 
                                                           ,(SELECT GrandTotal,Id,IsSyncing,blocked_quote__c FROM Quotes WHERE IsSyncing = true)
                                                          FROM Opportunity 
                                  where Id =:IdOportunity];     
        if(myopp.size()>0){
            return myopp.get(0);      
        }else{      
            return null;
        }   
    }
    
    //Solicitude de credito asociadas ----------------------------------------------------------
     public list<Requestfinancial__c> getRequestfinancial(String IdOportunity, String codecheck){
        List<Requestfinancial__c> Reqfin = [SELECT Chequeo_vigente__c,Id,Idoportunity__c,Fecha_Entregada_Facturacion__c,Date_of_Approval__c FROM Requestfinancial__c
                                   where Idoportunity__c =:IdOportunity ];     
        if(Reqfin.size()>0){
            return Reqfin;     
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
    
      public void disabledService(){
        if(Test.isRunningTest()){
                system.debug('disabledservice!!');
                invoked = false;
                lanzarProceso();
        }
      }









public void clase_prueba()
    {
         
         
         
         
         String var;
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         // mil
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
         var='1';
        
    }  

}