public with sharing class CL015_AssetHistory {
    
    public static void upsertAssetHistory(Asset[] newAsset, Asset[] oldAsset){
   string assetID = newAsset[0].Id;
   system.debug('jddebugha: oldAsset: '+oldAsset);
   system.debug('jddebugha: newasset: '+newAsset);
   
   if(oldAsset == NULL){
        string message = 'Creado';
        insHistory(message,assetID,'Etapa');
   }else{
   	

        	if(newAsset[0].Status != oldAsset[0].Status){
	       		insHistory('El estado ha cambiado de '+oldAsset[0].Status+' a '+ newAsset[0].Status,assetID, 'Etapa');
        	}
        	
        	if(newAsset[0].UsageEndDate != oldAsset[0].UsageEndDate && oldAsset[0].UsageEndDate != null){        		
        		DateTime newDateValue = newAsset[0].UsageEndDate;
        		DateTime oldDateValue = oldAsset[0].UsageEndDate;
        		        		
        		string new_UsageEndDate;
        		string old_UsageEndDate;
        		
        		if(newAsset[0].UsageEndDate != null ){        			
        			new_UsageEndDate = newDateValue.addHours(5).format('yyyy-MM-dd');        			
        		}
				if(oldAsset[0].UsageEndDate != null){
        			old_UsageEndDate = oldDateValue.addHours(5).format('yyyy-MM-dd');
        		}
				if(newAsset[0].UsageEndDate == null){
        			new_UsageEndDate = 'null';
        		}			
        		if(oldAsset[0].UsageEndDate == null){
        			old_UsageEndDate = 'null';
        		}
        		
        		insHistory('La fecha final de vigencia ha cambiado de '+ old_UsageEndDate +' a '+ new_UsageEndDate,assetID, 'Fecha Vigencia');
        	}  
        
            
        	string nivel_O = '';	  
	        string nivel_N = '';     
	        string etapa_O = '';
	        string etapa_N = '';	        
	        string areaCausal_O = '';
	        string areaCausal_N = '';	
	        string causal_O = '';	
	        string causal_N = '';	        
	        	         	
	        if(oldAsset[0].Nivel_de_Satisfaccion__c != null){
	        	nivel_O = oldAsset[0].Nivel_de_Satisfaccion__c;
	        }
	        if(newAsset[0].Nivel_de_Satisfaccion__c != null){
	        	nivel_N = newAsset[0].Nivel_de_Satisfaccion__c;
	        }
	        	        
	        if(oldAsset[0].Etapa__c != null){
	        	etapa_O = oldAsset[0].Etapa__c;
	        }
	        if(newAsset[0].Etapa__c != null){
	        	etapa_N = newAsset[0].Etapa__c;
	        }
	        	        	
	        if(oldAsset[0].Area_Causal__c != null){
	        	areaCausal_O = oldAsset[0].Area_Causal__c;
	        }
	        if(newAsset[0].Area_Causal__c != null){
	        	areaCausal_N = newAsset[0].Area_Causal__c;
	        }	
	        
	        if(oldAsset[0].Causal__c != null){
	        	causal_O = oldAsset[0].Causal__c;
	        }
	        if(newAsset[0].Causal__c != null){
	        	causal_N = newAsset[0].Causal__c;
	        }	
                  
		if(newAsset[0].Identificador__c == 'MES1' ){
	        if(newAsset[0].Identificador__c != oldAsset[0].Identificador__c ||
	           newAsset[0].Nivel_de_Satisfaccion__c != oldAsset[0].Nivel_de_Satisfaccion__c ||
	           newAsset[0].Etapa__c!= oldAsset[0].Etapa__c||
	           newAsset[0].Area_Causal__c != oldAsset[0].Area_Causal__c ||
	           newAsset[0].Causal__c != oldAsset[0].Causal__c
	        ){
	        	      
	        
	        insHistory('Antes 1: ' + oldAsset[0].Identificador__c  
	        + ' , ' + nivel_O
	        + ' , ' + etapa_O
	        + ' , ' + areaCausal_O
	        + ' , ' + causal_O
	        + ' /Despues 1: '+ newAsset[0].Identificador__c
	        + ' , ' + nivel_N
	        + ' , ' + etapa_N
	        + ' , ' + areaCausal_N
	        + ' , ' + causal_N
	        ,assetID, 'Postventa');
	        }
		}else{
			if(newAsset[0].Identificador__c != oldAsset[0].Identificador__c){
		        insHistory('Antes 2: ' + oldAsset[0].Identificador__c  
		        + ' , ' + nivel_O
		        + ' , ' + etapa_O
		        + ' , ' + areaCausal_O
		        + ' , ' + causal_O
		        + ' /Despues 2: '+ newAsset[0].Identificador__c
		        + ' , ' + nivel_N
		        + ' , ' + etapa_N
		        + ' , ' + areaCausal_N
		        + ' , ' + causal_N
		        ,assetID, 'Postventa');
		        }
		}
     }
   }
   
   public static void insHistory(string message, string assetid, string Categoria){
        AssetHistory__c Historial = new AssetHistory__c();
        Historial.Asset__c= assetid;
        Historial.Fecha__c= System.now();
        Historial.Usuario__c= UserInfo.getUserId();
        Historial.Accion__c = message;
        Historial.Categoria__c = Categoria;
        insert Historial;
        system.debug('Historial--> ' + Historial);	
   }
}