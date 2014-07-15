/*
*	Controller for opportunity s3 file 
*	22 Enero 2013 - Jairo Guzman - control quote opportunity sync 
*/

public class CTR005_SyncQuote {
	
	public string CurrentQuoteId{get{return string.valueof(CtxController.getRecord().get('id'));}}
	
	ApexPages.StandardController CtxController;
	public CTR005_SyncQuote(ApexPages.StandardController stdController) {
		CtxController = stdController; 
	}

	public pageReference StartSync() {
		
		try{
			//validate quote status
			CL005_QuoteProcessing Valq = new CL005_QuoteProcessing(CurrentQuoteId);
			if(Valq.ValidateQuoteRules()){
				//sync quote
				if(SyncQuoteOportunity(CurrentQuoteId)){
					system.debug('SyncQuoteOportunity = true');
					//redirect to returl
					PageReference pgRef = new PageReference('/' + CurrentQuoteId);
					pgRef.setRedirect(true);
					return pgRef;
				}
			}
			else{
				for(ApexPages.Message errms:Valq.ErrorList){
				 	ApexPages.addMessage(errms);
				}
			}
		}catch(Exception er){
		     
		     ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, er.getMessage());
			 ApexPages.addMessage(errorMsg);
		}
		return null;
	}

	/*sync quote to opportunity*/
	private Boolean SyncQuoteOportunity(string strQuoteId){
		
		Boolean oSuccess = false;
		
		//get quote info
		QuoteLineItem[] QuoteLineToSync =
			[select	id
					,Pricebookentry.Product2.ProductCode
					,TotalPrice
					,Discount
					
					,QuoteId
					,Quote.Ano_fiscal__c
					,Quote.Ciudad_venta__c
					,Quote.Token_venta_en_linea__c 
			
					,Quote.OpportunityId
					,Quote.Opportunity.IsDeleted
					,Quote.Opportunity.IsWon
					,Quote.Opportunity.IsClosed
					,Quote.Opportunity.SyncedQuoteId
					,Quote.Opportunity.Ano_Fiscal__c 
					,Quote.Opportunity.Ciudad_venta__c 
					,Quote.Opportunity.Token_venta_en_linea__c 					
			
			from	QuoteLineItem
			where	QuoteId =: strQuoteId];
		system.debug('Cotizacion_a_sincronizar  '+QuoteLineToSync);
		//validate opportunity status
		if(QuoteLineToSync  != null &&
			QuoteLineToSync.size() > 0 &&
			!QuoteLineToSync[0].Quote.Opportunity.IsDeleted &&
			!QuoteLineToSync[0].Quote.Opportunity.IsWon &&
			!QuoteLineToSync[0].Quote.Opportunity.IsClosed){
			
			//sync quote
			QuoteLineToSync[0].Quote.Opportunity.SyncedQuoteId = QuoteLineToSync[0].QuoteId;
			update QuoteLineToSync[0].Quote.Opportunity;
			
			//update billing information over related opportunity
			oSuccess = QuoteToOpportunity(QuoteLineToSync);
		}
		else{
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'El estado de la oportunidad no permite realizar sincronizaciones.');
		 	ApexPages.addMessage(errorMsg);
		}
		system.debug('oSuccess  '+oSuccess);
		return oSuccess;
	}
	
	/*replication data from quote to opportunity*/
	private Boolean QuoteToOpportunity(QuoteLineItem[] QuoteLineToSync){
	
		Boolean oSuccess = true;
	
		//set opportunity attributes
		QuoteLineToSync[0].Quote.Opportunity.Ano_Fiscal__c = QuoteLineToSync[0].Quote.Ano_fiscal__c;
		QuoteLineToSync[0].Quote.Opportunity.Ciudad_venta__c = QuoteLineToSync[0].Quote.Ciudad_venta__c;
		QuoteLineToSync[0].Quote.Opportunity.Token_venta_en_linea__c = QuoteLineToSync[0].Quote.Token_venta_en_linea__c;
		update QuoteLineToSync[0].Quote.Opportunity;
		
		//set OpportunityLineItem related to QuoteLineItem
		OpportunityLineItem[] CurrentOpportunityItem = 
			[select id
					,Pricebookentry.Product2.ProductCode
					,TotalPrice
					,Discount
			from	OpportunityLineItem
			where	OpportunityId =: QuoteLineToSync[0].Quote.OpportunityId];
			
		list<QuoteLineItem> QuoteLineToSyncAux = QuoteLineToSync.clone();
		map<string,OpportunityLineItem> OppLineItemToUpd = new map<string,OpportunityLineItem>();

		for(OpportunityLineItem oli:CurrentOpportunityItem){
			
			for(QuoteLineItem qli:QuoteLineToSyncAux){
				
				if(!OppLineItemToUpd.containsKey(qli.id)){
					
					if(oli.Pricebookentry.Product2.ProductCode == qli.Pricebookentry.Product2.ProductCode &&
						oli.TotalPrice == qli.TotalPrice &&
						oli.Discount == qli.Discount){
							
						oli.Producto_por_cotizacion__c = qli.Id;
						OppLineItemToUpd.put(qli.Id,oli);
						break;
					}
				}			
			}
		}

		if(OppLineItemToUpd.size() == CurrentOpportunityItem.size()){
			//update opportunity items
			update OppLineItemToUpd.values();
		}
		else{
			oSuccess = false;
			
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 
				'No se lograron replicar todos los productos por cotización en la oportunidad.');
		 	ApexPages.addMessage(errorMsg);
		}
		
		//set opportunity billing data
		Dato_facturacion__c[] NewBillingData = 
			[select id
			from 	Dato_facturacion__c
			where	Presupuesto__c =: QuoteLineToSync[0].QuoteId];
		
		Factura_por_oportunidad__c[] BillingOpportunityToDelete = 
			[select id
			from	Factura_por_oportunidad__c
			where 	Oportunidad__c =: QuoteLineToSync[0].Quote.OpportunityId];
			
		list<Factura_por_oportunidad__c> BillingOpportunityToInsert = new list<Factura_por_oportunidad__c>();
		
		for(Dato_facturacion__c df:NewBillingData){
			Factura_por_oportunidad__c nodf = new Factura_por_oportunidad__c();
			
			nodf.Dato_facturacion__c = df.Id;
			nodf.Oportunidad__c = QuoteLineToSync[0].Quote.OpportunityId;
			
			BillingOpportunityToInsert.add(nodf);
		}
		
		//remove old billing data
		delete BillingOpportunityToDelete;
		
		//insert new billing data 
		insert BillingOpportunityToInsert;
		

		return oSuccess;
	}
}