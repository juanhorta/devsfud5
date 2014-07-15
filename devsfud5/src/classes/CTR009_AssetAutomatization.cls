/*
*	Controller for opportunity s3 file 
*	07 Febrero 2013 - Jairo Guzman - sync opportunity asset when trigger fail
*/

public class CTR009_AssetAutomatization {
	
	ApexPages.StandardController CtxController;
	public CTR009_AssetAutomatization(ApexPages.StandardController stdController) {
		CtxController = stdController;
	}
	
	/*modify billing info*/
	public pageReference StartSync() {
	
		try{
			if([select 	count() 
				from 	User 
				where 	Profile.Name = 'Administrador del sistema'
						and Id =: UserInfo.getUserId()] > 0){

				List<Opportunity> oOpportunity = 
					[select id
							,IsWon
							,IsClosed
							,SyncedQuoteId
							,AccountId
							,Ano_Fiscal__c
							,Ciudad_venta__c
					from 	Opportunity
					where 	id =: ((Opportunity)CtxController.getRecord()).Id];
					
						AggregateResult[] qrAux;
  						
							for(Opportunity op :oOpportunity){
								
								if(op.IsWon){
									 
										  	system.debug('qraux: '+qrAux);
										  	
										  	if(Test.isRunningTest())
										  	{
										  		 qrAux = [SELECT count(Id) Max_Codigo_activo__c FROM Extension_archivo__c ];//
										  	}else
										  	if(qrAux == null)
										  	{	
										  		 qrAux = [select MAX(Codigo_activo__c) Max_Codigo_activo__c from asset]; //JDHC 20 febrero 2014 se saca esta asignacion del metodo calcnewasset debido a que se ejecutava varias veces y generaba los 50001 rows 
										    }
								
		    					
		    					
								}	
							}
				//Opportunity op1 = new Opportunity();
				//op1.Id=oOpportunity[0].Id;
		    	//op1.Fecha_cerrada_ganada__c = null;
		    	//CL002_AssetsProcessing.CreateAssets(oOpportunity,qrAux,op1);
			}
			else{
	     		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Esta funcionalidad solo esta habilitada para administradores del sistema.');
			 	ApexPages.addMessage(errorMsg);
			}
		}catch(Exception er){
		     
		     ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, er.getMessage());
			 ApexPages.addMessage(errorMsg);
		}
		return null;
	}

}