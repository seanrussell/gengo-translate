@isTest
private class TranslationControllerTest {
    
    @testSetup 
    static void setup() {
        Case sampleCase = new Case(
            Subject = 'Test case subject',
            Description = 'Test case description'

        );

        insert sampleCase;

        List<Translation__c> translations = new List<Translation__c>();

        translations.add(new Translation__c(
            Record_Id__c = sampleCase.Id,
            Status__c = 'available',
            Slug__c = 'Translation :: English to French',
            Source_Language__c = 'English',
            Source_Language_Code__c = 'en',
            Target_Language__c = 'French',
            Target_Language_Code__c = 'fr',
            Object_Name__c = 'Case',
            Field_Name__c = 'Description',
            Source_Content__c = 'Test case description'
        ));

        translations.add(new Translation__c(
            Record_Id__c = sampleCase.Id,
            Status__c = 'available',
            Slug__c = 'Translation :: English to Italian',
            Source_Language__c = 'English',
            Source_Language_Code__c = 'en',
            Target_Language__c = 'Italian',
            Target_Language_Code__c = 'it',
            Object_Name__c = 'Case',
            Field_Name__c = 'Description',
            Source_Content__c = 'Test case description'
        ));

        translations.add(new Translation__c(
            Record_Id__c = sampleCase.Id,
            Status__c = 'available',
            Slug__c = 'Translation :: English to German',
            Source_Language__c = 'English',
            Source_Language_Code__c = 'en',
            Target_Language__c = 'German',
            Target_Language_Code__c = 'de',
            Object_Name__c = 'Case',
            Field_Name__c = 'Description',
            Source_Content__c = 'Test case description'
        ));

        insert translations;
    }

    static List<Case> getCases() {
        return [
            SELECT 
                Id 
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

    static List<Translation__c> getTranslationsByLanguage(String sourceLanguageCode, String targetLanguageCode) {
        return [
            SELECT 
                Id 
            FROM 
                Translation__c
            WHERE 
                Source_Language_Code__c = :sourceLanguageCode
                AND Target_Language_Code__c = :targetLanguageCode
        ];
    }

    static List<Translation__c> getTranslationById(String translationId) {
        return [
            SELECT 
                Id 
            FROM 
                Translation__c
            WHERE 
                Id = :translationId
        ];
    }

    @isTest 
    static void testRetrieveTranslations_All() {
        List<Case> cases = getCases();

        Id caseId = cases.get(0).Id;

        Test.startTest();
        TranslationController.PagedResult result = TranslationController.retrieveTranslations(caseId, '{"status":"","sourceLanguage":"","targetLanguage":""}', 5, 1);
        Test.stopTest();

        List<Translation__c> translations = getTranslations();

        System.assertEquals(translations.size(), result.total);
    }

    @isTest 
    static void testRetrieveTranslations_Available() {
        List<Case> cases = getCases();

        Id caseId = cases.get(0).Id;

        Test.startTest();
        TranslationController.PagedResult result = TranslationController.retrieveTranslations(caseId, '{"status":"available","sourceLanguage":"","targetLanguage":""}', 5, 1);
        Test.stopTest();

        List<Translation__c> translations = getTranslations();

        System.assertEquals(translations.size(), result.total);
    }

    @isTest 
    static void testRetrieveTranslations_Pending() {
        List<Case> cases = getCases();

        Id caseId = cases.get(0).Id;

        Test.startTest();
        TranslationController.PagedResult result = TranslationController.retrieveTranslations(caseId, '{"status":"pending","sourceLanguage":"","targetLanguage":""}', 5, 1);
        Test.stopTest();

        List<Translation__c> translations = getTranslations();

        System.assertNotEquals(translations.size(), result.total);
        System.assertEquals(0, result.total);
    }

    @isTest 
    static void testRetrieveTranslations_EnglishToFrench() {
        List<Case> cases = getCases();

        Id caseId = cases.get(0).Id;

        Test.startTest();
        TranslationController.PagedResult result = TranslationController.retrieveTranslations(caseId, '{"status":"","sourceLanguage":"en","targetLanguage":"fr"}', 5, 1);
        Test.stopTest();

        List<Translation__c> translations = getTranslationsByLanguage('en', 'fr');

        System.assertEquals(translations.size(), result.total);
    }

    @isTest 
    static void testRetrieveTranslations_EnglishToItalian() {
        List<Case> cases = getCases();

        Id caseId = cases.get(0).Id;

        Test.startTest();
        TranslationController.PagedResult result = TranslationController.retrieveTranslations(caseId, '{"status":"","sourceLanguage":"en","targetLanguage":"it"}', 5, 1);
        Test.stopTest();

        List<Translation__c> translations = getTranslationsByLanguage('en', 'it');

        System.assertEquals(translations.size(), result.total);
    }

    @isTest 
    static void testRetrieveTranslations_EnglishToGerman() {
        List<Case> cases = getCases();

        Id caseId = cases.get(0).Id;

        Test.startTest();
        TranslationController.PagedResult result = TranslationController.retrieveTranslations(caseId, '{"status":"","sourceLanguage":"en","targetLanguage":"de"}', 5, 1);
        Test.stopTest();

        List<Translation__c> translations = getTranslationsByLanguage('en', 'de');

        System.assertEquals(translations.size(), result.total);
    }

    @isTest 
    static void testRetrieveTranslations_EnglishToSpanish() {
        List<Case> cases = getCases();

        Id caseId = cases.get(0).Id;

        Test.startTest();
        TranslationController.PagedResult result = TranslationController.retrieveTranslations(caseId, '{"status":"","sourceLanguage":"en","targetLanguage":"es"}', 5, 1);
        Test.stopTest();

        List<Translation__c> translations = getTranslationsByLanguage('en', 'es');

        System.assertEquals(translations.size(), result.total);
        System.assertEquals(0, result.total);
    }

    @isTest 
    static void testRetrieveTranslation() {
        List<Translation__c> translations = getTranslations();

        Id translationId = translations.get(0).Id;

        Test.startTest();
        String translation = TranslationController.retrieveTranslation(translationId);
        Test.stopTest();

        List<Translation__c> trans = getTranslationById(translationId);

        System.assert(!trans.isEmpty());

        Translation__c tran = trans.get(0);

        System.assertEquals(translationId, tran.Id);
    }

    
}
