/*
*   Controller for case s3 file 
*   11 Marzo 2014 - Sabrina Isaza Ferro - control new file creation into amazon S3 from case
*/

public class CTR001_NewS3File_Case_Step0 
{
	ApexPages.StandardController CtxController;
	public CTR001_NewS3File_Case_Step0(ApexPages.StandardController stdController) 
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
				for(Schema.PicklistEntry pl: Archivo_por_caso__c.Bucket__c.getDescribe().getPicklistValues()){
					if(pl.isActive() && pl.isDefaultValue()) strBucket = pl.getValue();
				}
				
				//create new file object
				string strFileId = CTR001_NewS3File_Step1.CreateAmazonFileRecord
						          (string.valueOf(CtxController.getRecord().get('Name')), 
						           strBucket, 
						           false,
						           string.valueOf(CtxController.getRecord().get('Extension__c')), 
						           CL000_Utils.C_CaseFilePermision, 
						           string.valueOf(CtxController.getRecord().get('Tipo_contenido__c')), 
						           strBaseFolder);
			
				if(strFileId != null)
				{					
					//create new file case object					
					Archivo_por_caso__c FileOp = new Archivo_por_caso__c();
					
					FileOp.Name = string.valueOf(CtxController.getRecord().get('Name'));
					FileOp.Archivo_amazon_s3__c = strFileId;
					FileOp.Bucket__c = strBucket;		
					FileOp.Extension__c = string.valueOf(CtxController.getRecord().get('Extension__c'));			
					FileOp.Caso__c = string.valueOf(CtxController.getRecord().get('Caso__c'));
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
		//get case info info
		list<Case> cases = 
			[SELECT CaseNumber,Id 
			 FROM Case
			 where 	id =: string.valueOf(CtxController.getRecord().get('Caso__c'))
			 limit 	1];
			 
			 
		if(cases.size() > 0)
		{
			string oRetorno = '/Casos/' + cases[0].CaseNumber;
			return oRetorno;
		}
		else
		{
			 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'No se encontro un caso al cual relacionar el archivo.');
			 ApexPages.addMessage(errorMsg);
		}
		return null;
	}
}