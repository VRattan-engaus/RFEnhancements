trigger IncidentToCaseUpdate on BMCServiceDesk__Incident__c (after update, before insert, before update) {
    public enum triggerAction {beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete}
    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('After Incident updated going to update related case');
        UpdateCasefromIncident.UpdateCase(Trigger.new, Trigger.old);
    }
    if(Trigger.isBefore && (Trigger.isInsert)||(Trigger.isUpdate)){
        System.debug('Before Insert1');
        NewIncidentCreateHandler.HandleCreate(Trigger.new);
        System.debug('Before Insert1');
    
    }
}