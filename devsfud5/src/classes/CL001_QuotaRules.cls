/*
*	Control quota creation and validation rules
*	08 Enero 2013 - Jairo Guzman - CreateQuotation: insert quota normal distribution
*	08 Enero 2013 - Jairo Guzman - CalcStandarQuota: calc standar quota distribution
*	08 Enero 2013 - Jairo Guzman - DeleteInvalidQuota: delete posible invalid quota 
*/
public class CL001_QuotaRules{
	
    
    /*Create a quota indicated in Quotation standar fields*/
	public static void CreateQuotation(Quote[] oQuotes) {
   		for (Quote q :oQuotes){

            if(q.Numero_cuotas__c > 0){
                //delete error quota 
				DeleteInvalidQuota(q);

                if(q.Cuota_normalizada__c){
                	//calculate cuota values
                    CalcStandarQuota(q,30); 
                }
                else{
                    //adjust non standar quota values
                    AdjustNonStandarQuota(q,30);
                }
            }
   		}
	}

    /*update or create standar quota values*/
    private static void AdjustNonStandarQuota(Quote oQuote,Integer QuotaIntervalDays) {
        
        Decimal QuotaValue = oQuote.GrandTotal;
        Decimal QuotaSum = 0;
        Date QuotaDate = oQuote.Fecha_primera_cuota__c;
        Date LastQuotaDate = oQuote.Fecha_primera_cuota__c;
        
        List <Cuota__c> cuotxcotizacion = [select Id,Name,No_Cuota__c,Fecha_cuota__c,Valor_cuota__c 
                                    from Cuota__c 
                                    where Presupuesto__c =: oQuote.Id ];
        system.debug('cuotxcotizacion_encontradas'+cuotxcotizacion);
       
        
        system.debug('total_de_cuotas'+cuotxcotizacion.size());
        for(Integer i = 0; i < oQuote.Numero_cuotas__c; i++)
        {
           
            //get quota
          /*
            Cuota__c[] CurrentQuota = [select Id,Name,No_Cuota__c,Fecha_cuota__c,Valor_cuota__c 
                                    from Cuota__c 
                                    where Presupuesto__c =: oQuote.Id
                                    and No_Cuota__c =: i
                                    limit 1];
            system.debug('cuotasactuales'+CurrentQuota.size());
            
            if(CurrentQuota.size() == 0){
          */  
             
             if(cuotxcotizacion.size() == 0)
             {  
                //create new quota
                Cuota__c oCurrentQuota = new Cuota__c
                    (name = 'Cuota ' + string.valueOf(i),
                     No_Cuota__c = i+1,
                     Fecha_cuota__c = QuotaDate,
                     Valor_cuota__c = QuotaValue,
                     Presupuesto__c = oQuote.Id);
                
                insert oCurrentQuota;
                
                //set new date and value
                LastQuotaDate = QuotaDate;
                QuotaDate = QuotaDate + QuotaIntervalDays;
                
                QuotaSum = oQuote.GrandTotal;
                QuotaValue = 0;
            }
            else{
                //update existing quota
                /*
                CurrentQuota[0].name = 'Cuota ' + string.valueOf(i);
                CurrentQuota[0].No_Cuota__c = i;
                */
                Integer a = i+1;
                system.debug('numero_de_cuota' + a);
                
                cuotxcotizacion[i].name = 'Cuota ' + string.valueOf(a);
                cuotxcotizacion[i].No_Cuota__c = a;
                system.debug('cuota'+cuotxcotizacion[i]);
                /*
                if(CurrentQuota[0].Fecha_cuota__c < LastQuotaDate){
                	CurrentQuota[0].Fecha_cuota__c = QuotaDate;
                    LastQuotaDate = QuotaDate;
                	QuotaDate = QuotaDate + QuotaIntervalDays;
                }
                else{
                	LastQuotaDate = CurrentQuota[0].Fecha_cuota__c;
                    QuotaDate = CurrentQuota[0].Fecha_cuota__c + QuotaIntervalDays;
                }
                */
                 if(cuotxcotizacion[i].Fecha_cuota__c < LastQuotaDate){
                	cuotxcotizacion[i].Fecha_cuota__c = QuotaDate;
                    LastQuotaDate = QuotaDate;
                	QuotaDate = QuotaDate + QuotaIntervalDays;
                }else{
                	LastQuotaDate = cuotxcotizacion[i].Fecha_cuota__c;
                    QuotaDate = cuotxcotizacion[i].Fecha_cuota__c + QuotaIntervalDays;
                }
                           
                /*
                if(CurrentQuota[0].Valor_cuota__c > oQuote.GrandTotal){
                    CurrentQuota[0].Valor_cuota__c = 0;
                }
                else if(QuotaSum >= oQuote.GrandTotal){
                	CurrentQuota[0].Valor_cuota__c = 0;
                    
                    QuotaSum = oQuote.GrandTotal;
                	QuotaValue = 0;
                }
                else if(QuotaValue < CurrentQuota[0].Valor_cuota__c){
                    CurrentQuota[0].Valor_cuota__c = QuotaValue;

                    QuotaSum = oQuote.GrandTotal;
                	QuotaValue = 0;
                }
                else{
                    QuotaSum = QuotaSum + CurrentQuota[0].Valor_cuota__c;
                	QuotaValue = QuotaValue - CurrentQuota[0].Valor_cuota__c;
                }

                */
                if(cuotxcotizacion[i].Valor_cuota__c > oQuote.GrandTotal){
                   cuotxcotizacion[i].Valor_cuota__c = 0;
                }
                else if(QuotaSum >= oQuote.GrandTotal){
                	cuotxcotizacion[i].Valor_cuota__c = 0;
                    
                    QuotaSum = oQuote.GrandTotal;
                	QuotaValue = 0;
                }
                else if(QuotaValue < cuotxcotizacion[i].Valor_cuota__c){
                    cuotxcotizacion[i].Valor_cuota__c = QuotaValue;

                    QuotaSum = oQuote.GrandTotal;
                	QuotaValue = 0;
                }
                else{
                    QuotaSum = QuotaSum + cuotxcotizacion[i].Valor_cuota__c;
                	QuotaValue = QuotaValue - cuotxcotizacion[i].Valor_cuota__c;
                }
                
                /*
                if(i == oQuote.Numero_cuotas__c && QuotaValue > 0){
                	CurrentQuota[0].Valor_cuota__c = CurrentQuota[0].Valor_cuota__c + QuotaValue;
                }
               */ 
               if(a == oQuote.Numero_cuotas__c && QuotaValue > 0){
                	cuotxcotizacion[i].Valor_cuota__c = cuotxcotizacion[i].Valor_cuota__c + QuotaValue;
                }
               
               
                update cuotxcotizacion[i];
            }
        }
    }
    

    /*update or create standar quota values*/
    private static void CalcStandarQuota(Quote oQuote,Integer QuotaIntervalDays) {
        
        Decimal QuotaValue = (oQuote.TotalPrice / oQuote.Numero_cuotas__c).intValue(); //JAAR 20-01-2014 Se dejaran las cuotas enteras
        system.debug('-------TotalPrice--->'+oQuote.TotalPrice);    
        Date QuotaDate = oQuote.Fecha_primera_cuota__c;
        //JAAR -  Cambio para que en la creación genere el residuo en la ultima cuota
		Decimal QuoteValuei = (oQuote.TotalPrice/oQuote.Numero_cuotas__c-(oQuote.TotalPrice/oQuote.Numero_cuotas__c).intValue())*oQuote.Numero_cuotas__c;
		
        List <Cuota__c> totaldecuotas = [select Id,Name,No_Cuota__c,Fecha_cuota__c,Valor_cuota__c 
                                  from Cuota__c 
                                  where Presupuesto__c =: oQuote.Id];
         system.debug('-------Creacion_QuoteValuei--->'+QuoteValuei + 'totaldecuotas  ' + totaldecuotas);                         
        
      
        
        for(Integer i = 1; i <= oQuote.Numero_cuotas__c; i++){
            
            //get quota
            Cuota__c[] CurrentQuota = [select Id,Name,No_Cuota__c,Fecha_cuota__c,Valor_cuota__c 
                                    from Cuota__c 
                                    where Presupuesto__c =: oQuote.Id
                                    and No_Cuota__c =: i
                                    limit 1];
            
            if(CurrentQuota.size() == 0){
                //create new quota
                Cuota__c oCurrentQuota = new Cuota__c();
                     oCurrentQuota.name = 'Cuota ' + string.valueOf(i);
                     oCurrentQuota.No_Cuota__c = i;
                     oCurrentQuota.Fecha_cuota__c = QuotaDate;
                     oCurrentQuota.Valor_cuota__c = QuotaValue;
                     system.debug('---Valor_cuota__c '+oCurrentQuota.Valor_cuota__c);
                     oCurrentQuota.Presupuesto__c = oQuote.Id;
                     
                     system.debug('---oCurrentQuota_No_Cuota__c' + oCurrentQuota.No_Cuota__c +' oQuote_Numero_cuotas__c  ' + oQuote.Numero_cuotas__c);
                     if(oCurrentQuota.No_Cuota__c == oQuote.Numero_cuotas__c)
                     {
                     	oCurrentQuota.Valor_cuota__c+=Math.round(QuoteValuei);
                     	system.debug('---se_ajusta_el_siguiente_excedente  ' + QuoteValuei +' total_cuota  ' + oCurrentQuota.Valor_cuota__c);
                     } 
                     
                insert oCurrentQuota;
                system.debug('---Valor_cuota__c_despuesde_insert '+oCurrentQuota);
            }
            else{
            	system.debug('---else ' + QuotaValue + 'CurrentQuota.size() ' + CurrentQuota);
            	
                //update existing quota
                CurrentQuota[0].name = 'Cuota ' + string.valueOf(i);
                CurrentQuota[0].No_Cuota__c = i;
                CurrentQuota[0].Fecha_cuota__c = QuotaDate;
                CurrentQuota[0].Valor_cuota__c = QuotaValue;
                
                system.debug('---oCurrentQuota_No_Cuota__c' + CurrentQuota[0].No_Cuota__c +' oQuote_Numero_cuotas__c  ' + oQuote.Numero_cuotas__c);
                     if(CurrentQuota[0].No_Cuota__c == oQuote.Numero_cuotas__c)
                     {
                     	CurrentQuota[0].Valor_cuota__c+=Math.round(QuoteValuei);
                     	system.debug('---se_ajusta_el_siguiente_excedente  ' + QuoteValuei +' total_cuota  ' + CurrentQuota[0].Valor_cuota__c);
                     } 
                
                update CurrentQuota[0];
            }
            
            //increase quota date
            QuotaDate = QuotaDate + QuotaIntervalDays;
        }
        
        
       
    }



    
    /*delete invalid quota from specific quote*/
    private static void DeleteInvalidQuota(Quote oQuote) {
        
        //update quote number
        Cuota__c[] QuotaToUpdate = [select Id, No_Cuota__c
                                    from Cuota__c
                                    where Presupuesto__c =: oQuote.Id
                                    order by No_Cuota__c ASC];
        Integer qNumber = 1;
        
        for (Cuota__c c :QuotaToUpdate){
            
        	if(c.No_Cuota__c <> qNumber){
            	c.No_Cuota__c = qNumber;
                update c;
            }
            
            qNumber = qNumber + 1;
        }
        
        
        //delete quota > quote number
        Cuota__c[] QuotaToDelete = [select Id 
                                    from Cuota__c
                                    where Presupuesto__c =: oQuote.Id
                                    and No_Cuota__c >: oQuote.Numero_cuotas__c];
        delete QuotaToDelete;
        
    }
}