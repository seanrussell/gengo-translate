public class OrderService {
    
    private TranslationService service;

    public OrderService() {
        this.service = new GengoService();
    }

    public List<Translation__c> updateJobs(String orderId, Map<String, Translation__c> jobMap) {
        List<Translation__c> translationsToUpdate = new List<Translation__c>();

        if (String.isNotBlank(orderId)) {
            try {
                String result = this.service.getOrder(orderId);
                GengoResponse.TranslationOrderResponse tor = (GengoResponse.TranslationOrderResponse)JSON.deserialize(result, GengoResponse.TranslationOrderResponse.class);
            
                if (tor.opstat == GengoConstants.OK_STATUS) {
                    GengoResponse.RetrieveResponse rr = tor.response;

                    for (String status: GengoConstants.ORDER_STATUSES) {
                        List<Translation__c> trans = processJobStatus(status, rr.order, jobMap);

                        if (!trans.isEmpty()) {
                            translationsToUpdate.addAll(trans);
                        }
                    }

                }
            } catch (Exception e) {

            }
        }

        return translationsToUpdate;
    }

    private List<Translation__c> processJobStatus(String jobStatus, GengoResponse.OrderResponse orderResponse, Map<String, Translation__c> jobMap) {
        List<Translation__c> translationsToUpdate = new List<Translation__c>();



        return translationsToUpdate;
    }
}
