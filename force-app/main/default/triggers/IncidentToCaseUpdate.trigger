trigger IncidentToCaseUpdate on BMCServiceDesk__Incident__c (after update) {
    public enum triggerAction {beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete}
    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('After Incident updated going to update related case');
        UpdateCasefromIncident.UpdateCase(Trigger.new, Trigger.old);
    }
    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('Before Insert1');
    
    }
}