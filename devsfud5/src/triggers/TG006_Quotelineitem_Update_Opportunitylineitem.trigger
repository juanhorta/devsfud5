trigger TG006_Quotelineitem_Update_Opportunitylineitem on QuoteLineItem (after update) {

    set<Id> qliIds = new Set<Id>();
    
  // Set<Id> synquedQuote = new Set<Id>();
  for (QuoteLineItem oqli : Trigger.new){ 
    qliIds.add(oqli.Id);
    
  }
  
   QuoteLineItem[] qli = 
        [select id 
                ,Activo_producido__c
                ,Activo_renovacion__c
                ,Activo_Upselling__c
                ,Aplica_bono__c
                ,CreatedById
                ,CreatedDate
                ,Description
                ,Discount
                ,Es_gratuito__c
                ,IsDeleted
                ,LastModifiedById
                ,LastModifiedDate
                ,LineNumber
                ,ListPrice
                ,Numberquota__c
                ,PricebookEntryId
                ,Quantity
                ,QuoteId
                ,ServiceDate
                ,SortOrder
                ,Subtotal
                ,SystemModstamp
                ,Tipo_venta__c
                ,Token_publicidad__c
                ,TotalPrice
                ,UnitPrice
                from QuoteLineItem
         where id in :qliIds];
    
    
            OpportunityLineItem[] oli = 
            [select id
                    ,Activo_producido__c
                    ,Activo_renovacion__c
                    ,Activo_upselling__c
                    ,Aplica_bono__c
                    ,Es_gratuito__c
                    ,Numero_de_cuotas__c
                    ,Tipo_venta__c
                    ,Token_publicidad__c
                    ,Producto_por_cotizacion__c
                    from    OpportunityLineItem
            where   Producto_por_cotizacion__c =: qliIds];
            
        CL010_Discuont_recalc.UpdateOppLineItem(qli,oli);
}