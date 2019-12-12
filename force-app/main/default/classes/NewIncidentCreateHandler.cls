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
        List<BMCServiceDesk__SRM_RequestDefinition__c> lstReqDef = [Select id, name from BMCServiceDesk__SRM_RequestDefinition__c];
        //Map to hold Incident Categories
        Map<String, BMCServiceDesk__Category__c> mpIncCat = new Map<String, BMCServiceDesk__Category__c>();
        //Map to hold Service Request Definitions
        Map<String,BMCServiceDesk__SRM_RequestDefinition__c> mpSRDef = new Map<String, BMCServiceDesk__SRM_RequestDefinition__c>();
        

        //Put Incident Categories into Map
        for(BMCServiceDesk__Category__c cat: lstIncCat){
            mpIncCat.put(cat.name,cat);
            System.debug('cat Id::' + cat.Id);
            System.debug('cat.name:::' + cat.name);
        }

         //Put Request Definitions into Map
        for(BMCServiceDesk__SRM_RequestDefinition__c rDef: lstReqDef){
            mpSRDef.put(rDef.name,rDef);
            System.debug('rDef Id::' + rDef.Id);
            System.debug('rDef.name:::' + rDef.name);
        }

        System.debug('Map of Categories >>' + mpIncCat);

        //Looping through the list of new incidents to formulate the incident record to be submitted
        for(BMCServiceDesk__Incident__c inc: newInc){
            System.debug('Type_of_ticket__c >>>' + inc.Type_of_ticket__c);
            if((inc.Type_of_ticket__c!=null) && (inc.Type_of_ticket__c).contains('Is something broken')){
                isSR = false;
                System.debug('type of Fault >>' + inc.Type_of_Fault__c);
                if(inc.Type_of_Fault__c == 'MyPortal'){
                    strIncCat = inc.Subcategory__c +' '+'-'+' '+inc.Subcategory_1__c;    
                }
                else if(inc.Type_of_Fault__c == 'Cvent' || inc.Type_of_Fault__c == 'Salesforce' || inc.Type_of_Fault__c == 'Connx'){
                    strIncCat = 'Application - '+ (inc.Type_of_Fault__c);
                }
                else if(inc.Type_of_Fault__c == 'Other'){
                    strIncCat = 'Other';
                }
                else{
                    strIncCat = inc.Type_of_Fault__c;
                }
                    
                
                System.debug('strIncCat >>' + strIncCat);
                 //System.debug('mpIncCat.get(strIncCat)>>>' + mpIncCat.get(strIncCat));
                System.debug('mpIncCat.get(strIncCat).Id>>>' + mpIncCat.get(strIncCat));
                if(Trigger.isBefore){
                    //Get Category from map based on name
                    inc.BMCServiceDesk__FKCategory__c = mpIncCat.get(strIncCat).Id;
                    System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                    //Set incident description
                    inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                }
            }
            else if((inc.Type_of_ticket__c!=null) && (inc.Type_of_ticket__c).contains('Do you Require something')){
                isSR = true;
                System.debug('Requirement Type >>' + inc.Requirement_Type__c);
                //System.debug('contains req type>>>' + (inc.Requirement_Type__c).contains('Access to a user\'s mailbox or calendar'));
                //System.debug('contains req type2>>>' + (inc.Requirement_Type__c).contains(String.escapeSingleQuotes('Access to a user\'s mailbox or calendar')));
                System.debug('cat ID>>' + mpSRDef.get('Application Access Request').id);
                //Set Category, request definition and decription for Service requests
                if(Trigger.isBefore){
                    //Requirmment Type Access to an application
                    if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Access to an application')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Application Access Request').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Application').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        //Set decription based on field values
                        if(inc.Application_Type__c !='Other'){
                            inc.BMCServiceDesk__incidentDescription__c = 'Application Type: ' + inc.Application_Type__c +'\n'+ 'Details: ' + inc.Details__c;
                        }
                        else{
                            inc.BMCServiceDesk__incidentDescription__c = 'Application Type: ' + inc.Application_Type__c +'\n'+ 'Name of Other Application: '+ inc.Name_of_Other_Application__c + '\n' + 'Details: ' + inc.Details__c;
                        }
                    }
                    //Requirmment Type Request for software Installation
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Request for software Installation')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Request for Software Installation').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Application').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        //Set description
                        if((inc.Software_Requested__c !=null) && (!inc.Software_Requested__c.contains('Other'))){
                            inc.BMCServiceDesk__incidentDescription__c = 'Software Requested: '+ inc.Software_Requested__c + '\n' +'Additional Information: '+  inc.Additional_Information__c;
                        }
                        else{
                            inc.BMCServiceDesk__incidentDescription__c = 'Software Requested: '+ inc.Software_Requested__c + '\n' + 'Name of Software Needed: ' + inc.Name_of_Software_Needed__c  +'\n' +'Additional Information: '+  inc.Additional_Information__c;
                        }
                    }
                    //Requirmment Type Password reset
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Password reset')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Password Resets').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Application').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        //Set description
                        if((inc.Application_Type__c !=null) && (inc.Application_Type__c!='Other')){
                            inc.BMCServiceDesk__incidentDescription__c = 'Application Type: ' + inc.Application_Type__c + '\n' + 'Details: ' + inc.Details__c;
                        }
                        else{
                            inc.BMCServiceDesk__incidentDescription__c = 'Application Type: ' + inc.Application_Type__c + '\n'+ 'Name of Other Application: '+ inc.Name_of_Other_Application__c +'\n' + 'Details: ' + inc.Details__c;
                        }
                    }
                    //Requirmment Type Request for a new email distribution list or amend..
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Request for a new email distribution list or amend')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Email Distribution List').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Distribution list').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        //Set description
                        inc.BMCServiceDesk__incidentDescription__c = 'Type of request for distribution list: '+ inc.Type_of_request_for_distribution_list__c + '\n' + inc.Name_of_Distribution_List__c + '\n' + inc.Additional_Information__c;
                    }
                    //Requirmment Type Shared folder access or ammendments
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Access to shared folders')){
                        System.debug('For shared folder access');
                        System.debug('Shared folders access >>>' + mpSRDef.get('Shared folders access').id);
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Shared folders access').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Shared folder').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                    //Requirmment Type Access to a new or existing shared mailbox
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Access to a new shared mailbox')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Shared mailbox').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Shared Mailbox').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type Access to a uers's mailbox or calendar
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Access to a user\'s mailbox or calendar')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Access user mailbox or calendar').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Access user mailbox or calendar').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type New Employee
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('New Employee')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('New Employee').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('New Employee').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type Employee Departure
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Employee departure')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Departure').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Departures').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type Employee relocation
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Employee relocating')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Relocation').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Relocation').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Public website modification
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Public website Modifications')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Public Website Modifications').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Public Website Modifications').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type VPN
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('VPN access')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('VPN').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('VPN').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type New hardware
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('New hardware')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Hardware Request').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Hardware').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type BI Data Request
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('BI Data request')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('BI Data Requests').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('BI Data Request').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type Global Roaming
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Global Roaming')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Mobile Phone').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Mobile Phone').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type My request is not in the above list
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('My request is not in the above list')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('General Service Request').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('General Request').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                     //Requirmment Type My request is not in the above list
                    else if((inc.Requirement_Type__c != null) && (inc.Requirement_Type__c).contains('Salesforce Request')){
                        inc.BMCServiceDesk__FKRequestDefinition__c = mpSRDef.get('Salesforce Request').id;
                        inc.BMCServiceDesk__FKCategory__c = mpIncCat.get('Salesforce').Id;
                        System.debug('inc.BMCServiceDesk__FKCategory__c >>' + inc.BMCServiceDesk__FKCategory__c);
                        inc.BMCServiceDesk__incidentDescription__c = inc.Details__c;
                    }
                }
            }
        }

    }
}
