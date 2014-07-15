/*
*	Controller for production movement s3 file 
*	19 Enero 2013 - Jairo Guzman - control new file creation into amazon S3 from production movement 
*/

public class CTR001_NewS3File_ProductionMov_Step0 {
	
	ApexPages.StandardController CtxController;
	public CTR001_NewS3File_ProductionMov_Step0(ApexPages.StandardController stdController) {
		CtxController = stdController;
	}
	
	public pageReference NextStep0() {
		
		try{
			//get base folder
			string strBaseFolder = GetBaseFolder();
			if(strBaseFolder != null){
				
				//get bucket
				string strBucket = '';
				for(Schema.PicklistEntry pl: Archivo_por_movimiento_produccion__c.Bucket__c.getDescribe().getPicklistValues()){
					if(pl.isActive() && pl.isDefaultValue()) strBucket = pl.getValue();
				}
				
				//create new file object
				string strFileId = 
					CTR001_NewS3File_Step1.CreateAmazonFileRecord
						(string.valueOf(CtxController.getRecord().get('Name')), 
						strBucket, 
						boolean.valueOf(CtxController.getRecord().get('Es_carpeta__c')),
						string.valueOf(CtxController.getRecord().get('Extension__c')), 
						CL000_Utils.C_ProductionMovFilePermision, 
						string.valueOf(CtxController.getRecord().get('Tipo_contenido__c')), 
						strBaseFolder);
						
				if(strFileId != null){
					
					//create new file opportunity object
					Archivo_por_movimiento_produccion__c FileMov = new Archivo_por_movimiento_produccion__c();
					
					FileMov.Name = string.valueOf(CtxController.getRecord().get('Name'));
					FileMov.Archivo_amazon_s3__c = strFileId;
					FileMov.Bucket__c = strBucket;
					FileMov.Es_carpeta__c = boolean.valueOf(CtxController.getRecord().get('Es_carpeta__c'));				
					FileMov.Extension__c = string.valueOf(CtxController.getRecord().get('Extension__c'));
					FileMov.Movimiento_produccion__c = string.valueOf(CtxController.getRecord().get('Movimiento_produccion__c'));
					FileMov.Tipo_contenido__c = string.valueOf(CtxController.getRecord().get('Tipo_contenido__c'));
					
					insert FileMov;
					
					//redirect to upload amazon file page
					PageReference pgRef = new PageReference('/apex/PG001_NewS3File_Step1');
																   
					//set selected user values and variables
					pgRef.getParameters().put('FileId',strFileId);
					pgRef.getParameters().put('retURL',ApexPages.currentPage().getParameters().get('retURL'));
					
					pgRef.setRedirect(true);
					return pgRef;	
				}						
			}
		}
		catch(Exception er){
			
			 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, er.getMessage());
			 ApexPages.addMessage(errorMsg);
			 
		}
		return null;
	}
	/*get base folder value*/
	private string GetBaseFolder(){
		
		//get opportunity info
		Movimiento_produccion__c[] PrMov = 
			[select	Activo__r.AccountId,
        			Activo__r.Codigo_activo__c,
        			Codigo_movimiento_produccion__c
			from 	Movimiento_produccion__c
			where   Activo__r.id != null
        			and Activo__r.AccountId != null
					and id =: string.valueOf(CtxController.getRecord().get('Movimiento_produccion__c'))
			limit 	1];
	
		if(PrMov.size() > 0){
			
			Account[] Ac = 
				[select Codigo_cuenta__c
				from 	Account
				where 	id =: PrMov[0].Activo__r.AccountId
				limit 	1];
				
			if(Ac.size() > 0){
			
				string oRetorno = 
					Ac[0].Codigo_cuenta__c + '/Movimiento_produccion__c/' +
					string.valueOf(PrMov[0].Activo__r.Codigo_activo__c) + '_' +
					string.valueOf(PrMov[0].Codigo_movimiento_produccion__c);
				 
				return oRetorno;
			}
			else{
			 	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No se encontro una cuenta a la cual relacionar el archivo.');
			 	ApexPages.addMessage(errorMsg);
			}
		}
		else{
			 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No se encontro un movimiento de producción al cual relacionar el archivo.');
			 ApexPages.addMessage(errorMsg);
		}
		return null;
	}
}