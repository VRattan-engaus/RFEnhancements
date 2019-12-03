/**************************************************************
* IncidentToCaseUpdate apex trigger is used to invoke UpdateCasefromIncident
* and NewIncidentCreateHandler to update case when related Incedent is updated or
* formulate the Incident object when Submit a Ticket button is used to
* create tickets.
* 
* Rev1: Dec 2019 Vandana Rattan
*************************************************************** */
trigger IncidentToCaseUpdate on BMCServiceDesk__Incident__c (after update, before insert, before update) {
    public enum triggerAction {beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete}
    
    //Call UpdateCaseFromIncident
    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('After Incident updated going to update related case');
        UpdateCasefromIncident.UpdateCase(Trigger.new, Trigger.old);
    }
    //Call NewIncidentCreateHandler
    if(Trigger.isBefore && (Trigger.isInsert)||(Trigger.isUpdate)){
        System.debug('Before Insert1');
        NewIncidentCreateHandler.HandleCreate(Trigger.new);
        System.debug('Before Insert1');
    
    }
}