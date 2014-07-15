/*
*   Controller for assets s3 file 
*   5 Febrero 2014 - Sabrina Isaza Ferro - control new file creation into amazon S3 from asset
*/

public class CTR001_NewS3File_Asset_Step0 
{
	public string period;
	
	ApexPages.StandardController CtxController;
	public CTR001_NewS3File_Asset_Step0(ApexPages.StandardController stdController) 
	{
		CtxController = stdController;
	}
	
	public pageReference NextStep0() 
	{
		try 
		{
			//get base folder
			string strBaseFolder = GetBaseFolder();
			if(strBaseFolder != null){
				
				//get bucket
				string strBucket = '';
				for(Schema.PicklistEntry pl: Archivo_por_activo__c.Bucket__c.getDescribe().getPicklistValues()){
					if(pl.isActive() && pl.isDefaultValue()) strBucket = pl.getValue();
				}
				
				//create new file object
				string strFileId = CTR001_NewS3File_Step1.CreateAmazonFileRecord
						          (string.valueOf(CtxController.getRecord().get('Name')), 
						           strBucket, 
						           false,
						           string.valueOf(CtxController.getRecord().get('Extension__c')), 
						           CL000_Utils.C_AssetFilePermision, 
						           string.valueOf(CtxController.getRecord().get('Tipo_contenido__c')), 
						           strBaseFolder);
			
				if(strFileId != null)
				{					
					//create new file asset object					
					Archivo_por_activo__c FileOp = new Archivo_por_activo__c();
					
					FileOp.Name = string.valueOf(CtxController.getRecord().get('Name'));
					FileOp.Archivo_amazon_s3__c = strFileId;
					FileOp.Bucket__c = strBucket;		
					FileOp.Extension__c = string.valueOf(CtxController.getRecord().get('Extension__c'));			
					FileOp.Activo__c = string.valueOf(CtxController.getRecord().get('Activo__c'));
					FileOp.Tipo_contenido__c = string.valueOf(CtxController.getRecord().get('Tipo_contenido__c'));
					FileOp.Periodo__c = period;
					
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
		catch(Exception er)
		{
			 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, er.getMessage());
			 ApexPages.addMessage(errorMsg);
		}
		return null;
	}
	
	/*get base folder value*/
	public string GetBaseFolder()
	{
		//get asset info
		asset[] assets = 
			[select AccountId,
			        Codigo_activo__c,
			        Account.Codigo_cuenta__c,
			        Identificador__c
			 from 	asset 
			 where 	id =: string.valueOf(CtxController.getRecord().get('Activo__c'))
			 limit 	1];		

		if(assets.size() > 0)
		{
			period=assets[0].Identificador__c;
			string oRetorno = assets[0].Account.Codigo_cuenta__c + '/Activos/' + assets[0].Codigo_activo__c;
			return oRetorno;
		}
		else
		{
			 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No se encontro un activo al cual relacionar el archivo.');
			 ApexPages.addMessage(errorMsg);
		}
		return null;
	}
}