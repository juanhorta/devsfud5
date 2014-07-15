/*
*   Create default quota distribution values
*   08 Enero 2013 - Jairo Guzman - TG001_Quote_CreateDefaultQuota: call CreateQuotation class
*/

trigger TG001_Quote_CreateDefaultQuota on Quote (after update) {

     set<Id> quoteId = new Set<Id>();
     for (Quote oQuote : Trigger.new){ 
        
        quoteId.add(oQuote.Id);
       
        system.debug('JDDEBUG2: entries: '+oQuote);
       // system.debug('JDDEBUG2: entries: '+synquedQuote);
     }
     
       integer size = quoteId.size();
          system.debug('JDDEBUG2: size: '+size);
         
         if(size==1){
         
         Quote[] quoteinfo = 
                [select Id
                        ,Numero_cuotas__c
                        ,Cuota_normalizada__c
                        ,GrandTotal
                        ,Fecha_primera_cuota__c
                        ,TotalPrice
                        from Quote 
                 where id in :quoteId];
                 
         
  //Asset[] oAssets = Trigger.new;
    
 CL001_QuotaRules.CreateQuotation(quoteinfo);
     
  }
    
   // Quote[] oQuotes = Trigger.new;
    //system.debug('cuotas_nuevas'+oQuotes);
    
  //  CL001_QuotaRules.CreateQuotation(oQuotes);
}