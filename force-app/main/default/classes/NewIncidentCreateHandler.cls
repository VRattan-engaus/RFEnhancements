/**************************************************************
* NewIncidentCreateHandler is invoked from IncidentToCaseUpdateTrigger.apxt
* This class is used to formulate incident object before a ticket is submitted
* using Submit a Ticket
* Rev1: Dec 2019 Vandana Rattan
*************************************************************** */
public with sharing class NewIncidentCreateHandler {
    public NewIncidentCreateHandler() {

    }

    //HandleCreate method is used to create Incident object before being submitted or updated.
    public static void HandleCreate(List<BMCServiceDesk__Incident__c>newInc){

        System.debug('In HandleCreate');
        System.debug('newInc >>>' + newInc);
        Boolean isSR = false;
        String strIncCat = '';
        List<BMCServiceDesk__Category__c> lstIncCat = [Select id, name from BMCServiceDesk__Category__c];
        //Map yp hold Incident Categories
        Map<String, BMCServiceDesk__Category__c> mpIncCat = new Map<String, BMCServiceDesk__Category__c>();
        

        //Put Incident Categories into Map
        for(BMCServiceDesk__Category__c cat: lstIncCat){
            mpIncCat.put(cat.name,cat);
        }

        System.debug('Map of Categories >>' + mpIncCat);

        //Looping through the list of new incidents to formulate the incident record to be submitted
        for(BMCServiceDesk__Incident__c inc: newInc){
            System.debug('Type_of_ticket__c >>>' + inc.Type_of_ticket__c);
            if((inc.Type_of_ticket__c).contains('Is something broken')){
                isSR = false;
                System.debug('type of Fault >>' + inc.Type_of_Fault__c);
                if(inc.Type_of_Fault__c == 'MyPortal'){
                    strIncCat = inc.Subcategory__c +' '+'-'+' '+inc.Subcategory_1__c;    
                }
                else if(inc.Type_of_Fault__c == 'Cvent' || inc.Type_of_Fault__c != 'Salesforce'){
                    strIncCat = 'Application - '+ (inc.Type_of_Fault__c);
                }
                else if(inc.Type_of_Fault__c == 'Other'){
                    strIncCat = 'Other';
                }
                System.debug('strIncCat >>' + strIncCat);
                //Get Category from map based on name
                inc.BMCServiceDesk__FKCategory__c = mpIncCat.get(strIncCat).Id;
                 System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                 //Set incident description
                 inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
            }
            else if((inc.Type_of_ticket__c).contains('Do you Require something')){
                isSR = true;
            }
        }

    }
}
