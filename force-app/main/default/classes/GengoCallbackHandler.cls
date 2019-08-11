@RestResource(urlMapping='/order')
global class GengoCallbackHandler {
    
    @HttpPost
    global static void doOrderPost() {
        String job = RestContext.request.params.get('job');

        if (job != null) {
            Map<String, Object> jobMap = (Map<String, Object>)JSON.deserializeUntyped(job);

            String bodyTgt = (String)jobMap.get(GengoConstants.JOB_TARGET_CONTENT);

            if (jobMap.containsKey(GengoConstants.JOB_ORDER_ID)) {
                String orderId = (String)jobMap.get(GengoConstants.JOB_ORDER_ID);
                
                String soql = 'SELECT Id, Status__c FROM Translation__c WHERE Order_Id__c = :orderId';
                
                List<Translation__c> translations = Database.query(soql);

                if (jobMap.containsKey(GengoConstants.JOB_STATUS)) {
                    String status = (String)jobMap.get(GengoConstants.JOB_STATUS);
                    
                    for (Translation__c translation: translations) {
                        translation.Status__c = status;
                        translation.Translated_Content__c = bodyTgt;
                    }

                    update translations;
                }
            }
        }
    }
}
