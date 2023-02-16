public class CIN_WS002_APIConsent {
    
    public static String token { get; set; }
    public static CalloutUtility.CalloutResult log = new CalloutUtility.CalloutResult();
    
    public class WrapperConsent{
        
        public String actorId {get;set;}
        public String activityName {get;set;}
        public String countryCode {get;set;}
		public List<WrapperConsentDetail> consentDetail {get;set;}
        
        public WrapperConsent(List<WrapperConsentDetail> lstConsent){
            this.actorId = null;
            this.activityName = null;
            this.countryCode = null;
            this.consentDetail = lstConsent;
        }
    }
    
    public class WrapperConsentDetail{
        
        public String consentId {get;set;}
        public String consentAllowed {get;set;}
        public String consentLastUpdate {get;set;}
        public String consentCategory {get;set;}
        public String consentType {get;set;}
        public String consentChannel {get;set;}
        public String consentSource {get;set;}
        
        public WrapperConsentDetail(){
            this.consentId = null;
            this.consentAllowed = null;
            this.consentLastUpdate = null;
            this.consentCategory = null;
            this.consentType = null;
            this.consentChannel = null;
            this.consentSource = null;
        }
    }
    
    public static void modificationOfConsent(Lead leadUpdate, Lead leadOld){
        
        Boolean valeur;
        valeur =(leadUpdate.OptInEmail__c != leadOld.OptInEmail__c) ? true : false;                        
        Boolean emailChange = valeur;
        system.debug('email modifié = ' + emailChange);
        valeur =(leadUpdate.OptInPhone__c != leadOld.OptInPhone__c) ? true : false;
        Boolean phoneChange = valeur;
        system.debug('phone modifié = ' + phoneChange);
        valeur =(leadUpdate.OptInMail__c != leadOld.OptInMail__c) ? true : false;
        Boolean mailChange = valeur;
        system.debug('mail modifié = ' + mailChange);
        valeur =(leadUpdate.OptInSMS__c != leadOld.OptInSMS__c) ? true : false;
        Boolean smsChange = valeur;
        system.debug('sms modifié = ' + smsChange);
        CIN_WS002_APIConsent.UpdateConsentInRDV(leadUpdate.Id, emailChange, phoneChange, mailChange, smsChange);
    }
    
    public static String getToken() {
        HttpRequest req = new HttpRequest();
		HTTPResponse res = new HttpResponse();
		res = CIN_WS001_IdpConnection.getTokenCallout();
		if (res.getStatusCode() == 200) {
			Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
			token = (String) results.get('access_token');
		}
		else {
				Map<String,Object> results = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
		}
		return token;
	}
    
	@future (callout=true)    
    public static void UpdateConsentInRDV(String leadId, Boolean emailChange, Boolean phoneChange, Boolean smsChange, Boolean mailChange){
        
        HttpRequest req = new HttpRequest();
		HTTPResponse res = new HttpResponse();
        Http http = new Http();
        Lead leadupdate = [SELECT Id, ActorId__c, OptInEmail__c, OptInEmailCollectionDate__c, OptInPhone__c, OptInPhoneCollectionDate__c, OptInMail__c, OptInMailCollectionDate__c, OptInSMS__c, OptInSMSCollectionDate__c  FROM Lead Where Id=: leadId];
        
        System.debug('leadcustomer in apiCustomer = ' + leadupdate);
        
        if (leadupdate != null) {
            
            token = getToken();
			req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-country', 'FR');
            String timeStamp = String.valueOf(DateTime.now().getTime());
            System.debug('Timestamp: '+ timeStamp);
            req.setHeader('x-contextId', 'IGD_MARKETING_' + timeStamp);
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setHeader('x-scope', 'IGD');
            req.setEndpoint('https://rcidev-gateway.apie-rcibs.com/gateway/rci-marketing-consent/v1');
			req.setMethod('POST');
            
            List<WrapperConsentDetail> listConsentDetail = new List<WrapperConsentDetail>();

            if(emailChange == true){
                
                WrapperConsentDetail consentDetailEmail = new WrapperConsentDetail();
                consentDetailEmail.consentId = 'ConsentIdEmail';
                consentDetailEmail.consentCategory = 'OPTIN';
                consentDetailEmail.consentType = 'MARKETING';
                consentDetailEmail.consentChannel = 'EMAIL';
                consentDetailEmail.consentSource = 'callCenter';
                consentDetailEmail.consentAllowed = String.valueOf(leadupdate.OptInEmail__c);
                consentDetailEmail.consentLastUpdate = String.valueOf(Date.today());
                listConsentDetail.add(consentDetailEmail);
            }
            if(phoneChange == true){
                
                WrapperConsentDetail consentDetailPhone = new WrapperConsentDetail();
                consentDetailPhone.consentId = 'ConsentIdPhone';
                consentDetailPhone.consentCategory = 'OPTIN';
                consentDetailPhone.consentType = 'MARKETING';
                consentDetailPhone.consentChannel = 'PHONE';
                consentDetailPhone.consentSource = 'callCenter';
                consentDetailPhone.consentAllowed = String.valueOf(leadupdate.OptInPhone__c);
                consentDetailPhone.consentLastUpdate = String.valueOf(Date.today());
                listConsentDetail.add(consentDetailPhone);
            }
            if(smsChange == true){
                
                WrapperConsentDetail consentDetailSms = new WrapperConsentDetail();
                consentDetailSms.consentId = 'ConsentSms';
                consentDetailSms.consentCategory = 'OPTIN';
                consentDetailSms.consentType = 'MARKETING';
                consentDetailSms.consentChannel = 'SMS';
                consentDetailSms.consentSource = 'callCenter';
                consentDetailSms.consentAllowed = String.valueOf(leadupdate.OptInSMS__c);
                consentDetailSms.consentLastUpdate = String.valueOf(Date.today());
                listConsentDetail.add(consentDetailSms);
            }
            if(mailChange == true){
                
                WrapperConsentDetail consentDetailmail = new WrapperConsentDetail();
                consentDetailmail.consentId = 'ConsentSms';
                consentDetailmail.consentCategory = 'OPTIN';
                consentDetailmail.consentType = 'MARKETING';
                consentDetailmail.consentChannel = 'MAIL';
                consentDetailmail.consentSource = 'callCenter';
                consentDetailmail.consentAllowed = String.valueOf(leadupdate.OptInMail__c);
                consentDetailmail.consentLastUpdate = String.valueOf(Date.today());
                listConsentDetail.add(consentDetailmail);
            }
                    
            WrapperConsent objWrp = new WrapperConsent(listConsentDetail);
            
        
            objWrp.activityName = 'INSURANCE_AUTO_GROUP';
            objWrp.countryCode = 'FR';
            
            req.setBody(JSON.serialize(objWrp));
            System.debug('Request body: ' + req.getBody());
            
            try {
                res = http.send(req);
                if (res.getStatusCode() == 200) {
                    System.debug('Success!');
                    log.ResponseHeader = res.getStatusCode() + ': ' + res.getStatus();
					log.RequestXML = req.getBody();
                } else {
                    System.debug('HTTP error: ' + res.getStatusCode());
                    log.ResponseHeader = res.getStatusCode() + ': ' + res.getStatus();
                    log.RequestXML = req.getBody();
                    log.Successful = false;
                }
                System.debug(res.getBody());
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                log.Successful = false;
				log.Message = 'Error : ' + e.getMessage() + ' a la ligne : ' + e.getLineNumber();
				log.RequestXML = req.getBody();
            }
            log.Input = req.getEndpoint();
			log.Output = res.getBody();
			CalloutUtility.CreateCalloutLog_SF_API('getCustomerDetails CIN consent', log);
            CalloutUtility.FlushLogs();
        }
        
    }
}