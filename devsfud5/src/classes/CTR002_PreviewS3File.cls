/*
*	Controller for opportunity s3 file 
*	21 Enero 2013 - Jairo Guzman - control file visibility 
*/

public class CTR002_PreviewS3File {
	
	/*****AWS Params****/
	
	//key params
 	private string AWSCredentialName = CL000_Utils.C_AWSCredentialName;
	//AWS Object
	public S3.AmazonS3 as3 { get; private set; }
	
	/*****AWS Params****/	

	//context params
	ApexPages.StandardController CtxController;
	public Archivo_amazon_s3__c CurrentRecord{get;set;}
	
	public CTR002_PreviewS3File(ApexPages.StandardController stdController) {
		try{
			//get current context controller
			CtxController = stdController;

			//get record info
			CurrentRecord = 
				[select id,
						Name,
						Bucket__c,
						Codigo_archivo__c,
						Es_carpeta__c,
						Extension_archivo__c,
						Extension_archivo__r.Name,
						Extension_archivo__r.Extension__c,
						Permisos_archivo__c,
						Tipo_contenido__c,
						Ubicacion_archivo__c,
						Url_objeto__c
				from 	Archivo_amazon_s3__c
				where 	id =: string.valueof(CtxController.getRecord().get('id'))
				limit 	1];
			
			if(CurrentRecord.Es_carpeta__c){			
				//create amazon object to query
				AWSKeys credentials = new AWSKeys(AWSCredentialName);
				as3 = new S3.AmazonS3(credentials.key,credentials.secret);
				as3 = new S3.AmazonS3();
		    	as3.secret = credentials.secret;
				as3.key = credentials.key;
			}
			
		}catch(Exception er){
		     
		     ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, er.getMessage());
			 ApexPages.addMessage(errorMsg);
		}
	}
	
	public List<TreeNodeInfo> getAWSobjectList(){

		List<TreeNodeInfo> oRetorno = new List<TreeNodeInfo>();		
		if(CurrentRecord.Es_carpeta__c){
	
			try{
				string strBaseLocation = 
					CurrentRecord.Ubicacion_archivo__c + '/' +
					CurrentRecord.Tipo_contenido__c + '/' +
					CurrentRecord.Codigo_archivo__c + '_' +
					CurrentRecord.Name + '/';
	
				Datetime now = Datetime.now();
				Integer maxNumberToList = 1000; //Set the number of Objects to return for a specific Bucket
				
				
				S3.ListBucketResult objectsForBucket = as3.ListBucket(CurrentRecord.Bucket__c, strBaseLocation, strBaseLocation ,maxNumberToList, 
		    		null,as3.key,now,as3.signature('ListBucket',now),as3.secret);
		    		
				
				if ( objectsForBucket != null && objectsForBucket.Contents != null) {
		        	for (S3.ListEntry f : objectsForBucket.Contents ) {
		            	oRetorno.add(new  TreeNodeInfo(
		            		f.Key.replace(strBaseLocation, ''),
		            		'https://s3.amazonaws.com/' + 
		            		CurrentRecord.Bucket__c + '/' +
		            		f.Key));
		        	}
	  			}
			}catch(Exception er){
				
			     ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, er.getMessage());
				 ApexPages.addMessage(errorMsg);
			}
			
		}  	
		return oRetorno;
	}

	public class TreeNodeInfo{
		public string strLabel {get;set;}
		public string strUrl{get;set;}
		
		public TreeNodeInfo(string ostrLabel,string ostrUrl){
			strLabel = ostrLabel;
			strUrl = ostrUrl;
		}	
	}
}