@isTest
private class GengoCallbackHandlerTest {
    
    private static final String ORDER_ID = '123';

    @TestSetup
    static void setup(){
        List<Translation__c> translations = new List<Translation__c>();

        translations.add(new Translation__c(
            Status__c = 'pending',
            Order_Id__c = ORDER_ID
        ));

        insert translations;
    }

    static List<Translation__c> getTranslationByOrderId(String orderId) {
        return [
            SELECT 
                Id,
                Order_Id__c,
                Status__c
            FROM 
                Translation__c
            WHERE 
                Order_Id__c = :orderId
        ];
    }

    @isTest 
    static void testDoOrderPost() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/order';
        req.addParameter('job', '{"order_id":"123","status":"approved","body_tgt":"translated content"}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        GengoCallbackHandler.doOrderPost();
        Test.stopTest();

        String responseBody = res.responseBody.toString();

        System.assertEquals('success', responseBody);

        List<Translation__c> updatedTranslations = getTranslationByOrderId(ORDER_ID);

        System.assertEquals(ORDER_ID, updatedTranslations.get(0).Order_Id__c);
        System.assertEquals('approved', updatedTranslations.get(0).Status__c);
    }
}
