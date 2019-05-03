public with sharing class GengoTranslateController {
    private static GengoService service = new GengoService();

    @AuraEnabled(cacheable=true)
    public static String getFieldContentToTranslate(String recordId, String objectName, String fieldName) {
        return retrieveFieldContentToTranslate(recordId, objectName, fieldName);
    }

    @AuraEnabled(cacheable=true)
    public static String submitTranslation(String payload) {
        Payload data = (Payload) JSON.deserialize(payload, Payload.class);
        return service.submitTranslation(data.relatedRecordId, data.objectName, data.fieldName, data.jobs);
    }

    @AuraEnabled(cacheable=true)
    public static String getTranslationStatus(String jobId) {
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static String getAccountBalance() {
        return service.getAccountBalance();
    }

    @AuraEnabled(cacheable=true)
    public static String getLanguagePairs() {
        return service.getLanguagePairs();
    }

    @AuraEnabled(cacheable=true)
    public static String getLanguages() {
        return service.getLanguages();
    }

    private static String retrieveFieldContentToTranslate(String recordId, String objectName, String fieldName) {
        String soql = 'SELECT ' + String.escapeSingleQuotes(fieldName) + 
                      ' FROM ' + String.escapeSingleQuotes(objectName) + 
                      ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'';

        SObject so = Database.query(soql);

        return (String) so.get(fieldName);
    }

    public class Payload {
        @AuraEnabled 
        String relatedRecordId { get; set; }

        @AuraEnabled 
        String objectName { get; set; }

        @AuraEnabled 
        String fieldName { get; set; }

        @AuraEnabled
        String jobs { get; set; }
    }
}
