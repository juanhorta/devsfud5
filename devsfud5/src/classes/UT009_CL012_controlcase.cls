/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Febrero 03 de 2014
*  Decripción:          Clase de prueba del proceso de chequeo de crédito con SAP
*  @version:            1.0
*
*  JSQP 01-07-2014      Se modifica clase de prueba para incluir el contador de modificaciones y de rediseños
*                        
* 
* ===================================================================================================================================
**/

@isTest (SeeAllData=true)
public with sharing class UT009_CL012_controlcase {

static testMethod void fnTest1() 
    {
        fnCrearData();
        Test.startTest();
        system.debug('prueba cerrar caso'  );
        Test.stopTest();
    }
    
 static void fnCrearData()
    {
        try{
               system.debug('Entro_a_fnCrearData');  
                //----
               Date DateOpp = date.newinstance(2136, 12, 31);   
               Date Datemen = date.newinstance(2012, 12, 31);
                
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
                     
                Account acc2 = new Account();
                    acc2.Activo__c = true;
                   
                    acc2.Name = 'cuenta2';
                    acc2.OwnerId= usr.Id;
                    acc2.Codigo_cliente_unico__c = 123;
                    acc2.Tipo_identificacion__c = tiponit.Id;
                    acc2.Numero_identificacion__c= '80048577';
                    insert acc2;  
                
                
                // JSQP 01-07-2014      Se modifica clase de prueba para incluir el contador de modificaciones y de rediseños
                    
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
                 
                // JSQP 01-07-2014      Se modifica clase de prueba para incluir el contador de modificaciones y de rediseños
                    
                Asset activo = new Asset();       
                    activo.Name = '2014_23_May_ORO_Suscripción SaludGurú_Migracion';
                    activo.Codigo_activo__c = 12345679;
                    activo.AccountId = acc1.id;
                    activo.Status = '01. Creado'; 
                    activo.Product2Id = prod3.Id;               
                    activo.Identificador__c = 'MES1';
                    activo.Nivel_de_Satisfaccion__c = 'SATISFECHO';
                    activo.Etapa__c = 'ADOPCION';
                    activo.Area_Causal__c = 'Diseño';
                    activo.Causal__c = 'ASESORIA DISEÑO';
                    insert activo;
                    system.debug('creamos_el_activo' + activo);         
                    
                Asset activo2 = new Asset();       
                    activo2.Name = '2014_23_May_ORO_Suscripción SaludGurú_Migracion';
                    activo2.Codigo_activo__c = 12345679;
                    activo2.AccountId = acc1.id;
                    activo2.Status = '01. Creado'; 
                    activo2.Product2Id = prod3.Id;               
                    activo2.Identificador__c = 'MES1';
                    activo2.Nivel_de_Satisfaccion__c = 'SATISFECHO';
                    activo2.Etapa__c = 'ADOPCION';
                    activo2.Area_Causal__c = 'Diseño';
                    activo2.Causal__c = 'ASESORIA DISEÑO';
                    activo2.Numero_de_modificaciones__c = 2;
                    activo2.Numero_de_redisenos__c = 2;
                    insert activo2;
                    system.debug('creamos_el_activo2' + activo2);                               
                                              
                system.debug('comienza creacion del caso1 ');     
               
               
                // JSQP 01-07-2014      Se modifica clase de prueba para incluir el contador de modificaciones y de rediseños
                
                Tipificacion__c ObjTipif_Modificacion  = [SELECT ID, NAME FROM Tipificacion__c WHERE NAME = 'Modificación de producto' limit 1];
                Tipificacion__c ObjTipif_Rediseno      = [SELECT ID, NAME FROM Tipificacion__c WHERE NAME = 'Rediseño página web' limit 1];
                Tipificacion__c ObjTipif_Seguimiento   = [SELECT ID, NAME FROM Tipificacion__c WHERE NAME = 'Seguimiento a caso' and Unidad_Soluciones_Digitales__c = true limit 1];                                          
                      
                case caso1 = new case();
                    caso1.AccountId = acc1.id;
                    caso1.Description = 'mi caso prueba';
                    caso1.Status = 'Nuevo';
                    caso1.Origin = 'Telefónico';
                    caso1.Priority = 'Media';
                    caso1.Ciudad_de_reclamacion__c= city.id;
                    caso1.Regional__c = 'Centro';
                    caso1.Nombres_contacto__c = 'Usuario 1';
                    caso1.Apellidos_contacto__c= 'apellidos';
                    caso1.Telefono_contacto__c = '123456';
                    caso1.Correo_electronico_del_contacto__c = 'mimail@yahoo.es';
                    caso1.Puntaje__c = '300';
                    caso1.Detalle_tipo_de_solicitud__c = ObjTipif_Seguimiento.ID; 
                    caso1.Activo_relacionado__c = activo.ID;
                    caso1.Familia_de_productos__c = 'Soluciones Web';
                    insert caso1;
                    system.debug('crea caso1 ' + caso1);   
                
                case subcaso1 = new case();
                    subcaso1.AccountId = acc1.id;
                    subcaso1.Description = 'mi subcaso prueba';
                    subcaso1.Status = 'Nuevo';
                    subcaso1.Origin = 'Telefónico';
                    subcaso1.Priority = 'Media';
                    subcaso1.Ciudad_de_reclamacion__c= city.id;
                    subcaso1.Regional__c = 'Centro';
                    subcaso1.ParentId = caso1.id;
                    subcaso1.Nombres_contacto__c = 'Usuario 1';
                    subcaso1.Apellidos_contacto__c= 'apellidos';
                    subcaso1.Telefono_contacto__c = '123456';
                    subcaso1.Correo_electronico_del_contacto__c = 'mimail@yahoo.es';
                    subcaso1.Puntaje__c = '300';
                    subcaso1.Familia_de_productos__c = 'Soluciones Web';
                    subcaso1.Detalle_tipo_de_solicitud__c = ObjTipif_Seguimiento.ID; 
                    subcaso1.Activo_relacionado__c = activo.ID;
                    insert subcaso1;
                    system.debug('crea subcaso1 ' + subcaso1);   
                    
                    caso1.Status = 'Cerrado';
                    update caso1;
                                                              
                
                case caso2 = new case();
                    caso2.AccountId = acc1.id;
                    caso2.Description = 'mi caso prueba 2';
                    caso2.Status = 'Nuevo';
                    caso2.Origin = 'Telefónico';
                    caso2.Priority = 'Media';
                    caso2.Ciudad_de_reclamacion__c= city.id;
                    caso2.Regional__c = 'Centro';
                    caso2.Nombres_contacto__c = 'Usuario 1';
                    caso2.Apellidos_contacto__c= 'apellidos';
                    caso2.Telefono_contacto__c = '123456';
                    caso2.Correo_electronico_del_contacto__c = 'mimail@yahoo.es';
                    caso2.Activo_relacionado__c = activo.ID;
                    caso2.Detalle_tipo_de_solicitud__c = ObjTipif_Modificacion.ID;
                    caso2.Familia_de_productos__c = 'Soluciones Web';
                    caso2.Puntaje__c = '300';
                insert caso2;     
                            
                system.debug('crea caso2 ' + caso2);   
                
                //caso2.Detalle_tipo_de_solicitud__c = ObjTipif_Seguimiento.ID;     
                //update caso2;   

                //caso2.Detalle_tipo_de_solicitud__c = ObjTipif_Modificacion.ID;     
                //update caso2; 
                                
                caso2.Detalle_tipo_de_solicitud__c = ObjTipif_Rediseno.ID;     
                update caso2;
                        
                caso2.Detalle_tipo_de_solicitud__c = ObjTipif_Seguimiento.ID;     
                update caso2;                               
                
                
                case caso3 = new case();
                    caso3.AccountId = acc1.id;
                    caso3.Description = 'mi caso prueba 2';
                    caso3.Status = 'Nuevo';
                    caso3.Origin = 'Telefónico';
                    caso3.Priority = 'Media';
                    caso3.Ciudad_de_reclamacion__c= city.id;
                    caso3.Regional__c = 'Centro';
                    caso3.Nombres_contacto__c = 'Usuario 1';
                    caso3.Apellidos_contacto__c= 'apellidos';
                    caso3.Telefono_contacto__c = '123456';
                    caso3.Correo_electronico_del_contacto__c = 'mimail@yahoo.es';
                    caso3.Activo_relacionado__c = activo.ID;
                    caso3.Detalle_tipo_de_solicitud__c = ObjTipif_Rediseno.ID;
                    caso3.Puntaje__c = '300';
                    caso3.Familia_de_productos__c = 'Soluciones Web';
                insert caso3;     

                //caso3.Detalle_tipo_de_solicitud__c = ObjTipif_Seguimiento.ID;     
                //update caso3;   
                
                caso3.Detalle_tipo_de_solicitud__c = ObjTipif_Modificacion.ID;     
                update caso3;   
            
                //caso3.Detalle_tipo_de_solicitud__c = ObjTipif_Rediseno.ID;     
                //update caso3;
            
                caso3.Detalle_tipo_de_solicitud__c = ObjTipif_Seguimiento.ID;     
                update caso3;               


                case caso4= new case();
                    caso4.AccountId = acc1.id;
                    caso4.Description = 'mi caso prueba 2';
                    caso4.Status = 'Nuevo';
                    caso4.Origin = 'Telefónico';
                    caso4.Priority = 'Media';
                    caso4.Ciudad_de_reclamacion__c= city.id;
                    caso4.Regional__c = 'Centro';
                    caso4.Nombres_contacto__c = 'Usuario 1';
                    caso4.Apellidos_contacto__c= 'apellidos';
                    caso4.Telefono_contacto__c = '123456';
                    caso4.Correo_electronico_del_contacto__c = 'mimail@yahoo.es';
                    caso4.Activo_relacionado__c = activo2.ID;
                    caso4.Detalle_tipo_de_solicitud__c = ObjTipif_Rediseno.ID;
                    caso4.Puntaje__c = '300';
                    caso4.Familia_de_productos__c = 'Soluciones Web';
                insert caso4;     

                //caso4.Detalle_tipo_de_solicitud__c = ObjTipif_Seguimiento.ID;     
                //update caso4;   
                
                caso4.Detalle_tipo_de_solicitud__c = ObjTipif_Modificacion.ID;     
                update caso4;   
            
                //caso4.Detalle_tipo_de_solicitud__c = ObjTipif_Rediseno.ID;     
                //update caso4;
            
                caso4.Detalle_tipo_de_solicitud__c = ObjTipif_Seguimiento.ID;     
                update caso4;  
           
        }catch(System.exception ex)
        {
            System.debug('\n\n ##Error##' + ex + '\n\n');
        }   
    }
}