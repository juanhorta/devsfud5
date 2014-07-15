/*
Sebastian Quintero Parra.
Junio - 12 - 2014

Trigger que cuenta en el activo el numero de veces que se ha creado un caso con la tipificación: 
- Modificación de producto 
- Rediseño página web 

*/

trigger TG009_CuentaModificaciones on Case (after insert, after update) {

     public Asset ObjActivo {get;set;}

     if(Trigger.isAfter  && Trigger.isUpdate ){
     
        Case objOld = Trigger.old[0];
        Case objNew = Trigger.new[0];
        system.debug('miCasoUPDATE  ' + objOld);
        
        if(objOld.Detalle_tipo_de_solicitud__c != null && objNew.Detalle_tipo_de_solicitud__c != null)  
        {          
	        if(objOld.Detalle_tipo_de_solicitud__c != objNew.Detalle_tipo_de_solicitud__c){
	            
	            if(objNew.Activo_relacionado__c != null || objOld.Activo_relacionado__c != null){
	            
		            ObjActivo = [ SELECT Id, Numero_de_modificaciones__c, Numero_de_redisenos__c FROM Asset WHERE ID =:objNew.Activo_relacionado__c];
		            system.debug('ObjActivo  ' + ObjActivo);
		            	            
		            Tipificacion__c ObjTipif = [SELECT NAME FROM Tipificacion__c WHERE ID =:objNew.Detalle_tipo_de_solicitud__c];
		            system.debug('ObjTipif  ' + ObjTipif);
		            
		            //El trigger solo aplica para las modificaciones            
		            if(objNew.tipo_de_solicitud__c == 'Modificacion'){
		
		                //Si cambia de tipificacion pero el tipo de solicitud sigue siendo Modificacion debe restarle 1 al anterior 
		                if(objNew.Detalle_tipo_de_solicitud__c != objOld.Detalle_tipo_de_solicitud__c){
		                    
		                    Tipificacion__c ObjTipif2 = [SELECT NAME FROM Tipificacion__c WHERE ID =:objOld.Detalle_tipo_de_solicitud__c];                
		                    if(ObjTipif2.NAME == 'Modificación de producto' || ObjTipif2.NAME == 'Modificación Datos direccionadores'){
		                        system.debug('entro_UPDATE_Modificación de producto_MENOS_1 ' + objOld);                                                            
		                        
		                        if(ObjActivo.Numero_de_modificaciones__c == NULL || ObjActivo.Numero_de_modificaciones__c == 0 || ObjActivo.Numero_de_modificaciones__c - 1 <= 0){
		                            ObjActivo.Numero_de_modificaciones__c = 0;
		                        }else{                    
		                                ObjActivo.Numero_de_modificaciones__c = ObjActivo.Numero_de_modificaciones__c - 1;                                                                  
		                        }                                        
		                                            
		                        try{
		                            update ObjActivo; 
		                            system.debug('modifico_miCaso  ' + ObjActivo);
		                        }catch(system.exception e){}
		                    }                   
		                                        
		                    if(ObjTipif2.NAME == 'Rediseño página web'){
		                        system.debug('entro_UPDATE_Rediseño página web_MENOS_1 ' + objOld);                                                         
		                        system.debug('Aquiii2 ' + ObjActivo.Numero_de_redisenos__c);
		                        if(ObjActivo.Numero_de_redisenos__c == NULL || ObjActivo.Numero_de_redisenos__c == 0 || ObjActivo.Numero_de_redisenos__c - 1 <= 0){
		                            ObjActivo.Numero_de_redisenos__c = 0;
		                        }else{         
		                                ObjActivo.Numero_de_redisenos__c = ObjActivo.Numero_de_redisenos__c - 1;                        
		                        }                                         
		                                            
		                        try{
		                            update ObjActivo; 
		                            system.debug('modifico_miCaso  ' + ObjActivo);
		                        }catch(system.exception e){}
		                    }             
		                } 
		
		                if(ObjTipif.NAME == 'Modificación de producto' || ObjTipif.NAME == 'Modificación Datos direccionadores'){                
		                    system.debug('entro_UPDATE_Modificación de producto_MAS_1 ');                                                          
		                    
		                    if(ObjActivo.Numero_de_modificaciones__c == NULL || ObjActivo.Numero_de_modificaciones__c == 0){
		                        ObjActivo.Numero_de_modificaciones__c = 1;
		                    }else{
		                        ObjActivo.Numero_de_modificaciones__c = ObjActivo.Numero_de_modificaciones__c + 1;
		                    }
		                                                            
		                    try{
		                        update ObjActivo; 
		                        system.debug('modifico_miCaso  ' + ObjActivo);
		                    }catch(system.exception e){}                                 
		                }
		                
		                if(ObjTipif.NAME == 'Rediseño página web'){                    
		                    system.debug('entro_UPDATE_Rediseño página web_MAS_1 '); 
		                    system.debug('Aquiii ' + ObjActivo);
		                    if(ObjActivo.Numero_de_redisenos__c == NULL || ObjActivo.Numero_de_redisenos__c == 0 ){
		                        ObjActivo.Numero_de_redisenos__c = 1;
		                    }else{
		                        ObjActivo.Numero_de_redisenos__c = ObjActivo.Numero_de_redisenos__c + 1;
		                    }                                                                                                
		                                        
		                    try{
		                        update ObjActivo; 
		                        system.debug('modifico_miCaso  ' + ObjActivo);
		                    }catch(system.exception e){}                    
		                }
		                                               
		            }else{
		                
		                Tipificacion__c ObjTipif2 = [SELECT NAME FROM Tipificacion__c WHERE ID =:objOld.Detalle_tipo_de_solicitud__c];
		                system.debug('ObjTipif2  ' + ObjTipif2);
		                
		                if(ObjTipif2.NAME == 'Modificación de producto' || ObjTipif2.NAME == 'Modificación Datos direccionadores'){
		                    system.debug('entro_UPDATE_Modificación de producto_MENOS_1 ' + objOld);                                                            
		                    
		                    if(ObjActivo.Numero_de_modificaciones__c == NULL || ObjActivo.Numero_de_modificaciones__c == 0 || ObjActivo.Numero_de_modificaciones__c - 1 <= 0){
		                        ObjActivo.Numero_de_modificaciones__c = 0;
		                    }else{                    
		                            ObjActivo.Numero_de_modificaciones__c = ObjActivo.Numero_de_modificaciones__c - 1;                                                                  
		                    }                                        
		                                        
		                    try{
		                        update ObjActivo; 
		                        system.debug('modifico_miCaso  ' + ObjActivo);
		                    }catch(system.exception e){}
		                }
		                
		                if(ObjTipif2.NAME == 'Rediseño página web'){
		                    system.debug('entro_UPDATE_Rediseño página web_MENOS_1 ' + objOld);                                                         
		                    system.debug('Aquiii2 ' + ObjActivo.Numero_de_redisenos__c);
		                    if(ObjActivo.Numero_de_redisenos__c == NULL || ObjActivo.Numero_de_redisenos__c == 0 || ObjActivo.Numero_de_redisenos__c - 1 <= 0){
		                        ObjActivo.Numero_de_redisenos__c = 0;
		                    }else{         
		                            ObjActivo.Numero_de_redisenos__c = ObjActivo.Numero_de_redisenos__c - 1;                        
		                    }                                         
		                                        
		                    try{
		                        update ObjActivo; 
		                        system.debug('modifico_miCaso  ' + ObjActivo);
		                    }catch(system.exception e){}
		                }                                                                             
		            }
		        }
	        }
	     }
     }
     
     if(Trigger.isAfter && Trigger.isInsert){
        
        Case objNew = Trigger.new[0];
        system.debug('miCasoNEW  ' + objNew);               
        
        if(objNew.tipo_de_solicitud__c == 'Modificacion' ){
            
            ObjActivo = [ SELECT Id, name, Numero_de_modificaciones__c FROM Asset WHERE id =:objNew.Activo_relacionado__c];
            system.debug('ObjActivo  ' + ObjActivo);
            
            Tipificacion__c ObjTipif = [SELECT NAME FROM Tipificacion__c WHERE ID =:objNew.Detalle_tipo_de_solicitud__c];
            system.debug('ObjTipif  ' + ObjTipif);
             
            if(ObjTipif.NAME == 'Modificación de producto' || ObjTipif.NAME == 'Modificación Datos direccionadores'){                
                system.debug('entro_miCaso  ' + objNew);                            
                                
                if(ObjActivo.Numero_de_modificaciones__c == NULL || ObjActivo.Numero_de_modificaciones__c == 0){
                    ObjActivo.Numero_de_modificaciones__c = 1;                  
                }
                                                              
                try{
                    update ObjActivo; 
                    system.debug('modifico_miCaso  ' + ObjActivo);
                }catch(system.exception e){}
            }
            
            if(ObjTipif.NAME == 'Rediseño página web'){                
                system.debug('entro_miCaso  ' + objNew); 
                
                ObjActivo = [ SELECT Id, name, Numero_de_redisenos__c FROM Asset WHERE id =:objNew.Activo_relacionado__c];
                system.debug('entro_ObjActivo  ' + ObjActivo);
                
                if(ObjActivo.Numero_de_redisenos__c == NULL || ObjActivo.Numero_de_redisenos__c == 0){                          
                   ObjActivo.Numero_de_redisenos__c = 1;
                }
                                
                try{
                    update ObjActivo; 
                    system.debug('modifico_miActivo  ' + ObjActivo);
                }catch(system.exception e){}
            }                                                
        }
    }   
}