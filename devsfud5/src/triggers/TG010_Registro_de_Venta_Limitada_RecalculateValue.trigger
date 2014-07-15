/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Junio 24 de 2014
*  Decripción:          Trigger que calcula el precio del producto en caso de eliminacion de algun registro de ventas limitadas 
*  @version:            1.0

* ===================================================================================================================================
**/

trigger TG010_Registro_de_Venta_Limitada_RecalculateValue on Registro_de_Venta_Limitada__c (before Delete) {

 public Decimal acumuladovtaslim{get;set;}
if(Trigger.isDelete  && Trigger.old.size()==1 ){
	Registro_de_Venta_Limitada__c objOld = Trigger.old[0];
 	
 	
 	String stridQuoteLineItem = String.valueof(objOld.Partida_de_presupuesto__c);
 	
 	//list<Registro_de_Venta_Limitada__c> totalvtas = [SELECT Id,Partida_de_presupuesto__c,Precio__c FROM Registro_de_Venta_Limitada__c   where Partida_de_presupuesto__c =:stridQuoteLineItem];
    //acumuladovtaslim = 0;
 	/*for(Registro_de_Venta_Limitada__c regvtas: totalvtas)
 	{
 		system.debug('acumuladovtaslim_antes '+acumuladovtaslim + '\n\n totalvtas ' + totalvtas);
 		if(regvtas.Precio__c <> null)
 		{
 			acumuladovtaslim = acumuladovtaslim + regvtas.Precio__c;
 		}
 		
 	}
     	system.debug('acumuladovtaslim_despues '+acumuladovtaslim );
     */	QuoteLineItem MyQuoteLineItem = [SELECT Id,ListPrice,TotalPrice,UnitPrice FROM QuoteLineItem WHERE Id =:stridQuoteLineItem ];
     // 1 se disminuye el valor del producto por cotizacion
    	MyQuoteLineItem.UnitPrice =  MyQuoteLineItem.UnitPrice - objOld.Precio__c;
    	//MyQuoteLineItem.UnitPrice =  MyQuoteLineItem.ListPrice + acumuladovtaslim;
    	update MyQuoteLineItem;	
 
 	
    	 
    
  
 	
}




}