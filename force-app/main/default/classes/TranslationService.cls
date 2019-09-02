public interface TranslationService {
    /**
	 * Submits content for translation
	 * @param relatedRecordId the id of the record that contains the content to be translated
     * @param objectName the name of the object type
     * @param fieldName the name of the field on the object being translated
     * @param jobs the jobs containing the content to be translated
	 * @return String 
	 */
    String submitTranslation(String relatedRecordId, String objectName, String fieldName, String jobs);

    /**
	 * Retrieves status of the translation
	 * @param jobId the id of the translation job in the external system
	 * @return String 
	 */
    String getTranslationStatus(String jobId);

	/**
	 * Retrieves an order by id
	 * @param orderId the id of the order to retrieve
	 * @return String
	 */
	String getOrder(String orderId);

	/**
	 * Retrieves a list of jobs
	 * @param jobIs the list of job ids to retrieve
	 * @return String
	 */
	String getJobs(List<Integer> jobIds);

    /**
	 * Retrieves account balance
	 * @return String
	 */
    String getAccountBalance();

    /**
	 * Retrieves language pairs available
	 * @return String 
	 */
	String getLanguagePairs();

	/**
	 * Retrieves languages available for translation
	 * @return String 
	 */
    String getLanguages();

	/**
	 * Updates a translation 
	 * @param jobId the id of the job record
	 * @param action the action to perform
	 * @return String 
	 */
	String updateTranslation(String jobId, String action);
}
