@isTest
private class GengoTranslateControllerTest {
    
    @TestSetup
    static void setup(){
        Case c = new Case(
            Subject = 'Test case subject',
            Description = 'Test case description'
        );

        insert c; 
    }

    static List<Case> getCases() {
        return [
            SELECT 
                Id,
                Description
            FROM
                Case
        ];
    }

    static List<Translation__c> getTranslations() {
        return [
            SELECT 
                Id 
            FROM 
                Translation__c
        ];
    }

    @isTest 
    static void testGetFieldsForObject() {

        Test.startTest();
        String result = GengoTranslateController.getFieldsForObject('Case');
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest 
    static void testGetFieldContentToTranslate() {
        List<Case> cases = getCases();
        Case c = cases.get(0);

        Test.startTest();
        String result = GengoTranslateController.getFieldContentToTranslate(String.valueOf(c.Id), 'Case', 'Description');
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest 
    static void testSubmitTranslation() {
        List<Case> cases = getCases();
        Case c = cases.get(0);

        List<GengoTranslateController.Job> jobs = new List<GengoTranslateController.Job>();

        GengoTranslateController.Job job = new GengoTranslateController.Job();
        job.type = 'text';
        job.slug = 'English :: French';
        job.sourceContent = c.Description;
        job.sourceLanguage = 'English';
        job.sourceLanguageCode = 'en';
        job.targetLanguage = 'French';
        job.targetLanguageCode = 'fr';
        job.tier = 'pro';
        job.autoApprove = 1;
        job.customData = '';
        job.callbackUrl = 'http://localhost/callback';

        jobs.add(job);

        GengoTranslateController.Payload translation = new GengoTranslateController.Payload();
        translation.relatedRecordId = c.Id;
        translation.objectName = 'Case';
        translation.fieldName = 'Description';
        translation.jobs = jobs;

        String payload = JSON.serialize(translation);

        GengoTranslateController.service = new GengoServiceMock();

        Test.startTest();
        GengoTranslateController.SubmissionResult result = GengoTranslateController.submitTranslation(payload);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('ok', result.status);

        List<Translation__c> translations = getTranslations();

        System.assert(!translations.isEmpty());
    }
    
    @isTest 
    static void testGetTranslationStatus() {
        List<Case> cases = getCases();
        Case c = cases.get(0);

        GengoTranslateController.service = new GengoServiceMock();

        Test.startTest();
        String result = GengoTranslateController.getTranslationStatus(String.valueOf(c.Id));
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest 
    static void testGetLanguagePairs() {
       GengoTranslateController.service = new GengoServiceMock();

        Test.startTest();
        String result = GengoTranslateController.getLanguagePairs();
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest 
    static void testGetLanguages() {
        GengoTranslateController.service = new GengoServiceMock();

        Test.startTest();
        String result = GengoTranslateController.getLanguages();
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest 
    static void testUpdateTranslation() {
        List<Case> cases = getCases();
        Case c = cases.get(0);

        Translation__c translation = new Translation__c(
            Record_Id__c = c.Id,
            Status__c = 'available',
            Slug__c = 'Translation :: English to French',
            Source_Language__c = 'English',
            Source_Language_Code__c = 'en',
            Target_Language__c = 'French',
            Target_Language_Code__c = 'fr',
            Object_Name__c = 'Case',
            Field_Name__c = 'Description',
            Source_Content__c = 'Test case description',
            Job_Id__c = '6789'
        );

        insert translation;

        GengoTranslateController.service = new GengoServiceMock();

        Test.startTest();
        String result = GengoTranslateController.updateTranslation(translation.Job_Id__c, 'approve');
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @isTest 
    static void testGetAccountBalance() {
        List<Case> cases = getCases();
        Case c = cases.get(0);

        GengoTranslateController.service = new GengoServiceMock();

        Test.startTest();
        String result = GengoTranslateController.getAccountBalance();
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    public class GengoServiceMock implements TranslationService {
        public String submitTranslation(String relatedRecordId, String objectName, String fieldName, String jobs) {
            return '{"opstat":"ok","response":{"job_count":1,"order_id":12345,"credits_used":10.45,"currency":"USD"}}';
        }

        public String getTranslationStatus(String jobId) {
            return '{"opstat":"ok","response":{"job":{"job_id":6789,"credits":0.05,"auto_approve":0,"eta":25056,"order_id":12345,"lc_tgt":"ja","unit_count":1,"lc_src":"en","slug":"APIJobtest","callback_url":"http://gengo.callback/","currency":"USD","tier":"standard","body_src":"This is text.","body_tgt":"これはテキストです。","ctime":1313475693,"status":"available"}}}';
        }

        public String getOrder(String orderId) {
            return '{"opstat":"ok"}';
        }

        public String getJobs(List<Integer> jobIds) {
            return '{"opstat":"ok"}';
        }

        public String getAccountBalance() {
            return '{"opstat":"ok","response":{"credits":25.32,"currency":"USD"}}';
        }

        public String getLanguagePairs() {
            return '{"opstat":"ok","response":[{"unit_price":0.05,"lc_tgt":"en","lc_src":"de","tier":"standard","currency":"USD"},{"unit_price":0.1,"lc_tgt":"en","lc_src":"de","tier":"pro","currency":"USD"}]}';
        }

        public String getLanguages() {
            return '{"opstat":"ok","response":[{"unit_type":"word","lc":"en","localized_name":"English","language":"English"},{"unit_type":"character","lc":"ja","localized_name":"日本語","language":"Japanese"},{"unit_type":"word","lc":"es","localized_name":"Español","language":"Spanish (Spain)"}]}';
        }

        public String updateTranslation(String jobId, String action) {
            return '{"opstat":"ok","response":{}}';
        }
    }
}
