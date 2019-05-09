public class GengoConstants {
    // General
    public static final String JOB_PREFIX = 'job_';
    public static final String STATUS_AVAILABLE = 'available';

    // Authentication
    public static final String QUERY_STRING = '?ts={0}&api_key={1}&api_sig={2}';
    public static final String FORM_DATA = 'ts={0}&api_key={1}&api_sig={2}&data={3}';

    // Statuses
    public static final String OK_STATUS = 'ok';

    // Payload fields
    // Top level
    public static final String STATUS_FIELD = 'opstat';
    public static final String RESPONSE_FIELD = 'response';

    // Job
    public static final String JOBS_FIELD = 'jobs';
    public static final String JOB_TYPE = 'type';
    public static final String JOB_SLUG = 'slug';
    public static final String JOB_SOURCE_CONTENT = 'body_src';
    public static final String JOB_SOURCE_LANGUAGE = 'lc_src';
    public static final String JOB_TARGET_LANGUAGE = 'lc_tgt';
    public static final String JOB_TIER = 'tier';
    public static final String JOB_AUTO_APPROVE = 'auto_approve';
    public static final String JOB_CUSTOM_DATA = 'custom_data';

    // Order
    public static final String ORDER_FIELD = 'order';
    public static final String ORDER_JOBS_REVIEWABLE = 'jobs_reviewable';
    public static final String ORDER_JOBS_AVAILABLE = 'jobs_available';
    public static final String ORDER_JOBS_PENDING = 'jobs_pending';
    public static final String ORDER_JOBS_APPROVED = 'jobs_approved';
    public static final String ORDER_JOBS_REVISING = 'jobs_revising';
    public static final String ORDER_JOBS_CANCELLED = 'jobs_cancelled';
    public static final String ORDER_JOBS_HELD = 'jobs_held';
}
