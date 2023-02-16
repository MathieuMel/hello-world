trigger LeadAfterUpdate on Lead (after update) {
    
    List<CIN_fleapping_feature__mdt> fleap = [SELECT Label, actif__c FROM CIN_fleapping_feature__mdt WHERE Label = 'fleapping'];
    
    if(fleap[0].actif__c == true){
        
        if (Trigger.isUpdate) {
        
            if (Trigger.isAfter) {
                
                for (Lead leadUpdate : Trigger.new){
                    
                    for (Lead leadOld : Trigger.old){
                        
                        if(leadUpdate.OptInEmail__c != leadOld.OptInEmail__c || leadUpdate.OptInPhone__c != leadOld.OptInPhone__c || leadUpdate.OptInMail__c != leadOld.OptInMail__c || leadupdate.OptInSMS__c != leadOld.OptInSMS__c){
                            
                            CIN_WS002_APIConsent.modificationOfConsent(leadUpdate, leadOld);
                        }                        
                    }
                }
            }
        }        
    }
}