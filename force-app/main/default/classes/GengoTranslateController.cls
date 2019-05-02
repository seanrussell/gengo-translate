public with sharing class GengoTranslateController {
    
    @AuraEnabled(cacheable=true)
    public static String submitTranslation(String payload) {

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static String getTranslationStatus(String jobId) {

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static String getAccountBalance() {

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static String getLanguagePairs() {

        return null;
    }

    public class Payload {
        String content { get; set; }
        String sourceLanguage { get; set; }
        String targetLanguage { get; set; }
        String selectedTier { get; set; }
        String type { get; set; }
        String slug { get; set; }
    }
}
