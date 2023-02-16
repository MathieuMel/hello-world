public class CIN_WS001_IdpConnection {
	public static HTTPResponse getTokenCallout() {
		HttpRequest req = new HttpRequest();
		HTTPResponse response = new HttpResponse();
		CalloutUtility.CalloutResult log = new CalloutUtility.CalloutResult();
		List<ES_CCA_Idp__mdt> IDP = [SELECT Endpoint__c, ClientId__c, ClientSecret__c, Username__c, Password__c FROM ES_CCA_Idp__mdt];
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setEndpoint(IDP.get(0).Endpoint__c);

		String CLIENT_ID = IDP.get(0).ClientId__c;
		String CLIENT_SECRET = IDP.get(0).ClientSecret__c;
		String USERNAME = IDP.get(0).Username__c;
		String PASSWORD = IDP.get(0).Password__c;

		req.setBody('grant_type=password' + '&client_id=' + CLIENT_ID +
		            '&client_secret=' + CLIENT_SECRET + '&username=' + USERNAME + '&password=' + PASSWORD);
		req.setTimeout(60000);

		System.debug('Request body: ' + req.getBody());
		Http http = new Http();
		try {
			response = http.send(req);
			System.debug('Response Body: ' + response.getBody());
			System.debug('Response Status code: ' + response.getStatusCode());
			System.debug('Response Status: ' + response.getStatus());
			log.ResponseHeader = response.getStatusCode() + ': ' + response.getStatus();
			log.RequestXML = req.getBody();
			log.Message = response.getStatusCode() != 200 ? response.getBody() : '';
		}
		catch (Exception e) {
			System.debug('Error in callout: ' + e.getMessage());
			System.debug('Error trace: ' + e.getStackTraceString());
			log.Successful = false;
			log.Message = e.getMessage();
			log.RequestXML = req.getBody();
		}
		log.Input = req.getEndpoint();
		log.Output = response.getBody();
		CalloutUtility.CreateCalloutLog_SF_API('getTokenCallout', log);

		return response;
	}
}