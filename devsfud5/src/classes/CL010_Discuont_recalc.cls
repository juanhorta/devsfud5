/*
*  26 Febrero 2014 - Juan Daniel Horta - QuoteLineItemDiscount_Recalc
*/
public with sharing class CL010_Discuont_recalc {
	
	 public static void CalcPercent(QuoteLineItem [] oQuoteItem) {
	 	
	 	for(QuoteLineItem qli: oQuoteItem){
	 		decimal Percent = 0;
	 		//float decVal = 0;
	 		if(qli.Discount != null)
	 			{
			 		Percent = qli.Discount;
		 		}
		 	decimal price = qli.UnitPrice * qli.Quantity;
		 	decimal newTotalPrice = Price-(Price*Percent/100);
	 		decimal IntVal = Math.Round(newTotalPrice);
	 		decimal floatVal = newTotalPrice - IntVal;
	 		system.debug('JDDEBUGq: IntVal: '+IntVal);
	 		system.debug('JDDEBUGq: newTotalPrice: '+newTotalPrice);
			system.debug('JDDEBUGq: floatVal: '+floatVal);
			
			if(price != 0){
				newTotalPrice = newTotalPrice-floatval;
				Percent = 100-(newTotalPrice*100/price);
				system.debug('JDDEBUGq: floatVal: '+floatVal);
				system.debug('JDDEBUGq: percent: '+Percent);
				Percent = Percent.stripTrailingZeros();
				
				system.debug('JDDEBUGq: percent: '+Percent);
				/*QuoteLineItem qliUpdate = new QuoteLineItem();
				qliUpdate.Id=qli.Id;
				qliUpdate.Discount = Percent;
				upsert qliUpdate;*/
				qli.Discount = Percent;
			}			
	 	}
	 	
	 }
	 
	  public static void UpdateOppLineItem(QuoteLineItem [] oQuoteItem, OpportunityLineItem [] oOppitem) {
	  	
		  	for(OpportunityLineItem oli: oOppitem){
		  		
		  		for(QuoteLineItem qli: oQuoteItem){
		  			
		  			if(oli.Producto_por_cotizacion__c == qli.Id){
		  				oli.Activo_producido__c=qli.Activo_producido__c;
		  				oli.Activo_renovacion__c=qli.Activo_renovacion__c;
		  				oli.Activo_upselling__c=qli.Activo_Upselling__c;
		  				oli.Aplica_bono__c=qli.Aplica_bono__c;
		  				oli.Es_gratuito__c = qli.Es_gratuito__c;
		  				oli.Numero_de_cuotas__c = qli.Numberquota__c;
		  				oli.Tipo_venta__c = qli.Tipo_venta__c;
		  				oli.Token_publicidad__c = qli.Token_publicidad__c;
		  				update oli;
		  			}	
		  				
		  		}
		  	}
	  	
	  }

}