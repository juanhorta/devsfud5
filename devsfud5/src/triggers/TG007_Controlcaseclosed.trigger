/**                                                     
* ===================================================================================================================================
*  Desarrollado por:    Joe Alexander Ayala
*  Fecha:               Febrero 03 de 2014
*  Decripción:          Trigger para controlar que un caso no se pueda cerrar si tiene sub casos abiertos
*  @version:            1.0
* ===================================================================================================================================
**/

trigger TG007_Controlcaseclosed on Case (after insert, after update) {


      CL012_controlcase logica = new CL012_controlcase();
      logica.ejecutarLogica(Trigger.new, Trigger.old);
}