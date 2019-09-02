public class TranslationJobUpdateQueueable implements Queueable, Database.AllowsCallouts {
    private String orderId;
    private TranslationService service;

    public TranslationJobUpdateQueueable(String orderId) {
        this.orderId = orderId;
        this.service = new GengoService();
    }

    public void execute(QueueableContext context) {
        Boolean successfullyUpdated = false;

        if (String.isNotBlank(this.orderId)) {
            try {
                String result = this.service.getOrder(this.orderId);
                
                GengoResponse.TranslationOrderResponse tor = (GengoResponse.TranslationOrderResponse)JSON.deserialize(result, GengoResponse.TranslationOrderResponse.class);
            
                if (tor.opstat == GengoConstants.OK_STATUS) {
                    GengoResponse.RetrieveResponse rr = tor.response;

                    if (rr.order != null) {
                        List<Translation__c> translations = retrieveTranslations(this.orderId);
                        List<Integer> jobIds = rr.order.jobs_available;

                        for (Translation__c translation: translations) {
                            for (Integer jobId: jobIds) {
                                translation.Job_Id__c = String.valueOf(jobId);
                            }
                        }

                        update translations;
                    }
                }
            } catch (Exception e) {
                System.debug('ERROR: ' + e.getMessage());
            }
        }

        if (!successfullyUpdated) {
            System.enqueueJob(this);
        }
    }

    private List<Translation__c> retrieveTranslations(String orderId) {
        return [
            SELECT 
                Id,
                Job_Id__c
            FROM 
                Translation__c 
            WHERE 
                Order_Id__c = :orderId
        ];
    }
}
