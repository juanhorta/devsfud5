/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Jairo Guzman
*  Fecha:               13 Enero 2013
*  Decripción:          Trigger Calculate Life time after asset is updated,TG003_Asset_UpdateLifeTime: call AssetsLifeTime class
*  @version:            1.0
*  @version:            1.1 JAAR 26-03-2014 Se reemplaza por la linea "Asset[] entries = Trigger.new" para consumnir menos querys
*  @version:            01-07-2014 JAAR  Modificacion para desactivar registros de ventas limitadas y liberar el control de inventario
* ===================================================================================================================================
**/


trigger TG003_Asset_UpdateLifeTime on Asset (after update, after insert) {
 
  if(!CL002_AssetsProcessing.hasAlreadyDone())
  {
  	System.debug('\n\n****  Queries_antes_de_trigger: ' + Limits.getQueries()); 
	  Set<Id> AssetId = new Set<Id>();
	 
	  for (Asset oAsset : Trigger.new){ 
	  		
	        AssetID.add(oAsset.Id);
	        system.debug('JDDEBUG2: entries: '+AssetID);
	   
	  }
	  
	  integer size = AssetId.size();
	  system.debug('JDDEBUG2: size: '+size);
	 
	 if(size==1)
	 {
	 	
	  system.debug('Trigger_new_Status: '+ Trigger.new[0].Status);
		if(Trigger.new[0].Status == CL000_Utils.C_FinalizedAssetStatus && Trigger.new[0].UsageEndDate == null)
		  {
		      Asset[] entries = 
		        [select id, 
		        		status, 
		        		product2Id, 
		        		InstallDate,
		                UsageEndDate,
		                Activo_relacionado__c,
		                Fecha_primera_activacion__c,
		                Fecha_vencimiento_anterior__c
		                from Asset 
		         where id in :AssetId];
		      System.debug('\n\n****  Queries_invocando_el_trigger: ' + Limits.getQueries()); 
		      //entries = Trigger.new;  
		     CL002_AssetsProcessing.AssetsLifeTime(entries);
		  }
		 
		 CL015_AssetHistory.upsertAssetHistory(Trigger.new, Trigger.old);
		 //JAAR - 01-07-2014 Modificacion para desactivar registros de ventas limitadas y liberar el control de inventario
	    if(Trigger.isUpdate){
	    	if(Trigger.new[0].Status == '04. Desactivado' ||Trigger.new[0].Status == '06. Anulado' ){
	    	CL002_AssetsProcessing.freestate(Trigger.new[0].Id);
	      }
	    }
	    
	    CL002_AssetsProcessing.setAlreadyDone();	// Cambia la bandera de control de ejecución para evitar que vuelva a ejecutarse el trigger
	    
	 }
  }
	 
}