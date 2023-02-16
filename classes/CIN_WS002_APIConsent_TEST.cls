@isTest
public class CIN_WS002_APIConsent_TEST {
    
    @TestSetup
    private static void testSetup() {
        
        Id rcLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('CIN_Lead_Process').getRecordTypeId();
        
        Lead leadtest = new Lead(LastName = 'Lead TEST', RecordTypeId = rcLead, Status = 'New', OptInMail__c = True, OptInPhone__c = True, OptInEmail__c = True, OptInSMS__c = True);
        insert leadtest;
    }

    @isTest
    static void UpdateConsentInRDVTest(){
        
        Test.setMock(HttpCalloutMock.class, new MCK_WS002_APIConsent());
        Lead leadupdate = [SELECT Id, OptInMail__c, OptInPhone__c, OptInEmail__c, OptInSMS__c FROM Lead WHERE LastName = 'Lead TEST'];
        
        Lead leadOld = leadupdate;
        leadOld.OptInMail__c = False;
        leadOld.OptInPhone__c = False;
        leadOld.OptInEmail__c = False;
        leadOld.OptInSMS__c = False;
                
        Test.startTest();

        Database.update(leadOld);
        
        Test.stopTest();
        
    }
}