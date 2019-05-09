public with sharing class GengoTranslateController {
    /*
     * Service that contains API calls to third party service
     */
    private static GengoService service = new GengoService();

    /**
	 * Retrieves the fields for an object
     * @param objectName the name of the object where the field resides
	 * @return String 
	 */
    @AuraEnabled(cacheable=true)
    public static String getFieldsForObject(String objectName) {

        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        List<Field> fields = new List<Field>();

        if (globalDescribe.containsKey(objectName)) {
            Map<String, Schema.SObjectField> objectFields = globalDescribe.get(objectName).getDescribe().fields.getMap();

            for (String fieldName: objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fieldName).getDescribe();
                Schema.DisplayType fieldDataType = fieldDescribe.getType();

                if (fieldDescribe.isAccessible() && fieldDataType != Schema.DisplayType.Boolean &&
                    fieldDataType != Schema.DisplayType.Reference && fieldDataType != Schema.DisplayType.Integer &&
                    fieldDataType != Schema.DisplayType.Long && fieldDataType != Schema.DisplayType.Percent) {
                    fields.add(new Field(
                        fieldDescribe.getLabel(),
                        fieldDescribe.getName()
                    ));
                }
            }
        }

        fields.sort();

        return JSON.serialize(fields);
    } 

    /**
	 * Retrieves the field to translate
	 * @param recordId the id of the record where the field resides
     * @param objectName the name of the object where the field resides
     * @param fieldName the name of the field
	 * @return String 
	 */
    @AuraEnabled(cacheable=true)
    public static String getFieldContentToTranslate(String recordId, String objectName, String fieldName) {
        return retrieveFieldContentToTranslate(recordId, objectName, fieldName);
    }

    /**
	 * Submits content for translation
	 * @param payload the json payload to submit
	 * @return String 
	 */
    @AuraEnabled
    public static SubmissionResult submitTranslation(String payload) {
        Payload data = (Payload)JSON.deserialize(payload, Payload.class);

        String result = service.submitTranslation(data.relatedRecordId, data.objectName, data.fieldName, convertJobsPayload(data.jobs));
        
        GengoTranslationSubmitResponse translationSubmitResponse = (GengoTranslationSubmitResponse)JSON.deserialize(result, GengoTranslationSubmitResponse.class);

        SubmissionResult submissionResult = new SubmissionResult();
        submissionResult.status = translationSubmitResponse.opstat;

        if (!String.isBlank(translationSubmitResponse.opstat) && translationSubmitResponse.opstat == GengoConstants.OK_STATUS) {
            submissionResult.translations = createTranslations(data.relatedRecordId, data.objectName, data.jobs, String.valueOf(translationSubmitResponse.response.order_id));
        } 

        return submissionResult;
    }

    /**
	 * Retrieves the status of a translation
	 * @param jobId the id of the translation to retrieve
	 * @return String 
	 */
    @AuraEnabled(cacheable=true)
    public static String getTranslationStatus(String jobId) {
        return service.getTranslationStatus(jobId);
    }

    /**
	 * Retrieves the account balance
	 * @return String 
	 */
    @AuraEnabled(cacheable=true)
    public static String getAccountBalance() {
        return service.getAccountBalance();
    }

    /**
	 * Retrieves available language pairs for translation
	 * @return String 
	 */
    @AuraEnabled(cacheable=true)
    public static String getLanguagePairs() {
        return service.getLanguagePairs();
    }

    /**
	 * Retrieves available languages
	 * @return String 
	 */
    @AuraEnabled(cacheable=true)
    public static String getLanguages() {
        return service.getLanguages();
    }

    private static String convertJobsPayload(List<Job> jobs) {
        Map<String, Map<String, Object>> jobsPayload = new Map<String, Map<String, Object>>{
            GengoConstants.JOBS_FIELD => new Map<String, Object>()
        };

        for (Integer i = 0; i < jobs.size(); i++) {
            Job job = jobs.get(i);

            Map<String, Object> jobBody = new Map<String, Object>();

            jobBody.put(GengoConstants.JOB_TYPE, job.type);
            jobBody.put(GengoConstants.JOB_SLUG, job.slug);
            jobBody.put(GengoConstants.JOB_SOURCE_CONTENT, job.sourceContent);
            jobBody.put(GengoConstants.JOB_SOURCE_LANGUAGE, job.sourceLanguage);
            jobBody.put(GengoConstants.JOB_TARGET_LANGUAGE, job.targetLanguage);
            jobBody.put(GengoConstants.JOB_TIER, job.tier);
            jobBody.put(GengoConstants.JOB_AUTO_APPROVE, job.autoApprove);
            jobBody.put(GengoConstants.JOB_CUSTOM_DATA, job.customData);

            Map<String, Object> jobsBody = jobsPayload.get(GengoConstants.JOBS_FIELD);

            jobsBody.put(GengoConstants.JOB_PREFIX + i, jobBody);

            jobsPayload.put(GengoConstants.JOBS_FIELD, jobsBody);
        }

        return JSON.serialize(jobsPayload);
    }

    private static String retrieveJobsForOrder(String translationOrder) {
        GengoTranslationOrderResponse translationOrderResponse = (GengoTranslationOrderResponse)JSON.deserialize(translationOrder, GengoTranslationOrderResponse.class);

        List<Integer> jobIds = new List<Integer>();

        if (!String.isBlank(translationOrderResponse.opstat) && translationOrderResponse.opstat == GengoConstants.OK_STATUS) {
            OrderRetrieveResponse orderRetriveResponse = translationOrderResponse.response;
            OrderResponse orderResponse = orderRetriveResponse.order;
        
            jobIds = getJobIdsForOrder(orderResponse);
        }

        return service.getJobs(jobIds);
    }

    private static List<Translation> createTranslations(String relatedRecordId, String objectName, List<Job> jobs, String orderId) {
        List<Translation__c> translations = new List<Translation__c>();
           
        for (Job job: jobs) {
            translations.add(new Translation__c(
                Order_Id__c = orderId,
                Slug__c = job.slug,
                Source_Content__c = job.sourceContent,
                Source_Language__c = job.sourceLanguage,
                Target_Language__c = job.targetLanguage,
                Status__c = GengoConstants.STATUS_AVAILABLE,
                Object_Name__c = objectName,
                Record_Id__c = relatedRecordId
            ));
        }
                        
        if (!translations.isEmpty()) {
            insert translations;
        }

        List<Translation> trans = new List<Translation>();

        for (Translation__c translation: translations) {
            trans.add(new Translation(
                translation.Id,
                translation.Slug__c,
                translation.Status__c
            ));
        }
        
        return trans;
    }

    private static List<Integer> getJobIdsForOrder(OrderResponse orderResponse) {
        List<Integer> jobIds = new List<Integer>();

        if (orderResponse.jobs_reviewable != null && !orderResponse.jobs_reviewable.isEmpty()) {
            jobIds.addAll(orderResponse.jobs_reviewable);
        }

        if (orderResponse.jobs_available != null && !orderResponse.jobs_available.isEmpty()) {
            jobIds.addAll(orderResponse.jobs_available);
        }

        if (orderResponse.jobs_pending != null && !orderResponse.jobs_pending.isEmpty()) {
            jobIds.addAll(orderResponse.jobs_pending);
        }

        if (orderResponse.jobs_approved != null && !orderResponse.jobs_approved.isEmpty()) {
            jobIds.addAll(orderResponse.jobs_approved);
        }

        if (orderResponse.jobs_revising != null && !orderResponse.jobs_revising.isEmpty()) {
            jobIds.addAll(orderResponse.jobs_revising);
        }

        if (orderResponse.jobs_cancelled != null && !orderResponse.jobs_cancelled.isEmpty()) {
            jobIds.addAll(orderResponse.jobs_cancelled);
        }

        if (orderResponse.jobs_held != null && !orderResponse.jobs_held.isEmpty()) {
            jobIds.addAll(orderResponse.jobs_held);
        }

        return jobIds;
    }

    private static String retrieveFieldContentToTranslate(String recordId, String objectName, String fieldName) {
        String soql = 'SELECT ' + String.escapeSingleQuotes(fieldName) + 
                      ' FROM ' + String.escapeSingleQuotes(objectName) + 
                      ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'';

        SObject so = Database.query(soql);

        return (String) so.get(fieldName);
    }

    public class Job {
        public String type { get; set; }
        public String slug { get; set; }
        public String sourceContent { get; set; }
        public String sourceLanguage { get; set; }
        public String targetLanguage { get; set; }
        public String tier { get; set; }
        public Integer autoApprove { get; set; }
        public String customData { get; set; }
    }

    public class Payload {
        public String relatedRecordId { get; set; }
        public String objectName { get; set; }
        public String fieldName { get; set; }
        public List<Job> jobs { get; set; }
    }

    public class Field implements Comparable {
        @AuraEnabled 
        public String label { get; set; }

        @AuraEnabled 
        public String name { get; set; }

        public Field(String label, String name) {
            this.label = label;
            this.name = name;
        }

        public Integer compareTo(Object compareTo) {
            Field compareToFld = (Field)compareTo;
            if (label == compareToFld.label) return 0;
            if (label > compareToFld.label) return 1;
            return -1;
	    }
    }

    public class Translation {
        @AuraEnabled 
        public String id { get; set; }

        @AuraEnabled
        public String slug { get; set; }

        @AuraEnabled
        public String status { get; set; }

        public Translation(String id, String slug, String status) {
            this.id = id;
            this.slug = slug;
            this.status = status;
        }
    }

    public class SubmissionResult {
        @AuraEnabled 
        public String status { get; set; }

        @AuraEnabled
        public List<Translation> translations { get; set; }
    }

    public class TranslationSubmitResponse {
        public Integer job_count { get; set; }
        public Integer order_id { get; set; }
        public Decimal credits_used { get; set; }
    }

    public class OrderResponse {
        public Integer jobs_queued { get; set; }
        public List<Integer> jobs_reviewable { get; set; }
        public List<Integer> jobs_available { get; set; }
        public List<Integer> jobs_pending { get; set; }
        public List<Integer> jobs_approved { get; set; }
        public List<Integer> jobs_revising { get; set; }
        public List<Integer> jobs_cancelled { get; set; }
        public List<Integer> jobs_held { get; set; }
        public String order_id { get; set; }
        public String total_credits { get; set; }
        public Integer total_units { get; set; }
        public String total_jobs { get; set; }
    }

    public class OrderRetrieveResponse {
        public OrderResponse order { get; set; }
    }

    public class JobsReponse {
        public String custom_data { get; set; }
        public String job_id { get; set; }
        public String credits { get; set; }
        public Integer auto_approve { get; set; }
        public String order_id { get; set; }
        public String lc_tgt { get; set; }
        public String lc_src { get; set; }
        public String slug { get; set; }
        public String tier { get; set; }
        public String body_src { get; set; }
        public String status { get; set; }
    }

    public class JobsRetrieveResponse {
        public List<JobsReponse> jobs { get; set; }
    }

    public virtual class GengoResponse {
        public String opstat { get; set; }
    }

    public class GengoTranslationSubmitResponse extends GengoResponse {
        public TranslationSubmitResponse response { get; set; }
    }

    public class GengoTranslationOrderResponse extends GengoResponse {
        public OrderRetrieveResponse response { get; set; }
    }

    public class GengoTranslationJobsResponse extends GengoResponse {
        public JobsRetrieveResponse response { get; set; }
    }
}
