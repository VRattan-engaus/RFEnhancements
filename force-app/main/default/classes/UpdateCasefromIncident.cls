public  without sharing class UpdateCasefromIncident {
    
    public static void UpdateCase(List<BMCServiceDesk__Incident__c>newInc,List<BMCServiceDesk__Incident__c>OldInc){
        System.debug('newInc >>>>' + newInc);
        System.debug('OldInc >>>' + OldInc);
        List<Id> incCaseId = new List<Id>();
        List<BMCServiceDesk__Incident__c> lstIncWithCase = new List<BMCServiceDesk__Incident__c>();
        Map<BMCServiceDesk__Incident__c,String> mpIncCaseNumber = new Map<BMCServiceDesk__Incident__c,String>(); 
        List<String> lstCaseNo = new List <String>();
        Map<BMCServiceDesk__Incident__c,Case> mpIncCase = new Map<BMCServiceDesk__Incident__c,Case>();
        Map<Id,BMCServiceDesk__Incident__c> mpCaseIdInc = new Map<Id,BMCServiceDesk__Incident__c>();
         Map<Id,BMCServiceDesk__Incident__c> mpOldIncIdInc = new Map<Id,BMCServiceDesk__Incident__c>();
         Map<Id,BMCServiceDesk__Incident__c> mpNewIncIdInc = new Map<Id,BMCServiceDesk__Incident__c>();
         Map<Id,Id> mpCsIdIncId = new Map<Id,Id>();
        List<Case> lstCsToUpdate = new List<Case>();
        for(BMCServiceDesk__Incident__c inc : newInc){
            if(inc.BMCRF_Related_Case_Formula__c!=null){
                lstIncWithCase.add(inc);
                mpNewIncIdInc.put(inc.id,inc);
            }
        }
        
        for(BMCServiceDesk__Incident__c inc : OldInc){
            if(inc.BMCRF_Related_Case_Formula__c!=null){
            	mpOldIncIdInc.put(inc.id,inc);
            }
        }
        
        System.debug('lstIncWithCase>>> ' + lstIncWithCase);
        for(BMCServiceDesk__Incident__c relInc : lstIncWithCase){
            if(lstIncWithCase.size()>0){
                System.debug('In if>>>>');
                mpIncCaseNumber.put(relInc, relInc.BMCRF_Related_Case_Formula__c);
                lstCaseNo.add(relInc.BMCRF_Related_Case_Formula__c);
            }
        }
        System.debug('mpIncCaseNumber >>' + mpIncCaseNumber);
        List<Case> lstRelCase = [Select CaseNumber,Raise_IT_Ticket__c, Description_IT__c, IT_Category__c,Incident_Urgency__c, BMCRF_Case_Comments__c, IT_Application_Type__c, Stage_for_IT_Ticket__c,
                                        EA_Member_No__c,  Contact_s_First_Name__c, Contact_Last_Name__c, Application_Number__c, Contact_s_Email__c, Contact_s_Phone_Number__c, Contact_s_Mobile_No__c,
                                  		BMCRF_New_Case_Comment__c, BMCRF_IT_Status__c from Case where CaseNumber in: lstCaseNo];
        
        for(BMCServiceDesk__Incident__c relInc : mpIncCaseNumber.keyset()){
            mpIncCase.put(relInc,[Select CaseNumber,Raise_IT_Ticket__c, Description_IT__c, IT_Category__c,Incident_Urgency__c, BMCRF_Case_Comments__c, IT_Application_Type__c, Stage_for_IT_Ticket__c,
                                        EA_Member_No__c,  Contact_s_First_Name__c, Contact_Last_Name__c, Application_Number__c, Contact_s_Email__c, Contact_s_Phone_Number__c, Contact_s_Mobile_No__c,
                                  		BMCRF_New_Case_Comment__c, BMCRF_IT_Status__c from Case where CaseNumber =: mpIncCaseNumber.get(relInc)]);
            mpCaseIdInc.put([Select Id from Case where CaseNumber =: mpIncCaseNumber.get(relInc)].Id,relInc);
            mpCsIdIncId.put([Select Id from Case where CaseNumber =: mpIncCaseNumber.get(relInc)].Id,relInc.id);
        }
        
        System.debug('mpIncCase >>>' + mpIncCase);
        System.debug('mpCaseIdInc*** >>>' + mpCaseIdInc);
        
        for(Case cs: lstRelCase){
            System.debug('cs details in for>>' + cs.Id);
            
            cs.Description_IT__c = mpCaseIdInc.get(cs.Id).BMCServiceDesk__incidentDescription__c;
            cs.Incident_Urgency__c = [Select id,name from BMCServiceDesk__Urgency__c where id =: mpCaseIdInc.get(cs.Id).BMCServiceDesk__FKUrgency__c].name;
            System.debug('Category>>>' + mpCaseIdInc.get(cs.Id).BMCServiceDesk__Category_ID__c);
            String[] catSplit = mpCaseIdInc.get(cs.Id).BMCServiceDesk__Category_ID__c.split('-');
            
            if(catSplit.size() > 0){
            	System.debug('catSplit[0] value ****>>' + catSplit[0]);
                if(catSplit[0] != 'Other'){
                    cs.IT_Category__c = 'myPortal';
                	cs.IT_Application_Type__c = catSplit[0];
                }
                else if(catSplit[0] != 'Other'){
                    cs.IT_Category__c = 'Other Issues';
                }
                
            	
            }
            if(catSplit.size() > 1){
                System.debug('catSplit[1]>>' + catSplit[1]);
            	cs.Stage_for_IT_Ticket__c = catSplit[1];
            }
            cs.Application_Number__c = mpCaseIdInc.get(cs.Id).BMCRF_Contact_Application_ID__c;
            if((mpOldIncIdInc.get(mpCsIdIncId.get(cs.Id)).BMCServiceDesk__incidentDescription__c != mpNewIncIdInc.get(mpCsIdIncId.get(cs.Id)).BMCServiceDesk__incidentDescription__c) ||
               (mpOldIncIdInc.get(mpCsIdIncId.get(cs.Id)).BMCServiceDesk__Category_ID__c != mpNewIncIdInc.get(mpCsIdIncId.get(cs.Id)).BMCServiceDesk__Category_ID__c)||
               (mpOldIncIdInc.get(mpCsIdIncId.get(cs.Id)).BMCRF_Contact_Application_ID__c != mpNewIncIdInc.get(mpCsIdIncId.get(cs.Id)).BMCRF_Contact_Application_ID__c)||
               (mpOldIncIdInc.get(mpCsIdIncId.get(cs.Id)).BMCServiceDesk__FKStatus__c != mpNewIncIdInc.get(mpCsIdIncId.get(cs.Id)).BMCServiceDesk__FKStatus__c)){
            		cs.Status = 'IT Ticket Updated';
               }
            System.debug('BMCRF_Category_Level__c>>>' + mpCaseIdInc.get(cs.Id).BMCRF_Category_Level__c);
            lstCsToUpdate.add(cs);
        }
        
        System.debug('lstCsToUpdate>>>' + lstCsToUpdate);
        if(lstCsToUpdate.size()>0){
            try{
            	update lstCsToUpdate;
            }
            Catch(Exception e){
                System.debug('Exception >>>' + e);
            }
        }
    }
}