/*
*	Controller to load file into amazon s3 
*	15 Enero 2013 - Jairo Guzman - load file into amazon s3 
*/

public class CTR001_NewS3File_Step1 {
	
	//request params
	public string PR_FileId {get;set;}
	public string PR_retURL {get;set;}
	
	//Context params
	ApexPages.StandardController CtxController{get;set;}
	public Archivo_amazon_s3__c CurrentRecord{get;set;}
	public string serverURL {get;set;}
	
	/*****AWS Params****/
	
	//key params
 	public AWSKeys credentials {get;set;}
 	public string AWSCredentialName = CL000_Utils.C_AWSCredentialName;
 	public string secret { get {return credentials.secret;} }
	public string key { get {return credentials.key;} }
	
	//AWS Object
	public S3.AmazonS3 as3 { get; private set; }
	
	/*****AWS Params****/
	
	//file name
	public string FileName	{
		get{
			if(CurrentRecord.Es_carpeta__c){
				return CurrentRecord.Ubicacion_archivo__c + '/' + 
						CurrentRecord.Tipo_contenido__c + '/' + 
						CurrentRecord.Codigo_archivo__c + '_' + 
						CurrentRecord.Name + '/';
			}
			else{			
				return CurrentRecord.Ubicacion_archivo__c + '/' + 
						CurrentRecord.Tipo_contenido__c + '/' + 
						CurrentRecord.Codigo_archivo__c + '_' + 
						CurrentRecord.Name + '.' +
						CurrentRecord.Extension_archivo__r.Extension__c;
			}
		}
	}
	
	//file upload visible
	public string FileUploadVisible{
		get{
			if(CurrentRecord.Es_carpeta__c){
				return 'none';
			}
			else{
				return '';
			}
		}
	}
	
	//content type
	public string ContentType{get{return CurrentRecord.Extension_archivo__r.Name;}}
	
	public string FileAccess{
		get{
			if(CurrentRecord.Permisos_archivo__c == CL000_Utils.C_AWSAccessRecordFull){
				return 'FULL_CONTROL';
			}
			if(CurrentRecord.Permisos_archivo__c == CL000_Utils.C_AWSAccessRecordWrite){
				return 'WRITE';
			}
			else{
				return 'public-read';
			}
			
		}
	}		
	
	//policy
	
	datetime expire = system.now().addDays(1);
	String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+
		expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';           
	      
	string policy { get {return 
		'{ "expiration": "'+formattedexpire+'","conditions": [ {"bucket": "'+
    	CurrentRecord.Bucket__c +'" } ,{ "acl": "'+
    	FileAccess +'" },'+
    //	'{"success_action_status": "201" },'+
    	'{"content-type":"'+ContentType+'"},'+
    	'{"success_action_redirect": "https://'+serverURL+PR_retURL+'"},' +
    	'["starts-with", "$key", ""] ]}'; 	} } 
    
    public String getPolicy() {
        return EncodingUtil.base64Encode(Blob.valueOf(policy));
    }
    
    public String getSignedPolicy() {    
        return make_sig(EncodingUtil.base64Encode(Blob.valueOf(policy)));        
    }
    
    // tester
    public String getHexPolicy() {
        String p = getPolicy();
        return EncodingUtil.convertToHex(Blob.valueOf(p));
    }
    
    //method that will sign
    private String make_sig(string canonicalBuffer) {        
        String macUrl ;
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(secret));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(Secret)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }

    /*contructor*/
	public CTR001_NewS3File_Step1(ApexPages.StandardController stdController) {

		try
		{
			//get context controller
			CtxController = stdController;
			
			//get server host 
			serverURL = URL.getSalesforceBaseUrl().getHost();
			
			//get request variables
			PR_FileId = ApexPages.currentPage().getParameters().get('FileId');
			PR_retURL = ApexPages.currentPage().getParameters().get('retURL');
			
			//get amazon credentials
			credentials = new AWSKeys(AWSCredentialName);
			as3 = new S3.AmazonS3(credentials.key,credentials.secret);
			
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
				where 	id =: PR_FileId
				limit 	1];
		}
		catch(Exception er){
			 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, er.getMessage());
			 ApexPages.addMessage(errorMsg);
		}
    } 
	
	/*public static methods*/
	
	/*
		Create Amazon file row 
	
		Public method invoke from external controllers to create new file 
		register.
		
		return amazon file id
	*/
	public static string CreateAmazonFileRecord
			(string vName,
			string vBucket,
			boolean vEsCarpeta,
			string vFileExtension,
			string vPermisosArchivo,
			string vTipoContenido,
			string vUbicacionArchivo){

		if(vName != null &&
			vBucket != null &&
			vPermisosArchivo != null &&
			vTipoContenido != null &&
			vUbicacionArchivo != null){ 
		 
			//get file extension
			Extension_archivo__c[] RelExt = null;	
			
			if(vEsCarpeta){
				RelExt = [select id 
						from Extension_archivo__c 
						where extension__c =: CL000_Utils.C_AWSFolderExtension
						limit 1];
			}
			else if(vFileExtension != null){
				RelExt = [select id 
						from Extension_archivo__c 
						where extension__c =: vFileExtension
						limit 1];
			}
			
			//create new amazon file
			Archivo_amazon_s3__c newFile = new Archivo_amazon_s3__c();

			if(RelExt != null && RelExt.size() > 0){
				
				try{
					newFile.Name = vName;
					newFile.Bucket__c = vBucket;
					newFile.Es_carpeta__c = vEsCarpeta;
					newFile.Extension_archivo__c =	RelExt[0].id; 
					newFile.Permisos_archivo__c = vPermisosArchivo;
					newFile.Tipo_contenido__c = vTipoContenido;
					newFile.Ubicacion_archivo__c = vUbicacionArchivo;

					insert newFile;
							
					return newFile.id;
				}
				catch(Exception er){
					 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, er.getMessage());
					 ApexPages.addMessage(errorMsg);
				}			
			}
			else{
				 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'NO se encontro una extensión de archivo valida.');
				 ApexPages.addMessage(errorMsg);
			}
		}
		else{
			 ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Las propiedades de creacion del archivo son incorrectas.');
			 ApexPages.addMessage(errorMsg);
		}
		return null;
	}
}