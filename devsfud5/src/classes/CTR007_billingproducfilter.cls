/*
*	Controller to load file into amazon s3 
*	29 Enero 2014 - Juan Daniel Horta - billing product filter 
*/

public class CTR007_billingproducfilter {
	
	/*Context properties*/
	private QuoteLineItem oCurrentQuoteItem;
	public QuoteLineItem CurrentQuoteItem{ 
		get {
			if(oCurrentQuoteItem == null){
				oCurrentQuoteItem = 
					[select Id
							,TotalPrice
							,Tipo_venta__c
							,Activo_renovacion__c
							,Activo_Upselling__c
							
							
							,Quote.Opportunity.AccountId
							,PricebookEntry.Product2.Linea_de_produccion__c
							,PricebookEntry.Product2.Family
							
					from 	QuoteLineItem
					where 	id =: ((QuoteLineItem)CtxController.getRecord()).Id
					limit 	1][0];
			}
			return oCurrentQuoteItem;
		}
		set{
			oCurrentQuoteItem = value;
		}
	}
	
	ApexPages.StandardController CtxController;
	public CTR007_billingproducfilter(ApexPages.StandardController stdController) {
		CtxController = stdController;
	}
	
	/*select asset*/
	public pageReference SelectAsset() {

		try{
			//get asset info
			Asset[] AssetToInsert = 
				[select id
						,Name
						,SerialNumber
						,InstallDate
						,Price
						,Codigo_activo__c
						
						,AccountId
						,Account.Name
						
						,Product2Id
						,Product2.Linea_de_produccion__c 
						,Product2.Family
				from 	Asset
				where 	id =: Apexpages.currentPage().getParameters().get('rbSelectedAsset')
				limit 	1];
			
			if(AssetToInsert != null && AssetToInsert.size() > 0){
				
				Boolean ovStartUpdate = false;
				
				if(AssetToInsert[0].AccountId == CurrentQuoteItem.Quote.Opportunity.AccountId &&
					AssetToInsert[0].Product2.Family == CurrentQuoteItem.PricebookEntry.Product2.Family &&
					AssetToInsert[0].Product2.Linea_de_produccion__c == CurrentQuoteItem.PricebookEntry.Product2.Linea_de_produccion__c){
					
					//renew
					CurrentQuoteItem.Activo_renovacion__c = AssetToInsert[0].id;
					CurrentQuoteItem.Activo_Upselling__c = null;
					CurrentQuoteItem.Tipo_venta__c = CL000_Utils.C_QuoteLineItemsaleTyperenew;
					
					ovStartUpdate = true;
				}
				else if(AssetToInsert[0].AccountId == CurrentQuoteItem.Quote.Opportunity.AccountId &&
					AssetToInsert[0].Product2.Family == CurrentQuoteItem.PricebookEntry.Product2.Family){
					
					//up-down selling
					CurrentQuoteItem.Activo_renovacion__c = null;
					CurrentQuoteItem.Activo_Upselling__c = AssetToInsert[0].id;
					
						
					if(AssetToInsert[0].Price <= CurrentQuoteItem.TotalPrice){
						//upselling
						CurrentQuoteItem.Tipo_venta__c = CL000_Utils.C_QuoteLineItemsaleTypeUpselling;
					}
					else if(AssetToInsert[0].Price > CurrentQuoteItem.TotalPrice){
						//downselling
						CurrentQuoteItem.Tipo_venta__c = CL000_Utils.C_QuoteLineItemsaleTypeDownselling;
					}
					
					ovStartUpdate = true;
				}
				else{
					
		 			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'El activo no se puede relacionar al producto por cotización.');
					ApexPages.addMessage(errorMsg);
				}
				
				if(ovStartUpdate){
					
					//update quote line item
					update CurrentQuoteItem;
						
					//return to quote line item detail page
					PageReference pgRef = new PageReference('/' + CurrentQuoteItem.id);
					pgRef.setRedirect(true);
					return pgRef;
				}
			}
			else{
		 		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Debe seleccionar un activo.');
				ApexPages.addMessage(errorMsg);
			}
		}catch(Exception er){
			
	 		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
	 			'Linea:: ' +  string.valueof(er.getLineNumber()) + '::' +  
	 			'Linea:: ' +  string.valueof(er.getStackTraceString()) + '::' +
	 			er.getMessage());
	 		ApexPages.addMessage(errorMsg);
	 		
		}
		return null;
	}

	/*get related asset*/ 
	public List<Asset> getAssetInfo(){
		
		List<Asset> oRetorno = new List<Asset>();
		
		if(CurrentQuoteItem.Id != null){
			
			oRetorno =
				[select	id
						,Name
						,SerialNumber
						,InstallDate
						,Price
						,Codigo_activo__c
						
						,AccountId
						,Account.Name
						
						,Product2Id
						,Product2.Linea_de_produccion__c 
						,Product2.Family
				from 	Asset 
				where 	AccountId =: CurrentQuoteItem.Quote.Opportunity.AccountId
						and (
							Product2.Linea_de_produccion__c =: CurrentQuoteItem.PricebookEntry.Product2.Linea_de_produccion__c
							or Product2.Family =: CurrentQuoteItem.PricebookEntry.Product2.Family)
				order by Product2.Family,Product2.Linea_de_produccion__c ];
		}
		
		return oRetorno; 
	}	
}