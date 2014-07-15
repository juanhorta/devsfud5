/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Febrero 03 de 2014
*  Decripción:          Clase que controla que un caso no se pueda cerrar si tiene sub casos abiertos
*  @version:            1.0
* ===================================================================================================================================
**/

public with sharing class CL012_controlcase 
{


 public void ejecutarLogica( List<Case> lstNewCases, List<Case> lstOldCases )
 {
 	 List<String> lstCaseId = new List<String>();
 	 Set<String> setSubcasesOpenByCase = new Set<String>();
 	 
 	 For(Case caseRecord: lstNewCases)
        {
        	if ((caseRecord.Status == 'Cerrado') )
            {
                lstCaseId.add(caseRecord.Id);
            }
        }
      
      List<Case> caseQuery = [SELECT
                                ParentId
                                FROM
                                Case
                                WHERE
                                ParentId IN :lstCaseId
                                AND (IsClosed = FALSE OR IsClosed = null)
                                LIMIT 1000]; 
      System.debug('\n\n****Cantidad_de_Queries_consumidos_por_este_proceso: ' + Limits.getQueries());                          
      for (Case subcaseRecord: caseQuery)
        {
            setSubcasesOpenByCase.add(subcaseRecord.ParentId);
        }                            
 	 
 	 For(Case caseRecord: lstNewCases)
        {
            if ((caseRecord.Status == 'Cerrado') )
            {
                if (setSubcasesOpenByCase.contains(caseRecord.Id))
                {
                    caseRecord.addError('Operación no permitida, el caso no puede ser cerrado porque tiene subcasos abiertos');
                }
            }
        }
 
 }
}