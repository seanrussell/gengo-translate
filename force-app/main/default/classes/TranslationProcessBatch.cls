global with sharing class TranslationProcessBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private final String query;
    private final Set<String> STATUSES = new Set<String>{
        'queued',
        'available',
        'pending',
        'revising',
        'reviewable'
    };

    private OrderService service;
    
    public TranslationProcessBatch() {
        this.service = new OrderService();
        this.query = 'SELECT Id, Status__c, Order_Id__c, Job_Id__c FROM Translation__c WHERE Status__c IN (:STATUSES)';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bd, List<SObject> records) {
        List<Translation__c> translations = (List<Translation__c>)records;

        Map<String, Map<String, Translation__c>> translationsOrderToJobMap = new Map<String, Map<String, Translation__c>>();

        for (Translation__c translation: translations) {
            if (!translationsOrderToJobMap.containsKey(translation.Order_Id__c)) {
                translationsOrderToJobMap.put(translation.Order_Id__c, new Map<String, Translation__c>());
            } 

            Map<String, Translation__c> jobMap = translationsOrderToJobMap.get(translation.Order_Id__c);
            jobMap.put(translation.Job_Id__c, translation);
            translationsOrderToJobMap.put(translation.Job_Id__c, jobMap);
        }

        List<Translation__c> translationsToUpdate = new List<Translation__c>();

        for (String orderId: translationsOrderToJobMap.keySet()) {
            List<Translation__c> trans = this.service.updateJobs(orderId, translationsOrderToJobMap.get(orderId));

            if (!trans.isEmpty()) {
                translationsToUpdate.addAll(trans);
            }
        }

        if (!translationsToUpdate.isEmpty()) {
            update translations;
        }
    }

    global void finish(Database.BatchableContext bc) {}
}
