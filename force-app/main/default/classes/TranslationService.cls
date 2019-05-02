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
	 * Retrieves account balance
	 * @return String 
	 */
    String getAccountBalance();

    /**
	 * Retrieves languages available for translatoin
	 * @return String 
	 */
    String getLanguages();
}
