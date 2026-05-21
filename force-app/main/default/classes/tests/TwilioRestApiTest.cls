@IsTest
private class TwilioRestApiTest {
    
    static RestRequest generatePostRequestWithStandardParams() {

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/twilio/sms';
        req.httpMethod = 'POST';

        req.addParameter('MessageSid', 'SID12345');
        req.addParameter('AccountSid', 'ACSID12345');
        req.addParameter('MessagingServiceSid', 'MGSID12345');
        req.addParameter('From', '+18008008000');
        req.addParameter('To', '+18888888888');
        req.addParameter('Body', 'Test message');
        req.addParameter('NumSegments', '1');

        return req;
    }

    static void processAndAssertTest(RestRequest req) {

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        String response = TwilioRestApi.handleIncomingSMS();
        Test.stopTest();
        
        Assert.isNotNull(response, 'Response should not be null');
        Assert.areEqual('<?xml version="1.0" encoding="UTF-8"?><Response></Response>', response, 'The response is not as expected');
    }

    @IsTest
    static void testHandleIncomingSMSStandard() {

        RestRequest req = generatePostRequestWithStandardParams();
        req.addParameter('NumMedia', '0');

        processAndAssertTest(req);
    }
    
    @IsTest
    static void testHandleIncomingSMSWithMedia() {

        RestRequest req = generatePostRequestWithStandardParams();
        req.addParameter('NumMedia', '2');
        req.addParameter('MediaContentType0', 'image/png');
        req.addParameter('MediaUrl0', 'https://api.twilio.com/2010-04-01/Accounts/ACSID12345/Messages/MMSID12345/Media/ME12345');
        req.addParameter('MediaContentType1', 'image2/png');
        req.addParameter('MediaUrl1', 'https://api.twilio.com/2010-04-01/Accounts/ACSID54321/Messages/MMSID54321/Media/ME54321');
    
        processAndAssertTest(req);
    }
    
    @IsTest
    static void testHandleIncomingSMSWithLocation() {

        RestRequest req = generatePostRequestWithStandardParams();
        req.addParameter('FromCity', 'Austin');
        req.addParameter('FromState', 'TX');
        req.addParameter('FromZip', '78758');
        req.addParameter('FromCountry', 'US');
        req.addParameter('ToCity', 'Austin');
        req.addParameter('ToState', 'TX');
        req.addParameter('ToZip', '78758');
        req.addParameter('ToCountry', 'US');
    
        processAndAssertTest(req);
    }
    
    @IsTest
    static void testHandleIncomingSMSWithWhatsApp() {

        RestRequest req = generatePostRequestWithStandardParams();
        req.addParameter('ProfileName', 'Test Name');
        req.addParameter('WaId', '+18008008000');
        req.addParameter('Forwarded', 'false');
        req.addParameter('FrequentlyForwarded', 'false');
        req.addParameter('ButtonText', 'Test');
        req.addParameter('Latitude', '51.51322977399644');
        req.addParameter('Longitude', '-0.2197976373036567');
        req.addParameter('Address', '100 Test Rd, Austin, TX, 78758');
        req.addParameter('Label', 'Test Location');
    
        processAndAssertTest(req);        
    }

    /*
        I found the part of the instructions asking for integraton with assignment 5 confusing.
        The instructions did not suggest we should modify the existing code, but the existing code will only be a success for Jira
        Therefore, I just validated that the webhook for Twilio could enter into the framework and return an error in the wrapper
    */
    @isTest
    static void assignment5Test() {

        Map<String, String> parameters = new Map<String, String>();
        parameters.put('MessageSid', 'SID12345');
        parameters.put('AccountSid', 'ACSID12345');
        parameters.put('MessagingServiceSid', 'MGSID12345');
        parameters.put('From', '+18008008000');
        parameters.put('To', '+18888888888');
        parameters.put('Body', 'Test message');
        parameters.put('NumSegments', '1');
        
        RestRequest req = new RestRequest();
        req.requestURI = '/webhook/jira';
        req.httpMethod = 'POST';
        req.params.putAll(parameters);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        WebhookResource.ResponseWrapper response = WebhookResource.doPost();
        Test.stopTest();

        Assert.areEqual('error', response.status, 'Webhook should enter the framework, but have an error since it is only enabled for Jira');
    }
} 