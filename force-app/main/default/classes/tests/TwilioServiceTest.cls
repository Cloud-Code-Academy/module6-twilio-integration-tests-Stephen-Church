@IsTest
private class TwilioServiceTest {

    public static final String PHONE_NUMBER = '+15551234567';
    public static final String MESSAGE = 'Hello';
    
    //***** TESTS *****/

    @IsTest
    static void testSendSMS() {
        
        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock(201,'{"sid":"SM123","status":"queued"}'));
        
        Test.startTest();
        TwilioResponse response = TwilioService.sendSMS(PHONE_NUMBER, MESSAGE);
        Test.stopTest();
        
        Map<String, Object> responseBody = response.getBodyAsJson();
        Assert.isTrue(response.success, 'The response was not a success');
        Assert.areEqual(201, response.statusCode, 'The response status code was not 201');
        Assert.areEqual('SM123', responseBody.get('sid'), 'The SID in the response is not as expected');
        Assert.areEqual('queued', responseBody.get('status'), 'The Status in the response is not as expected');
    }

    @IsTest
    static void testSendSMSError_message() {
        
        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock(400,'{"message":"Invalid number"}'));
        testSendSMSError('message');
    }

    @IsTest
    static void testSendSMSError_error_message() {
        
        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock(400,'{"error_message":"Invalid number"}'));
        testSendSMSError('error_message');
    }

    @IsTest
    static void testSendSMSError_error() {
        
        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock(400,'{"error":"Invalid number"}'));
        testSendSMSError('error');
    }

    @IsTest
    static void testGetMessages_validLimit() {

        testGetMessages(20);
    }

    @IsTest
    static void testGetMessages_nullLimit() {
        
        testGetMessages(null);
    }

    @IsTest
    static void testGetMessages_negativeLimit() {
        
        testGetMessages(-20);
    }

    @IsTest
    static void testMakeHttpRequestException() {
        
        Test.setMock(HttpCalloutMock.class, TwilioCalloutMock.createExceptionMock());

        Test.startTest();
        TwilioResponse response = TwilioService.sendSMS(PHONE_NUMBER, MESSAGE);
        Test.stopTest();

        Assert.isFalse(response.success, 'The response should be a failure');
        Assert.areEqual(500, response.statusCode, 'The status code should be 500');
        Assert.isTrue(response.getErrorMessage().contains('Twilio callout failed'), 'The error message is not as expected');
    }

    @isTest
    static void getBodyAsJson_null() {

        TwilioResponse response = new TwilioResponse();

        Test.startTest();
        Map<String, Object> responseMap = response.getBodyAsJson();
        Test.stopTest();

        Assert.isNull(responseMap, 'The responseMap should be null');
    }

    @isTest
    static void getBodyAsJson_invalidJson() {

        TwilioResponse response = new TwilioResponse();
        response.body = '{"message": "Invalid JSON",}';

        Test.startTest();
        Map<String, Object> responseMap = response.getBodyAsJson();
        Test.stopTest();

        Assert.isNull(responseMap, 'The responseMap should be null');
    }

    @isTest
    static void getErrorMessages_success() {

        TwilioResponse response = new TwilioResponse();
        response.success = true;

        Test.startTest();
        String responseString = response.getErrorMessage();
        Test.stopTest();

        Assert.isNull(responseString, 'The response should be null');
    }

    //***** HELPERS *****/

    static void testSendSMSError(String keyToExtract) {

        Test.startTest();
        TwilioResponse response = TwilioService.sendSMS(PHONE_NUMBER, MESSAGE);
        Test.stopTest();

        Map<String, Object> responseBody = response.getBodyAsJson();
        Assert.isFalse(response.success, 'The response was a success');
        Assert.areEqual(400, response.statusCode, 'The response status code was not 400');
        Assert.areEqual('Invalid number', responseBody.get(keyToExtract), 'The message is not as expected');
        Assert.areEqual('Invalid number', response.getErrorMessage(), 'The message extracted is not as expected');
    }

    static void testGetMessages(Integer pageSizeNumber) {

        String pageSizeString = String.valueOf(pageSizeNumber);

        String mockBody =
        '{' +
        '  "page": 0,' +
        '  "page_size": ' + pageSizeString + ',' +
        '  "messages": [' +
        '    {' +
        '      "sid": "sid0",' +
        '      "body": "body0",' +
        '      "status": "sent",' +
        '      "from": "+18008008000",' +
        '      "to": "+18888888880"' +
        '    },' +
        '    {' +
        '      "sid": "sid1",' +
        '      "body": "body1",' +
        '      "status": "sent",' +
        '      "from": "+18008008001",' +
        '      "to": "+18888888881"' +
        '    }' +
        '  ]' +
        '}';        

        Test.setMock(HttpCalloutMock.class, new TwilioCalloutMock(200, mockBody));

        Test.startTest();
        TwilioResponse response = TwilioService.getMessages(pageSizeNumber);
        Test.stopTest();

        Map<String, Object> responseBody = response.getBodyAsJson();
        List<Object> messages = (List<Object>)responseBody.get('messages');

        Assert.isTrue(response.success, 'The response was a success');
        Assert.areEqual(200, response.statusCode, 'The response status code was not 200');
        for (Integer i = 0; i < messages.size(); i++) {
            Map<String, Object> msg = (Map<String, Object>)messages.get(i);
            Assert.areEqual('sid' + i, msg.get('sid'), 'The sid is not as expected');
            Assert.areEqual('body' + i, msg.get('body'), 'The body is not as expected');
            Assert.areEqual('sent', msg.get('status'), 'The status is not as expected');
            Assert.areEqual('+1800800800' + i, msg.get('from'), 'The from is not as expected');
            Assert.areEqual('+1888888888' + i, msg.get('to'), 'The to is not as expected');
        }
    }

} 