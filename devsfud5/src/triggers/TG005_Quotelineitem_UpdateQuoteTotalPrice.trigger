/*
*   Create default quota distribution values
*   26 Febrero 2014 - Juan Horta - TG005_Quotelineitem_UpdateQuoteTotalPrice: update discount percents
*/

trigger TG005_Quotelineitem_UpdateQuoteTotalPrice on QuoteLineItem (before insert, before update) {


    CL010_Discuont_recalc.CalcPercent(Trigger.new);
   

}