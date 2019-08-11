public with sharing class TranslationController {
    
    /**
	 * Retrieves translations for a record
	 * @param recordId the id of the record for which to retrieve translations
     * @param filters the filters for the query
     * @param pageSize the size of the paged result
     * @param pageNumber the number of the page
	 * @return PagedResult 
	 */
    @AuraEnabled(cacheable=true)
    public static PagedResult retrieveTranslations(String recordId, String filters, Decimal pageSize, Decimal pageNumber) {
        Filter filter = (Filter)JSON.deserializeStrict(filters, Filter.class);
        Integer pSize = (Integer)pageSize;
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        
        PagedResult result =  new PagedResult();
        result.pageSize = pSize;
        result.page = (Integer)pageNumber;

        Integer count = getNumberOfRecords(recordId, filter.status, filter.sourceLanguage, filter.targetLanguage);
        List<Translation__c> translations = retrieveTranslationsForRecord(recordId, filter.status, filter.sourceLanguage, filter.targetLanguage, pSize, offset);

        result.total = count;
        result.pages = (Math.ceil(result.total / result.pageSize)).intValue();

        if (result.pages == 0) {
            result.pages = 1;
        }

        List<TranslationListItem> translationListItems = new List<TranslationListItem>();

        for (Translation__c translation: translations) {
            translationListItems.add(new TranslationListItem(
                translation.Id,
                translation.Status__c,
                translation.Slug__c,
                translation.Source_Language__c,
                translation.Target_Language__c
            ));
        }

        result.translationListItems = translationListItems;
        return result;
    }

    /**
	 * Retrieves a translation record
	 * @param recordId the id of the translation record
	 * @return String 
	 */
    @AuraEnabled(cacheable=true)
    public static String retrieveTranslation(String recordId) {
        Translation__c translation = retrieveTranslationRecord(recordId);

        TranslationDetailItem translationDetailItem = new TranslationDetailItem(
            translation.Id,
            translation.Object_Name__c,
            translation.Field_Name__c,
            translation.Status__c,
            translation.Slug__c,
            translation.Job_Id__c,
            translation.Order_Id__c,
            translation.Source_Content__c,
            translation.Source_Language__c,
            translation.Target_Language__c,
            translation.Translated_Content__c,
            translation.Acknowledged__c
        );

        return JSON.serialize(translationDetailItem);
    }

    private static Integer getNumberOfRecords(String recordId, String status, String sourceLanguage, String targetLanguage) {
        String soql = 'SELECT COUNT() FROM Translation__c';

        List<String> conditionals = new List<String>();

        if (String.isNotBlank(recordId)) {
            conditionals.add('Record_Id__c = :recordId');
        }

        if (String.isNotBlank(status)) {
            conditionals.add('Status__c = :status');
        }

        if (String.isNotBlank(sourceLanguage)) {
            conditionals.add('(Source_Language_Code__c = :sourceLanguage OR Source_Language__c = :sourceLanguage)');
        }

        if (String.isNotBlank(targetLanguage)) {
            conditionals.add('(Target_Language_Code__c = :targetLanguage OR Target_Language__c = :targetLanguage)');
        }

        if (!conditionals.isEmpty()) {
            soql += ' WHERE ' + String.join(conditionals, ' AND ');
        }

        return Database.countQuery(soql);
    }

    private static List<Translation__c> retrieveTranslationsForRecord(String recordId, String status, String sourceLanguage, String targetLanguage, Integer pageSize, Integer offset) {
        String soql = 'SELECT Id, Status__c, Slug__c, Source_Language__c, Target_Language__c FROM Translation__c';

        List<String> conditionals = new List<String>();

        if (String.isNotBlank(recordId)) {
            conditionals.add('Record_Id__c = :recordId');
        }

        if (String.isNotBlank(status)) {
            conditionals.add('Status__c = :status');
        }

        if (String.isNotBlank(sourceLanguage)) {
            conditionals.add('Source_Language__c = :sourceLanguage');
        }

        if (String.isNotBlank(targetLanguage)) {
            conditionals.add('Target_Language__c = :targetLanguage');
        }

        if (!conditionals.isEmpty()) {
            soql += ' WHERE ' + String.join(conditionals, ' AND ');
        }

        soql += ' LIMIT :pageSize OFFSET :offset';

        return Database.query(soql);
    }

    private static Translation__c retrieveTranslationRecord(String recordId) {
        return [
            SELECT 
                Id,
                Object_Name__c,
                Field_Name__c,
                Status__c,
                Slug__c,
                Job_Id__c,
                Order_Id__c, 
                Source_Content__c,
                Source_Language__c,
                Target_Language__c,
                Translated_Content__c,
                Acknowledged__c
            FROM 
                Translation__c
            WHERE 
                Id = :recordId
            LIMIT 1
        ];
    }

    public class PagedResult {
        @AuraEnabled
        public Integer pageSize { get;set; }

        @AuraEnabled
        public Integer page { get;set; }

        @AuraEnabled
        public Integer pages { get;set; }

        @AuraEnabled
        public Integer total { get;set; }

        @AuraEnabled
        public List<TranslationListItem> translationListItems { get;set; }
    }

    public class Filter {
        @AuraEnabled
        public String status { get;set; }

        @AuraEnabled
        public String sourceLanguage { get; set; }

        @AuraEnabled
        public String targetLanguage { get; set; }
    }

    private class TranslationListItem {
        @AuraEnabled
        public String id { get; set; }

        @AuraEnabled
        public String status { get; set; }

        @AuraEnabled
        public String slug { get; set; }

        @AuraEnabled
        public String sourceLanguage { get; set; }

        @AuraEnabled 
        public String targetLanguage { get; set; }

        public TranslationListItem(String id, String status, String slug, String sourceLanguage, String targetLanguage) {
            this.id = id;
            this.status = status;
            this.slug = slug;
            this.sourceLanguage = sourceLanguage;
            this.targetLanguage = targetLanguage;
        }
    }

    private class TranslationDetailItem {
        @AuraEnabled
        public String id { get; set; }

        @AuraEnabled
        public String objectName { get; set; }

        @AuraEnabled
        public String fieldName { get; set; }

        @AuraEnabled
        public String status { get; set; }

        @AuraEnabled
        public String slug { get; set; }

        @AuraEnabled
        public String jobId { get; set; }

        @AuraEnabled
        public String orderId { get; set; }

        @AuraEnabled
        public String sourceContent { get; set; }

        @AuraEnabled
        public String sourceLanguage { get; set; }

        @AuraEnabled
        public String targetLanguage { get; set; }

        @AuraEnabled
        public String translatedContent { get; set; }

        @AuraEnabled
        public Boolean acknowledged { get; set; }

        public TranslationDetailItem(String id, String objectName, String fieldName, String status, String slug,
                                     String jobId, String orderId, String sourceContent, String sourceLanguage,
                                     String targetLanguage, String translatedContent, Boolean acknowledged) {
            this.id = id;
            this.objectName = objectName;
            this.fieldName = fieldName;
            this.status = status;
            this.slug = slug;
            this.jobId = jobId;
            this.orderId = orderId;
            this.sourceContent = sourceContent;
            this.sourceLanguage = sourceLanguage;
            this.targetLanguage = targetLanguage;
            this.translatedContent = translatedContent;
            this.acknowledged = acknowledged;
        }
    }
}
