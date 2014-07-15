/*
*	Controller for opportunity s3 file 
*	15 Enero 2013 - Jairo Guzman - control new file creation into amazon S3 from opportunity 
*/

public class CTR001_NewS3File_Opportunity_Step0 {
	
	ApexPages.StandardController CtxController;
	public CTR001_NewS3File_Opportunity_Step0(ApexPages.StandardController stdController) {
		CtxController = stdController;
	}

	public pageReference NextStep0() {
		
		try 
		{
			//get base folder
			string strBaseFolder = GetBaseFolder();
			if(strBaseFolder != null){
				
				//get bucket
				string strBucket = '';
				for(Schema.PicklistEntry pl: Archivo_por_oportunidad__c.Bucket__c.getDescribe().getPicklistValues()){
					if(pl.isActive() && pl.isDefaultValue()) strBucket = pl.getValue();
				}
				
				//create new file object
				string strFileId = 
					CTR001_NewS3File_Step1.CreateAmazonFileRecord
						(string.valueOf(CtxController.getRecord().get('Name')), 
						strBucket, 
						false,
						string.valueOf(CtxController.getRecord().get('Extension__c')), 
						CL000_Utils.C_OpportunityFilePermision, 
						string.valueOf(CtxController.getRecord().get('Tipo_contenido__c')), 
						strBaseFolder);
			
				if(strFileId != null){
					
					//create new file opportunity object
					Archivo_por_oportunidad__c FileOp = new Archivo_por_oportunidad__c();
					
					FileOp.Name = string.valueOf(CtxController.getRecord().get('Name'));
					FileOp.Archivo_amazon_s3__c = strFileId;
					FileOp.Bucket__c = strBucket;		
					FileOp.Extension__c = string.valueOf(CtxController.getRecord().get('Extension__c'));			
					FileOp.Oportunidad__c = string.valueOf(CtxController.getRecord().get('Oportunidad__c'));
					FileOp.Tipo_contenido__c = string.valueOf(CtxController.getRecord().get('Tipo_contenido__c'));
					
					insert FileOp;
					
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
	public string GetBaseFolder(){
		
		//get opportunity info
		opportunity[] oOp = 
			[select Account.Codigo_cuenta__c,
					Numero_contrato__c
			from 	opportunity
			where 	id =: string.valueOf(CtxController.getRecord().get('Oportunidad__c'))
			limit 	1];
	
		if(oOp.size() > 0){
			
			string oRetorno = 
				oOp[0].Account.Codigo_cuenta__c + '/Oportunidades/' +
				oOp[0].Numero_contrato__c;
				 
			return oRetorno;
		}
		else
		{
			 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No se encontro una oportunidad a la cual relacionar el archivo.');
			 ApexPages.addMessage(errorMsg);
		}
		return null;
	}
}