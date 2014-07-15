/*
*	Utils class 
*	23 Enero 2013 - Jairo Guzman - admin all quote processing rules 
    V 1.1 JDHC 13-02-2014  Se agrega validacion para que permita sincronizar  las cotizaciones de valor cero
*/

public class CL005_QuoteProcessing {
	
	public string RelatedQuoteId{get;private set;}
	
	public List<ApexPages.Message> ErrorList{get;private set;}
	
	public CL005_QuoteProcessing(string oRelatedQuoteId){
	
		RelatedQuoteId = oRelatedQuoteId;
	}
	
	/*validate quote replication rules */
	public Boolean ValidateQuoteRules(){
		
		Boolean ValidQuote = true;
		
		try{
			
			ErrorList = new List<ApexPages.Message>();
			
			//get quote items info
			QuoteLineItem[] lstQuoteItem = 
				[select id
						,Discount
						,Token_publicidad__c
						
						,Pricebookentry.Product2.ProductCode
						,Pricebookentry.Product2.Family					
						,Pricebookentry.Product2.Linea_de_produccion__c
						,Pricebookentry.Product2.Descuento_autorizado__c
						,Pricebookentry.Product2.Venta_limitada__c
						
						,Activo_renovacion__c
						,Activo_renovacion__r.AccountId
						,Activo_renovacion__r.Product2.ProductCode
						,Activo_renovacion__r.Product2.Family
						,Activo_renovacion__r.Product2.Linea_de_produccion__c
						,Quote.Name
						,Activo_Upselling__c
						,Activo_Upselling__r.AccountId
						,Activo_Upselling__r.Product2.ProductCode
						,Activo_Upselling__r.Product2.Family
						
						,Quote.id
						,Quote.Token_venta_en_linea__c
						,Quote.TotalPrice
						,Quote.Ciudad_venta__c
						
						,Quote.Opportunity.AccountId
						,Quote.Opportunity.Type

				from	QuoteLineItem
				where 	QuoteId =: RelatedQuoteId];			
		     system.debug('lstQuoteItem_encontrado? '+lstQuoteItem);
			//validate quote line items
			if(lstQuoteItem != null && lstQuoteItem.size() > 0){
				
				//get last aproval
				ProcessInstance[] LastAproval =
					[select id,
							Status,
							TargetObjectId,
							LastModifiedDate 
					from 	ProcessInstance 
					where	TargetObjectId =: lstQuoteItem[0].Quote.id 
							and IsDeleted = false
					order by LastModifiedDate desc limit 1]; 
					
				//validate sale city
				if(lstQuoteItem[0].Quote.Ciudad_venta__c == null){
					ValidQuote = false;
					ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL, 
						'Debe completar el campo "ciudad de venta".'));
				}
					
				//validate pay on line
				if(!ValidatePayOnLine(lstQuoteItem[0].Quote)){
					ValidQuote = false;
				}
					
				Boolean blValOpportunityRenew = false;
				
				for(QuoteLineItem qli : lstQuoteItem ){

					//validate quote items discount
					if(!ValidateItemDiscount(qli, LastAproval)){
						ValidQuote = false;
					}

					//validate advertising token
					if(!ValidateAdvertisingToken(qli)){
						ValidQuote = false;
					}
					
					//validate renew assets
					if(!ValidateRenewAssets(qli)){
						ValidQuote = false;
					}
					else if(qli.Activo_renovacion__c != null || 
							qli.Activo_Upselling__c != null){
						
						blValOpportunityRenew = true;
					}
				}

				//validate opportunity renew
				if(lstQuoteItem[0].Quote.Opportunity.Type == CL000_Utils.C_OpportunitySaleTypeRenew && !blValOpportunityRenew){
					ValidQuote = false;
					ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL, 
						'Una oportunidad de renovación debe tener por lo menos uno de sus productos renovados.'));
				}
				else if(lstQuoteItem[0].Quote.Opportunity.Type == CL000_Utils.C_OpportunitySaleTypeNew && blValOpportunityRenew){
					ValidQuote = false;
					ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL, 
						'Una oportunidad de venta nueva no debe tener ninguno de sus productos renovados.'));
				}
				
				//validate billing data
				if(!ValidateBillingData(lstQuoteItem[0].Quote)){
					ValidQuote = false;
				}
				
			}
			else{
				ValidQuote = false;
				ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL, 'La cotización debe tener por lo menos un producto configurado.'));
			}
		}
		catch(Exception er){
			ValidQuote = false;
			ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL, 'CL005_QuoteProcessing.ValidateQuoteRules::' + er.getMessage()));
		}					
		return ValidQuote;
	}
	
	/*validate pay on line*/
	private Boolean ValidatePayOnLine(Quote QuoteToEval){

		Boolean ValidQuote = true;
		//validate pay on line
		if(QuoteToEval.Token_venta_en_linea__c != null){
			
			//get number of quotas
			Integer ovNumQuotas = 
				[select	count()
				from	Cuota_facturacion__c
				where	Dato_facturacion__r.Presupuesto__c =: QuoteToEval.Id];
					
			CL004_OnLinePayToken OnLineToken = new CL004_OnLinePayToken(QuoteToEval.Token_venta_en_linea__c);
				
			if(!OnLineToken.ValidateTokenFormat()){
				
				ValidQuote = false;
					
				ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
					'La cotización tiene relacionado un token de venta en linea invalido.'));
			}
			else if(ovNumQuotas != 1){
				
				ValidQuote = false;
					
				ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
					'Cuando la cotizacion tiene relacionado un token de venta en linea el número de coutas debe ser de uno (1).'));
			}
		}
		
		return ValidQuote;	
	}
	
	/*Validate item discount rules*/
	private Boolean ValidateItemDiscount(QuoteLineItem ItemToEval, ProcessInstance[] LastAproval){

		Boolean ValidQuote = true;

		//validate quote items discount
		if(ItemToEval.Discount != null && 
			ItemToEval.Pricebookentry.Product2.Descuento_autorizado__c != null &&
			ItemToEval.Discount > ItemToEval.Pricebookentry.Product2.Descuento_autorizado__c){
		
			if(LastAproval != null &&
				LastAproval.size() > 0 && 
				LastAproval[0].Status == 'Approved'){}
			else{
					
				ValidQuote = false;
				
				ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
					'El producto ' + string.valueof(ItemToEval.Pricebookentry.Product2.ProductCode) +
					' tiene un descuento superior al autorizado y no esta aprobado.'));
			}
		}
		return ValidQuote;		
	}
	
	/*Validate advertising token*/
	private Boolean ValidateAdvertisingToken(QuoteLineItem ItemToEval){
		
		Boolean ValidQuote = true;
		
		//validate advertising token
		if(ItemToEval.Pricebookentry.Product2.Venta_limitada__c != null &&
			ItemToEval.Pricebookentry.Product2.Venta_limitada__c){
			
			CL003_AdvertisingToken AdvToken = new CL003_AdvertisingToken(ItemToEval.Token_publicidad__c);
			
			if(!AdvToken.ValidateTokenFormat()){
				
				ValidQuote = false;
					
				ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
					'El producto ' + string.valueof(ItemToEval.Pricebookentry.Product2.ProductCode) +
					' es de venta limitada y no posee un token valido.'));
			}
		}		
		return ValidQuote;	
	}
	
	/*Validate renew assets*/
	private Boolean ValidateRenewAssets(QuoteLineItem ItemToEval){
		
		Boolean ValidQuote = true;
		
		if(ItemToEval.Activo_renovacion__c != null &&
			ItemToEval.Activo_Upselling__c != null){
			
			ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
						'Un producto no puede tener llenos al mismo tiempo los campos de activo de renovación y activo de upselling'));
		}
		else{
			//validate renew assets
			if(ItemToEval.Activo_renovacion__c != null){
							
				if(ItemToEval.Activo_renovacion__r.AccountId == ItemToEval.Quote.Opportunity.AccountId &&
					ItemToEval.Activo_renovacion__r.Product2.Family == ItemToEval.Pricebookentry.Product2.Family &&
					ItemToEval.Activo_renovacion__r.Product2.Linea_de_produccion__c == ItemToEval.Pricebookentry.Product2.Linea_de_produccion__c){}
				else{
					ValidQuote = false;
									
					ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
						'El producto ' + string.valueof(ItemToEval.Pricebookentry.Product2.ProductCode) +
						' no puede ser renovado con el producto ' + string.valueof(ItemToEval.Activo_renovacion__r.Product2.ProductCode)));
				}
			}
			else if(ItemToEval.Activo_Upselling__c != null){
				
				if(ItemToEval.Activo_Upselling__r.AccountId == ItemToEval.Quote.Opportunity.AccountId &&
					ItemToEval.Activo_Upselling__r.Product2.Family == ItemToEval.Pricebookentry.Product2.Family){}
				else{
					ValidQuote = false;
									
					ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
						'El producto ' + string.valueof(ItemToEval.Pricebookentry.Product2.ProductCode) +
						' no puede ser comercializado a cambio del producto con el producto ' + string.valueof(ItemToEval.Activo_Upselling__r.Product2.ProductCode)));
				}
			}
		}		
		
		return ValidQuote;	
	}	
	
	/*Validate renew assets*/
	private Boolean ValidateBillingData(Quote QuoteToEval){
	
		Boolean ValidBilling = true;

		//validate total billing
		Integer ovCountBillings =
			[select count()
			from	Dato_facturacion__c
			where	Presupuesto__c =: QuoteToEval.Id];
			
		// JDHC 13-02-2014 Se agrega validacion para que permita sincronizar  las cotizaciones de valor cero
		if(ovCountBillings < 1 && QuoteToEval.TotalPrice > 0){
			ValidBilling = false;
			ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
				'La cotización debe poseer por lo menos un dato de facturación.'));
		}
		
		if(QuoteToEval.TotalPrice == 0){
			ValidBilling = true;
		}

		
		//validate total billing
		decimal ovTotalBilling =
			(decimal)[select sum(Valor_facturacion__c)SumQuote
			from	Dato_facturacion__c
			where	Presupuesto__c =: QuoteToEval.Id][0].get('SumQuote');
			
		if(ovTotalBilling != QuoteToEval.TotalPrice && QuoteToEval.TotalPrice != 0 ){
			
			ValidBilling = false;
			ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
				'El valor total de la cotización ' + string.valueof(QuoteToEval.TotalPrice) + 
				' Debe ser igual a la sumatoria de los valores de las facturas ' + string.valueof(ovTotalBilling) + '.'));
		}

		//validate quota sum
		AggregateResult[] ovTotalBillingDetail =
			[select Dato_facturacion__c
					,max(Dato_facturacion__r.Name)Name
					,max(Dato_facturacion__r.Valor_facturacion__c)QuotaTotal
					,sum(Valor_cuota__c)SumQuota
			from	Cuota_facturacion__c
			where	Dato_facturacion__r.Presupuesto__c =: QuoteToEval.Id
			group by Dato_facturacion__c];
		
		for(AggregateResult ar:ovTotalBillingDetail){
			
			if((decimal)ar.get('QuotaTotal') != ar.get('SumQuota')){
				
				ValidBilling = false;
				ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
					'El dato de facturación ' + ar.get('Name') + 
					' no coincide su valor de facturación ' + string.valueof(ar.get('QuotaTotal')) +
					' con la sumatoria de sus cuotas ' + string.valueof(ar.get('SumQuota')) + '.'));			
			}
		}
		
		//validate product sum
		AggregateResult[] ovTotalProductDetail =
			[select Partida_de_presupuesto__c
					,max(Partida_de_presupuesto__r.Pricebookentry.Product2.ProductCode)ProductCode						
					,max(Partida_de_presupuesto__r.LineNumber)LineNumber 
					,max(Partida_de_presupuesto__r.TotalPrice)QuotaTotal
					,sum(Valor_cuota__c)SumQuota
			from	Cuota_facturacion__c
			where	Dato_facturacion__r.Presupuesto__c =: QuoteToEval.Id
			group by Partida_de_presupuesto__c];
					
		for(AggregateResult ar:ovTotalProductDetail){
			
			if((decimal)ar.get('QuotaTotal') != ar.get('SumQuota')){
				
				ValidBilling = false;
				ErrorList.add(new ApexPages.Message(ApexPages.Severity.FATAL,
					'El producto por cotización ' + ar.get('ProductCode') + 
					' no coincide su valor total ' + string.valueof(ar.get('QuotaTotal')) +
					' con la sumatoria de sus cuotas ' + string.valueof(ar.get('SumQuota')) + '.'));			
			}
		}
		return ValidBilling;
	}
}