/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Enero 28 de 2014
*  Decripción:          Clase que contiene los parametros que se envian y se reciben al SW de chequeo de credito
*  @version:            1.0
* ===================================================================================================================================
**/




/**************************************************************************************/
/*                OBJETOS EMPLEADOS EN EL LLAMADO AL SW DE CHEQUEO                    */
/*                              REQUEST Y RESPONSE                                    */
/*************************************************************************************/  


public class CL008_Sap_ConsCupoCredit_ObjectsSF 
{
    
    /****************************************************************************************
    /**********************  SECCION DE DEFINICIONES DEL REQUEST   **************************
    /****************************************************************************************   
    
    /**  Clase que encapsula los atributos  de los parametros Enviados al WS **/        
        
    
    public class RequestChequearCreditos{
           public CreditWorthinessQuery  parCreditWorthinessQuery;
    
                
    }
    
    public class CreditWorthinessQuery {
          public String creditSegmentInternalID;
          public Decimal chekedAmount;
          public String currencyCode;
          public String checkingRuleCode;
          public String checkingSeverityCode;
          public String parCreditAgencyReportRetrievalPermissionIndicator;
          public DebtorPartyRq parDebtorParty;
          public CM1_Info_Adicional  parcm1_Info_Adicional;
    }

    public class CM1_Info_Adicional {         
         public  DT_CM_Basis          parDT_CM_Basis;    
    }


     public class Producto {
        public String moneda{get;set;}
        public String producto{get;set;}
        public Decimal plazo{get;set;}
        public Double monto{get;set;}
        public Double porcentajeCuotaInicual{get;set;}
        public String fMaxPrimeraCuota{get;set;}   //fecha maximo primera cuota
        public String fMaxUltimaCuota{get;set;}      //fecha maxima ultima cuota
        public String Lineaproduccion{get;set;}//JAAR Mostrar la linea de produccion en la consulta de chequeo
                
      } 
     
     public class DT_CM_Basis {
          public String                 organizacionVentas;
          public Producto[]             productos;
          public Seccion[]              secciones;
          public CanalRecaudo[]         canalRecaudo;
          public CanalFacturacion[]     canalFacturacion;   
        
     }
     
      
     public class Seccion {
        public String IdSeccion;        
      } 
      
      public class CanalRecaudo {
        public String idCanalR;     
      }
      
      public class CanalFacturacion {
        public String tipoCanalFacturacion;
      }
        
      public class DebtorPartyRq {
        public String internalId;
      } 
	/****************************************************************************************
	/**********************  SECCION DE DEFINICIONES DEL RESPONSE  **************************
	/****************************************************************************************
	
	/**  Clase que encapsula los	atributos	de los parametros Recibidos al WS **/		
	public class ResponseChequearCreditos{
		public CreditWorthiness parCreditWorthiness;	
	}
	public  class CreditWorthiness{
		public String 			creditSegmentInternalid{get;set;}
		public Boolean 			indicador{get;set;}
		public String 			indicadorFv{ 									//JA representación del valor boolenano de la variable indicador
		get{
				if(indicador)
					 return 'APROBADO'; 
				else
					return 'RECHAZADO';
			}set;}
			
		public String nombrePropuestaComercial {get;set;}
	    public  List<DescripcionMsgRs>			listCheckingDescription{get;set;}	 
		public  String							checkingDescription{get;set;}
		public Boolean 			debtorbartyBlockedIndicator{get;set;}
		public String 			debtorbartyBlockedIndicatorFv{				//JA representación del valor boolenano de la variable debtorbartyBlockedIndicator
		get {
			if(debtorbartyBlockedIndicator)
				return 'SI';
			else
				return 'NO';
		}set;}
		public Boolean          debtorPartySpecialAttentionRequiredIndicator{get;set;}
		public String          debtorPartySpecialAttentionRequiredIndicatorFv{ //JA representación del valor boolenano de la variable debtorPartySpecialAttentionRequiredIndicator
		get{
			if(debtorPartySpecialAttentionRequiredIndicator)
				return 'SI';
			else
				return 'NO';
		}set;}
		
		public Date 			dynamicCheckHorizonEndDate{get;set;}
		public DebtorPartyRS 	debtorPartyRS{get;set;}
		public CreditorPartyRs	parCreditorPartyRS{get;set;}//pend
		public SellerPartyRs    parSellerPartyRS{get;set;} //pend
		public Rating 			rating{get;set;}
		public RiskClass 		riskClass{get;set;}
		public CreditLimit    	creditLimit{get;set;}	
		public CreditExposure 	parCreditExposure{get;set;}
		
		public Double     	    saldo{
		get{
			 return (creditLimit.amount - parCreditExposure.amount);
		   }
		set;}
		
		public DTE_CM1_Info_Adicional_CM  parInfo_Adicional_CM{get;set;}
		
		public Boolean          permiteExcepcion{get;set;}
		public String           permiteExcepcionFv{							//JA representación del valor boolenano de la variable permiteExcepcion
		get {
				if(permiteExcepcion)
					return 'SI';
				else
					return 'NO';
		}set;}
		
		public Boolean 			requiereEstudio{get;set;}
		
		public String 			requiereEstudioFv{							//JA representación del valor boolenano de la variable requiereEstudio
		get{
				if(requiereEstudio)
					return 'SI';
				else
					return 'NO';
			}set;}
			
	}

	  public class DebtorPartyRS {
	 	public String internalId{get;set;}
	  }	
	  
	  public class Rating {
	 	public String 				code{get;set;}
	 	public ValidityPeriod 	validityPeriod{get;set;}
	  }	
	  
	  public class ValidityPeriod {
	 	public Date startDate{get;set;}
	    public Date endDate{get;set;}
	 	
	  }			

	  public class RiskClass {
	 	public String 				code{
	 	get{
	 		if(code == 'B')
	 		return 'BAJO';
	 		else if(code == 'A')
	 		return 'ALTO';
	 		else if (code == 'M')
	 		return 'MEDIO';
	 		else
	 		return 'NO DEFINIDO';
	 	}
	 	set;}
	 	
	 	public validityPeriod 	validityPeriod{get;set;}
	  }		  
	  
	  public class CreditLimit {
	 	public Double 				amount{get;set;}
	 	public ValidityPeriod 	validityPeriod{get;set;}
	 	public String currencyCode{get;set;}	   
	  
	  }		  

	  public class CreditExposure {
	 	public Double amount{get;set;}
	 	public String currencyCode{get;set;}
	  }		  	  

	  public class CreditorPartyRs {
	 	public String internalId;
	  }		 
	  public class SellerPartyRs {
	 	public String internalId;
	  }
	  public class DescripcionMsgRs {
	 	public String mensaje{get;set;}	
	  }	
	  
	  public class DTE_CM1_Info_Adicional_CM{
	  	public Boolean          permiteExcepcion{get;set;}
	  	public String           permiteExcepcionFv{							//OA representación del valor boolenano de la variable permiteExcepcion
		get {
				if(permiteExcepcion)
					return 'SI';
				else
					return 'NO';
		}set;}
		
	    public Boolean 			requiereEstudio{get;set;}
	  }
	  
	 	  		   	    	  	
}