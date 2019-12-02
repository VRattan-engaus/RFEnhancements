public with sharing class NewIncidentCreateHandler {
    public NewIncidentCreateHandler() {

    }

    public static void HandleCreate(List<BMCServiceDesk__Incident__c>newInc){

        System.debug('In HandleCreate');
        System.debug('newInc >>>' + newInc);
        Boolean isSR = false;
        String strIncCat = '';
        for(BMCServiceDesk__Incident__c inc: newInc){
            System.debug('Type_of_ticket__c >>>' + inc.Type_of_ticket__c);
            if(inc.Type_of_ticket__c == 'Is something broken (e.g. did work but no longer does)'){
                isSR = false;
                System.debug('type of Fault >>' + inc.Type_of_Fault__c);
                if(inc.Type_of_Fault__c == 'MyPortal'){
                    strIncCat = inc.Subcategory__c +' '+'-'+' '+inc.Subcategory_1__c;    
                }
                else if(inc.Type_of_Fault__c == 'Cvent' || inc.Type_of_Fault__c != 'Salesforce'){
                    strIncCat = 'Application - '+ (inc.Type_of_Fault__);
                }

                System.debug('strIncCat >>' + strIncCat);
            }
            else if(inc.Type_of_ticket__c == 'Do you Require something (e.g. access, hardware)'){
                isSR = true;
            }
        }

    }
}
