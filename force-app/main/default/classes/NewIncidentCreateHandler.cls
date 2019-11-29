public with sharing class NewIncidentCreateHandler {
    public NewIncidentCreateHandler() {

    }

    public static void HandleCreate(List<BMCServiceDesk__Incident__c>newInc){

        System.debug('In HandleCreate');
        System.debug('newInc >>>' + newInc);

    }
}
