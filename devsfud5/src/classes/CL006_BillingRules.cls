/*
*	     							Control quota creation and validation rules
*	Jairo Guzman	27 Enero 2013 - UpdateFromAccount: update billing data from account
	JAAR 			06-05-2014 		Se cambiara la logica de la primera cuota para que al guardar deje la fecha que el asesor seleccione.
    JAAR		    09-06-2014      Se agrega campos estado para diferenciar las cuotas nuevas enviadas y anuladas.
*/

public class CL006_BillingRules {
	
	////////////  object params /////////////////////////
	
	public Dato_facturacion__c BillingData{get;private set;}
	
	private map<string,decimal> RelatedQuotes{get;private set;}
	private map<string,Cuota_facturacion__c> CurrentQuotes{get;private set;}
	private map<string,QuoteLineItem> QuoteItems{get;private set;}
	
	private Integer oAllowedQuoteNumber;
	
	// Verifica que maximo se pueda dividir por el maximo numero de  cuotas establecidas a nivel de producto
	// return AllowedQuoteNumber        = numero de cuotas por el cual dividirá 
	private Integer AllowedQuoteNumber{
		get{
			if(oAllowedQuoteNumber == null){
				
				FillQuoteItems();
				oAllowedQuoteNumber = 1;
				for(QuoteLineItem qli:QuoteItems.values()){
					if(qli.PricebookEntry.Product2.Numero_cuotas_maximo__c > oAllowedQuoteNumber){
						oAllowedQuoteNumber = Integer.valueof(qli.PricebookEntry.Product2.Numero_cuotas_maximo__c);
					}
				}
			}
			system.debug('Valor_por_el_cual_dividira  ' + oAllowedQuoteNumber + '\n\n FillQuoteItems_u '+ QuoteItems);
			return oAllowedQuoteNumber;
		}
	}
	
	private decimal oAllowedBillingValue;
	
	private decimal AllowedBillingValue{
		
		get{
			if(oAllowedBillingValue == null){

				FillQuoteItems();
				
				AggregateResult TotalRelatedBilling = null;
				
				if(BillingData.id == null){

					TotalRelatedBilling =
						[select sum(Valor_facturacion__c)Valor_facturacion__c
						from 	Dato_facturacion__c
						where 	Presupuesto__c =: BillingData.Presupuesto__c][0];
				}
				else{

					TotalRelatedBilling =
						[select sum(Valor_facturacion__c)Valor_facturacion__c
						from 	Dato_facturacion__c
						where 	Presupuesto__c =: BillingData.Presupuesto__r.id
								and id !=: BillingData.id][0];
				}
				
				
				
				if(TotalRelatedBilling.get('Valor_facturacion__c') == null){
					oAllowedBillingValue = QuoteItems.values()[0].Quote.TotalPrice;
				}
				else if(QuoteItems.values()[0].Quote.TotalPrice > 
						(decimal)TotalRelatedBilling.get('Valor_facturacion__c')){
					
					oAllowedBillingValue = QuoteItems.values()[0].Quote.TotalPrice - 
						(decimal)TotalRelatedBilling.get('Valor_facturacion__c');
				}						
				else{
					throw new CL006_BillingRules_Exception('Imposible validar valor de facturación.');
				}
			}
			
			return oAllowedBillingValue;
		}
	}
	
	////////////  constructors /////////////////////////
	public CL006_BillingRules(string oIdBillingData){
		FillBillingData(oIdBillingData);

	}
	
	public CL006_BillingRules(Dato_facturacion__c oBillingData){
		BillingData = oBillingData;
	}
	
	////////////  public proccess methods /////////////////////////
	
	/*create new billing record*/
	public void CreateBillingRecord() {
		
		//rectify total billing value
		system.debug('Creando_nuevo_registro_BillingData ' + BillingData);
		BillingData.Valor_facturacion__c = RectifyBillingTotal(BillingData);
		
		//validate billing info
		if(ValidateBillingInfo(BillingData)){
		
			//create billing data
			insert BillingData;
		
			//map con los QuoteLineItem que tiene la cotización 
			FillQuoteItems();
					
			//create billing quotes
			AdjustBillingQuotes(BillingData,0);
			
			//get current quotes
			CurrentQuotes = null;
			FillCurrentQuotes();

			//calc quote standar values
			List<Cuota_facturacion__c> CalcQuote = CalculatedNormalizedQuote
				(BillingData,CurrentQuotes);
			
			//insert billing quotes
			update CalcQuote;
		}
	}
	/*create new billing record*/
	public void UpdateBillingRecord(Dato_facturacion__c bdToUpdate,List<Cuota_facturacion__c> cqToUpdate) {
		system.debug('Update_Dato_de_fact '+ bdToUpdate+'lista_de_cuotas '+cqToUpdate);
		if(bdToUpdate.id == BillingData.Id){
			
			//rectify total billing value
			bdToUpdate.Valor_facturacion__c = RectifyBillingTotal(bdToUpdate);
			
			//validate billing info
			if(ValidateBillingInfo(bdToUpdate)){
				
				//create billing quotes
				AdjustBillingQuotes(bdToUpdate,Integer.valueof(BillingData.Numero_cuotas__c));
				
				//Mapa con las cuotas get current quotes
				FillCurrentQuotes();
				
				//refresh update values
				if(!bdToUpdate.Cuota_normalizada__c){
                system.debug('no_es_cuota_normalizada '+bdToUpdate.Cuota_normalizada__c );
					for(Cuota_facturacion__c cqupd:cqToUpdate){
							
						//get object to update
						Cuota_facturacion__c updQuota = (Cuota_facturacion__c)CurrentQuotes.get
							(cqupd.Dato_facturacion__c + '_' + 
							cqupd.Partida_de_presupuesto__c + '_' + 
							string.valueof(cqupd.No_Cuota__c));

						if(updQuota != null){
							//update quota value
							updQuota.Valor_cuota__c = cqupd.Valor_cuota__c.round(System.RoundingMode.HALF_UP);
							//update quote date allways get day in 1
							updQuota.Fecha_cuota__c = Date.newInstance(cqupd.Fecha_cuota__c.year(), cqupd.Fecha_cuota__c.month(), 1); 
						}
					}
				}				
	
				List<Cuota_facturacion__c> CalcQuote = new List<Cuota_facturacion__c>(); 
				//calc quote standar values
				if(bdToUpdate.Cuota_normalizada__c){
					CalcQuote = CalculatedNormalizedQuote
						(bdToUpdate,CurrentQuotes);
				}
				else{
					CalcQuote = CalculatedNonNormalizedQuote
						(bdToUpdate,CurrentQuotes);
				}				
					
				//update quote info						
				update CalcQuote;
						
				//update billing information
				update bdToUpdate;
				BillingData = bdToUpdate;
			}				
		}
		else{
			throw new CL006_BillingRules_Exception('El dato de facturación a actualizar no coincide con el dato de facturación existente.');
		}
	}	
	
	////////////  private logic methods /////////////////////////
	/*rectify total billing value
	Recibe la info del dato de facturación 
	Retorna valor del dato*/
	
	private decimal RectifyBillingTotal(Dato_facturacion__c ovBillingData){

		decimal oRetorno = ovBillingData.Valor_facturacion__c;	

		if(((oRetorno - AllowedBillingValue) < (0.9) &&
			(oRetorno - AllowedBillingValue) > 0) ||
		 	((AllowedBillingValue - oRetorno) < (0.9) &&
		 	(AllowedBillingValue - oRetorno) > 0)){
				 	
		 	oRetorno = AllowedBillingValue;
 		}			
 		
 		return oRetorno;
	}

	/*validate billing info*/
	private Boolean ValidateBillingInfo(Dato_facturacion__c ovBillingData){
		
		Boolean oRetorno = true;
		system.debug('\n\n 1 - validar_valor_maximo_del_dato ' + AllowedBillingValue);	 
		//validate allowed values
		if(ovBillingData.Valor_facturacion__c <= AllowedBillingValue &&
			ovBillingData.Valor_facturacion__c > 0){}
		else{
			throw new CL006_BillingRules_Exception('El valor de la factura debe ser mayor a cero (0) y menor a ' + string.valueof(AllowedBillingValue));
		}
		
		
		//JAAR - 17-02-2014 -------------FACTURACION POR CUOTAS IGUALES O FACTURACION ESPECIAL --------------------------------------------------
	  if(ovBillingData.billing_type__c == 'Facturación por cuotas iguales'||ovBillingData.billing_type__c =='Facturación Especial')
	   {
			system.debug('Facturación por_cuotas_iguales' );	
		//validate quote number
		if(ovBillingData.Numero_cuotas__c <= AllowedQuoteNumber &&
			ovBillingData.Numero_cuotas__c > 0){}
		else{
			throw new CL006_BillingRules_Exception('El número de cuotas debe ser mayor a cero (0) y menor o igual a ' + string.valueof(AllowedQuoteNumber));
		}
	  }
	  //----------------------------------------------------------------------------------------------------------------------		
		
	//valida que el numero de cuotas sea menor al maximo definido de todos los productos
		
		//validate date number
		if(ovBillingData.Fecha_primera_cuota__c > Datetime.now()){}
		else{
			throw new CL006_BillingRules_Exception('La fecha de la primera cuota debe ser mayor a la fecha actual.' +ovBillingData.Fecha_primera_cuota__c + ' datetime '+ Datetime.now());
		}
		//hasta aqui jaar
		//get first quote date
		//JAAR 06-05-2014 Se cambiara la logica de la primera cuota para que al guardar deje la fecha que el asesor seleecione.
		//JAAR ovBillingData.Fecha_primera_cuota__c = Date.newInstance(ovBillingData.Fecha_primera_cuota__c.year(), ovBillingData.Fecha_primera_cuota__c.month(), 1);
		
		if(ovBillingData.Fecha_primera_cuota__c < Date.today()){
			//ovBillingData.Fecha_primera_cuota__c = ovBillingData.Fecha_primera_cuota__c.addMonths(1);
		}		
			
		return oRetorno;
	}
	
	
	
	/*adjust billing quotes crea las cuotas del dato de facturacion
	Recibe LastQuoteNumber = 0 si es nuevo registro y numero de cuotas del dato si es modificacion
	
	*/
	private void AdjustBillingQuotes(Dato_facturacion__c ovBillingData,Integer LastQuoteNumber){
		
	//map con los QuoteLineItem que tiene la cotización 
	FillQuoteItems();
	//JAAR - 17-02-2014 -------------FACTURACION POR CUOTAS IGUALES O FACTURACION ESPECIAL --------------------------------------------------------
	if(ovBillingData.billing_type__c == 'Facturación por cuotas iguales'||ovBillingData.billing_type__c =='Facturación Especial')
	 {
		//si tiene mas cuotas de las ingresadas borra el resto de cuotas 
		if(ovBillingData.Numero_cuotas__c < LastQuoteNumber){
			
			//remove quote higher than need
			Cuota_facturacion__c[] QuoteToRemove =
				[select	id
				from	Cuota_facturacion__c
				where 	Dato_facturacion__c =: ovBillingData.Id
						and No_Cuota__c >: ovBillingData.Numero_cuotas__c];
			system.debug('borraremos_las_cuotas_sobrantes '+QuoteToRemove + '\n\n');				
			delete QuoteToRemove;
		
		}
		else if(ovBillingData.Numero_cuotas__c > LastQuoteNumber){
		
			//create billing quotes
			List<Cuota_facturacion__c> lstNewQuota = new List<Cuota_facturacion__c>();
			 
 			for(QuoteLineItem qli:QuoteItems.values()){
							
				for(Integer i = (LastQuoteNumber + 1) ; i <= ovBillingData.Numero_cuotas__c ; i++){

					//validate max quotation allowed
					//if(i <= qli.PricebookEntry.Product2.Numero_cuotas_maximo__c){
						
						Cuota_facturacion__c NewQuota = new Cuota_facturacion__c();
						
						NewQuota.Dato_facturacion__c = ovBillingData.Id;
						NewQuota.No_Cuota__c = i;
						NewQuota.Estado__c = 'N'; //JAAR 09-06-2014 Se agrega campos estado para diferenciar las cuotas nuevas enviadas y anuladas.
						NewQuota.Partida_de_presupuesto__c = qli.Id;
						NewQuota.Valor_cuota__c = 0;
						NewQuota.Fecha_cuota__c = Date.Today();
						
						lstNewQuota.add(NewQuota);
					//}
				}
			}
						
			//insert billing quotes
			insert lstNewQuota;		
		}
	 		
		///// validate product modifications /////

		Integer ovCurrentTotalProductCount = 
			[select Partida_de_presupuesto__c 
			from 	Cuota_facturacion__c
			where 	Dato_facturacion__c =: ovBillingData.Id
			group by Partida_de_presupuesto__c].size();
			
		if(QuoteItems.size() != ovCurrentTotalProductCount){
		
			//remove all quotes
			Cuota_facturacion__c[] QuoteToRemove =
				[select	id
				from	Cuota_facturacion__c
				where 	Dato_facturacion__c =: ovBillingData.Id];
						
			delete QuoteToRemove;
			
			//create all quotes
			List<Cuota_facturacion__c> lstNewQuota = new List<Cuota_facturacion__c>();
			 
 			for(QuoteLineItem qli:QuoteItems.values()){
							
				for(Integer i = 1 ; i <= ovBillingData.Numero_cuotas__c ; i++){

					//validate max quotation allowed
					//if(i <= qli.PricebookEntry.Product2.Numero_cuotas_maximo__c){
						
						Cuota_facturacion__c NewQuota = new Cuota_facturacion__c();
						
						NewQuota.Dato_facturacion__c = ovBillingData.Id;
						NewQuota.No_Cuota__c = i;
						NewQuota.Partida_de_presupuesto__c = qli.Id;
						NewQuota.Valor_cuota__c = 0;
						NewQuota.Fecha_cuota__c = Date.Today();
						NewQuota.Estado__c = 'N'; //09-06-2014 JAAR se agrega campos estado para diferenciar las cuotas nuevas enviadas y anuladas.
						lstNewQuota.add(NewQuota);
					//}
				}
			}
						
			//insert billing quotes
			insert lstNewQuota;	
		}
	}
 }	
	//----------------------------------------------------------------------------------------------------------------------
	
	/*calc normalized quote*/
	private List<Cuota_facturacion__c> CalculatedNormalizedQuote
			(Dato_facturacion__c oQuoteBillingInfo
			,map<string,Cuota_facturacion__c> oQuoteToCalc){
		
		//get quote list to return
		List<Cuota_facturacion__c> oRetorno = new List<Cuota_facturacion__c>();
		
		//get current quotes info
		FillRelatedQuotes();				
			
		//map con los QuoteLineItem que tiene la cotización 
		FillQuoteItems();
		
		//get total value percent
		decimal ovTotalPercent = oQuoteBillingInfo.Valor_facturacion__c/((QuoteLineItem)QuoteItems.values()[0]).Quote.TotalPrice;
		Boolean ovQuoteHasDecimals = (oQuoteBillingInfo.Valor_facturacion__c.round(System.RoundingMode.UP) != oQuoteBillingInfo.Valor_facturacion__c.round(System.RoundingMode.DOWN)); 
		
		decimal ovSumValue = 0, ovQuoteSumValue = 0, ovProductCount = 1;

		for(QuoteLineItem qli : QuoteItems.values()){

			//get quote number
			decimal ovQuoteNumber = oQuoteBillingInfo.Numero_cuotas__c;
			/* comentariado para cuotas iguales
			if(ovQuoteNumber > qli.PricebookEntry.Product2.Numero_cuotas_maximo__c){
				ovQuoteNumber = qli.PricebookEntry.Product2.Numero_cuotas_maximo__c;
			}
            */
			//get related product quote total
			decimal ovRelatedProductQuoteTotal = RelatedQuotes.get(qli.id);

			//get value missing value
			Boolean ovProductHasDecimals = (qli.TotalPrice.round(System.RoundingMode.UP) != qli.TotalPrice.round(System.RoundingMode.DOWN));
			decimal ovMissingValue = ovTotalPercent * qli.TotalPrice;
			system.debug('valor_de_cuota__que falta '+qli.id +'   ' + ovMissingValue);
			
			//get quote value
			decimal ovEstimatedValue = ovMissingValue/ovQuoteNumber;
			system.debug('valor_de_cuota__estimado'+qli.id +'   ' + ovEstimatedValue);
			ovEstimatedValue = ovEstimatedValue;
			
			//start quote sum value
			ovQuoteSumValue = 0;
			
			//get start quote date
			Date ovCurrentDate = oQuoteBillingInfo.Fecha_primera_cuota__c;
			
			for(Integer i = 1; i<=ovQuoteNumber; i++){
				
				Cuota_facturacion__c ovQuoteItemToCalc = (Cuota_facturacion__c)oQuoteToCalc.get
					(oQuoteBillingInfo.id + '_' + 
					qli.id + '_' + 
					string.valueof(i));
					
				////////// Date value calculation //////////////
				ovQuoteItemToCalc.Fecha_cuota__c = ovCurrentDate;
				
				//add 1 month for next quote
				ovCurrentDate = ovCurrentDate.addMonths(1);
				
				////////// Quote value calculation /////////////

				//get standar quote
				ovQuoteItemToCalc.Valor_cuota__c = ovEstimatedValue.round(System.RoundingMode.HALF_UP);
				
				if(i == ovQuoteNumber){
					
					//last quote for product excedent on normalization calc
					ovQuoteItemToCalc.Valor_cuota__c = ovMissingValue - ovQuoteSumValue;
				}				

				//sum total
				ovSumValue = ovSumValue + ovQuoteItemToCalc.Valor_cuota__c;
				ovQuoteSumValue = ovQuoteSumValue + ovQuoteItemToCalc.Valor_cuota__c;
				
				oRetorno.add(ovQuoteItemToCalc);
			}
			
			ovProductCount = ovProductCount + 1;
		}

		if(ovSumValue.round(System.RoundingMode.HALF_UP) != 
			oQuoteBillingInfo.Valor_facturacion__c.round(System.RoundingMode.HALF_UP)){
				
			throw new CL006_BillingRules_Exception('La sumatoria de las cuotas (' + 
				string.valueof(ovSumValue) + 
				') debe tener como resultado el valor total (' + 
				string.valueof(oQuoteBillingInfo.Valor_facturacion__c) +
				')');
		}
		
		return oRetorno;	
	}
	
	
	private List<Cuota_facturacion__c> CalculatedNonNormalizedQuote
			(Dato_facturacion__c oQuoteBillingInfo
			,map<string,Cuota_facturacion__c> oQuoteToCalc){
		system.debug('Calculando_cuotas_no_normalizadas '+oQuoteToCalc + '\n\n' ); 
		//get quote list to return
		List<Cuota_facturacion__c> oRetorno = new List<Cuota_facturacion__c>();
		
		//obtener información actual de cotizaciones
		FillRelatedQuotes();				
			
		//map con los QuoteLineItem que tiene la cotización 
		FillQuoteItems();
		
		//get total value percent
		Boolean ovQuoteHasDecimals = (oQuoteBillingInfo.Valor_facturacion__c.round(System.RoundingMode.UP) != oQuoteBillingInfo.Valor_facturacion__c.round(System.RoundingMode.DOWN)); 
		
		decimal ovSumValue = 0, ovQuoteSumValue = 0, ovProductCount = 1;
         //recorrer los productos 
		for(QuoteLineItem qli : QuoteItems.values()){

			//get quote number - numero de cuotas del dato < cuotas po prod 
			decimal ovQuoteNumber = oQuoteBillingInfo.Numero_cuotas__c;
			/* --------comentariado para cuotas iguales
			if(ovQuoteNumber > qli.PricebookEntry.Product2.Numero_cuotas_maximo__c){
				ovQuoteNumber = qli.PricebookEntry.Product2.Numero_cuotas_maximo__c;
			}
           */
			//get related product quote total
			decimal ovRelatedProductQuoteTotal = RelatedQuotes.get(qli.id);

			//get value missing value
			Boolean ovProductHasDecimals = (qli.TotalPrice.round(System.RoundingMode.UP) != qli.TotalPrice.round(System.RoundingMode.DOWN));

			decimal ovMaxMissingValue = qli.TotalPrice;
			system.debug('valor_maximo_por_producto ' + ovMaxMissingValue);
			if(ovSumValue >= oQuoteBillingInfo.Valor_facturacion__c){
				//total billing value exceed
				ovMaxMissingValue = 0;
			}
			else{
				if(ovRelatedProductQuoteTotal != null){
					
					if(qli.TotalPrice > ovRelatedProductQuoteTotal){
						//max missing value less related quotes total
						ovMaxMissingValue = qli.TotalPrice - ovRelatedProductQuoteTotal;
					}
					else{
						//product value covered in related quotes
						ovMaxMissingValue = 0;
					}
				}
				system.debug('ovMaxMissingValue '+ovMaxMissingValue + ' Valor_facturacion__c '+oQuoteBillingInfo.Valor_facturacion__c +' ovSumValue '+ovSumValue  );
				if(ovMaxMissingValue > (oQuoteBillingInfo.Valor_facturacion__c - ovSumValue)){
					//max missing value cant be greater than billing total
					ovMaxMissingValue = oQuoteBillingInfo.Valor_facturacion__c - ovSumValue;
				}
			}

			//start quote sum value
			ovQuoteSumValue = 0;
			
			//get start quote date
			Date ovCurrentDate = oQuoteBillingInfo.Fecha_primera_cuota__c;
			Date ovLastDate = oQuoteBillingInfo.Fecha_primera_cuota__c;
			
			for(Integer i = 1; i<=ovQuoteNumber; i++){
				
				Cuota_facturacion__c ovQuoteItemToCalc = (Cuota_facturacion__c)oQuoteToCalc.get
					(oQuoteBillingInfo.id + '_' + 
					qli.id + '_' + 
					string.valueof(i));
				system.debug('cuota_actual '+ovQuoteItemToCalc);		
				////////// Date value calculation //////////////
				if(i == 1){
					ovQuoteItemToCalc.Fecha_cuota__c = ovCurrentDate;
				}
				else if(ovQuoteItemToCalc.Fecha_cuota__c < ovLastDate){
					ovQuoteItemToCalc.Fecha_cuota__c = ovCurrentDate;
				}
				//add 1 month for next quote
				ovCurrentDate = ovQuoteItemToCalc.Fecha_cuota__c.addMonths(1);
				ovCurrentDate = Date.newInstance(ovCurrentDate.year(), ovCurrentDate.month(), 1);				
				//save last quote date
				ovLastDate = ovQuoteItemToCalc.Fecha_cuota__c;
				
				
				////////// Quote value calculation /////////////

				//adjust non standar quote
				if(ovQuoteItemToCalc.Valor_cuota__c > (ovMaxMissingValue - ovQuoteSumValue)){
					system.debug('Valor_cuota__c_mayor_al_max de prod' );
					ovQuoteItemToCalc.Valor_cuota__c = ovMaxMissingValue - ovQuoteSumValue;
				}			
				
				if(i == ovQuoteNumber && ovProductCount == QuoteItems.values().size()){
					system.debug('validar_Valor_facturacion_diferente_al_calculo:_de cuotas ' + oQuoteBillingInfo.Valor_facturacion__c + ' ovSumValue ' + ovSumValue+ ' Valor_cuota__c ' + ovQuoteItemToCalc.Valor_cuota__c);
					if(oQuoteBillingInfo.Valor_facturacion__c != (ovSumValue + ovQuoteItemToCalc.Valor_cuota__c)){
					
						if(ovSumValue > oQuoteBillingInfo.Valor_facturacion__c){
							ovQuoteItemToCalc.Valor_cuota__c = ovSumValue - oQuoteBillingInfo.Valor_facturacion__c;
						}
						else if(oQuoteBillingInfo.Valor_facturacion__c > ovSumValue){
							ovQuoteItemToCalc.Valor_cuota__c = oQuoteBillingInfo.Valor_facturacion__c - ovSumValue;
						}
					}
				}	
				
				if(ovQuoteItemToCalc.Valor_cuota__c < 0){
					//remove negative values
					ovQuoteItemToCalc.Valor_cuota__c = 0;
				}

				ovSumValue = ovSumValue + ovQuoteItemToCalc.Valor_cuota__c;
				ovQuoteSumValue = ovQuoteSumValue + ovQuoteItemToCalc.Valor_cuota__c;
				
				oRetorno.add(ovQuoteItemToCalc);
				system.debug('valor_final '+ oRetorno);
			}
			
			ovProductCount = ovProductCount + 1;
		}

		if(ovSumValue.round(System.RoundingMode.HALF_UP) != 
			oQuoteBillingInfo.Valor_facturacion__c.round(System.RoundingMode.HALF_UP)){
				
			throw new CL006_BillingRules_Exception('La sumatoria de las cuotas (' + 
				string.valueof(ovSumValue) + 
				') debe tener como resultado el valor total (' + 
				string.valueof(oQuoteBillingInfo.Valor_facturacion__c) +
				')');
		}
		
		return oRetorno;
	}	
	
	////////////  read data methods /////////////////////////
	
	/*fill billing data object*/
	private void FillBillingData(string oIdBillingData){
	system.debug('oIdBillingData_1   '+ oIdBillingData);	
		BillingData = 
			[select	id
					,Name
					,Agente_facturacion__c
					,Agente_recaudo__c
					,Celular__c
					,Ciudad_facturacion__c
					,Ciudad_telefono_facturacion__c
					,Correo_facturacion__c
					,Direccion_facturacion__c
					,Fecha_primera_cuota__c
					,Numero_cuotas__c
					,Numero_identificacion__c
					,Razon_social__c
					,Telefono_contacto_financiero__c
					,Tipo_identificacion__c
					,Valor_facturacion__c
					
					,Presupuesto__r.id
					,Presupuesto__r.TotalPrice

			from	Dato_facturacion__c
			where 	id =: oIdBillingData][0];
	system.debug('BillingData_2   '+ BillingData);
	}
	
	/*fill Current Quotes*/
	private void FillCurrentQuotes(){
		
		if(CurrentQuotes == null){
			
			Cuota_facturacion__c[] olstObject =
				[select	id
						,No_Cuota__c
						,Partida_de_presupuesto__c
						,Valor_cuota__c
						,Fecha_cuota__c
						,Estado__c
						,Dato_facturacion__c
				from	Cuota_facturacion__c
				where 	Dato_facturacion__c =: BillingData.Id
				order by Dato_facturacion__c,No_Cuota__c];
				
			CurrentQuotes = new map<string,Cuota_facturacion__c>();
			
			for(Cuota_facturacion__c cbd:olstObject){
				
				CurrentQuotes.put
					(cbd.Dato_facturacion__c + '_' + 
					cbd.Partida_de_presupuesto__c + '_' + 
					string.valueof(cbd.No_Cuota__c),cbd);
			}					
		}	
	}
	
	/*fill Related Quotes*/
	private void FillRelatedQuotes(){
		
		if(RelatedQuotes == null){
			
			AggregateResult[] olstObject =
				[select	Partida_de_presupuesto__c
						,sum(Valor_cuota__c)Valor_cuota__c
				from	Cuota_facturacion__c
				where 	Dato_facturacion__c !=: BillingData.Id
						and Dato_facturacion__r.Presupuesto__c =: BillingData.Presupuesto__c
				group by Partida_de_presupuesto__c
				order by Partida_de_presupuesto__c];	
				
			RelatedQuotes = new map<string,decimal>();

			for(AggregateResult rbd:olstObject){
				
				RelatedQuotes.put(
					string.valueof(rbd.get('Partida_de_presupuesto__c'))
					,(decimal)rbd.get('Valor_cuota__c'));
			}
			system.debug('\n\n Calculando_otras_cuotas ' + RelatedQuotes);					
		}	
	}
	
	/*fill quote items
	LLena un map con los QuoteLineItem que tiene la cotización 
	return ====  QuoteItems 
	*/
	private void FillQuoteItems(){
		
		if(QuoteItems == null){
			
			QuoteLineItem[] olstObject = 
				[select	id
						,TotalPrice
						
						,Quote.TotalPrice
						
						,PricebookEntry.Product2.id
						,PricebookEntry.Product2.Numero_cuotas_maximo__c
				from 	QuoteLineItem
				where 	QuoteId =: BillingData.Presupuesto__c];
				
			QuoteItems = new map<string,QuoteLineItem>();
			
			for(QuoteLineItem qli:olstObject){
				QuoteItems.put(qli.id,qli);
			}				
		}
	}
	
	/*Exception class*/	
	public class CL006_BillingRules_Exception extends Exception{}
}