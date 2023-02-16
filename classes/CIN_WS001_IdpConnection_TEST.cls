@IsTest
public class CIN_WS001_IdpConnection_TEST {

    @isTest
	private static void testCIN_IdpConnection() {
		Test.setMock(HttpCalloutMock.class, new MCK_WS001_ApiCustomer());
		Test.startTest();
		CIN_WS001_IdpConnection.getTokenCallout();
		Test.stopTest();
	}
}