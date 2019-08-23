@isTest
private class GengoServiceTest {
    
    private static final String RESPONSE_GET_LANGUAGES = '{"opstat":"ok","response":[{"unit_type":"word","lc":"en","localized_name":"English","language":"English"},{"unit_type":"character","lc":"ja","localized_name":"日本語","language":"Japanese"},{"unit_type":"word","lc":"es","localized_name":"Español","language":"Spanish (Spain)"}]}';
    private static final String RESPONSE_GET_LANGUAGE_PAIRS = '{"opstat":"ok","response":[{"unit_price":0.05,"lc_tgt":"en","lc_src":"de","tier":"standard","currency":"USD"},{"unit_price":0.1,"lc_tgt":"en","lc_src":"de","tier":"pro","currency":"USD"}]}';
    private static final String RESPONSE_GET_ACCOUNT_BALANCE = '{"opstat":"ok","response":{"credits":25.32,"currency":"USD"}}';
    private static final String RESPONSE_GET_ORDER = '{"opstat":"ok","response":{"order":{"jobs_queued":0,"jobs_reviewable":[],"jobs_available":["100","200","300"],"jobs_pending":[],"jobs_approved":["400","500"],"jobs_revising":[],"jobs_cancelled":[],"jobs_held":[],"order_id":"232","total_credits":"0.30","total_units":6,"total_jobs":"3","currency":"USD"}}}';
    private static final String RESPONSE_GET_JOBS = '{"opstat":"ok","response":[{"job_id":123,"ctime":""},{"job_id":425,"ctime":""},{"job_id":274,"ctime":""}]}';
    private static final String RESPONSE_GET_TRANSLATION_STATUS = '{"opstat":"ok","response":{"job":{"job_id":384985,"credits":0.05,"auto_approve":0,"eta":25056,"order_id":54632,"lc_tgt":"ja","unit_count":1,"lc_src":"en","slug":"APIJobtest","callback_url":"http://gengo.callback/","currency":"USD","tier":"standard","body_src":"This is text.","body_tgt":"これはテキストです。","ctime":1313475693,"status":"available"}}}';
    private static final String RESPONSE_UPDATE_TRANSLATION = '{"opstat":"ok","response":{}}';
    private static final String RESPONSE_SUBMIT_TRANSLATION = '{"opstat":"ok","response":{"job_count":10,"order_id":139370,"credits_used":100.45,"currency":"USD"}}';

    @isTest 
    static void testGetLanguages() {
        GengoService service = new GengoService();

        Test.setMock(HttpCalloutMock.class, new GetLanguagesMock());

        Test.startTest();
        String response = service.getLanguages();
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assertEquals(RESPONSE_GET_LANGUAGES, response);
    }

    @isTest 
    static void testGetLanguagePairs() {
        GengoService service = new GengoService();

        Test.setMock(HttpCalloutMock.class, new GetLanguagePairsMock());

        Test.startTest();
        String response = service.getLanguagePairs();
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assertEquals(RESPONSE_GET_LANGUAGE_PAIRS, response);
    }

    @isTest 
    static void testGetAccountBalance() {
        GengoService service = new GengoService();

        Test.setMock(HttpCalloutMock.class, new GetAccountBalanceMock());

        Test.startTest();
        String response = service.getAccountBalance();
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assertEquals(RESPONSE_GET_ACCOUNT_BALANCE, response);
    }

    @isTest 
    static void testGetOrder() {
        GengoService service = new GengoService();

        Test.setMock(HttpCalloutMock.class, new GetOrderMock());

        Test.startTest();
        String response = service.getOrder('232');
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assertEquals(RESPONSE_GET_ORDER, response);
    }

    @isTest 
    static void testGetJobs() {
        GengoService service = new GengoService();

        Test.setMock(HttpCalloutMock.class, new GetJobsMock());

        Test.startTest();
        String response = service.getJobs(new List<Integer>{ 100, 200, 300, 400, 500 });
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assertEquals(RESPONSE_GET_JOBS, response);
    }

    @isTest 
    static void testGetTranslationStatus() {
        GengoService service = new GengoService();

        Test.setMock(HttpCalloutMock.class, new GetTranslationStatusMock());

        Test.startTest();
        String response = service.getTranslationStatus('384985');
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assertEquals(RESPONSE_GET_TRANSLATION_STATUS, response);
    }

    @isTest 
    static void testUpdateTranslation() {
        GengoService service = new GengoService();

        Test.setMock(HttpCalloutMock.class, new UpdateTranslationMock());

        Test.startTest();
        String response = service.updateTranslation('384985', 'approve');
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assertEquals(RESPONSE_UPDATE_TRANSLATION, response);
    }

    @isTest 
    static void testSubmitTranslation() {
        GengoService service = new GengoService();

        Test.setMock(HttpCalloutMock.class, new SubmitTranslationMock());

        Test.startTest();
        String response = service.submitTranslation('recordId', 'Case', 'Description', '{"jobs":{}}');
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assertEquals(RESPONSE_SUBMIT_TRANSLATION, response);
    }

    public class GetLanguagesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(RESPONSE_GET_LANGUAGES);
            response.setStatusCode(200);
            return response;
        }
    }

    public class GetLanguagePairsMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(RESPONSE_GET_LANGUAGE_PAIRS);
            response.setStatusCode(200);
            return response;
        }
    }

    public class GetAccountBalanceMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(RESPONSE_GET_ACCOUNT_BALANCE);
            response.setStatusCode(200);
            return response;
        }
    }

    public class GetOrderMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(RESPONSE_GET_ORDER);
            response.setStatusCode(200);
            return response;
        }
    }

    public class GetJobsMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(RESPONSE_GET_JOBS);
            response.setStatusCode(200);
            return response;
        }
    }

    public class GetTranslationStatusMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(RESPONSE_GET_TRANSLATION_STATUS);
            response.setStatusCode(200);
            return response;
        }
    }

    public class UpdateTranslationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(RESPONSE_UPDATE_TRANSLATION);
            response.setStatusCode(200);
            return response;
        }
    }

    public class SubmitTranslationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(RESPONSE_SUBMIT_TRANSLATION);
            response.setStatusCode(200);
            return response;
        }
    }
}
