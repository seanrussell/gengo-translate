public class GengoService implements TranslationService {
    
    private static final Auth AUTH = new Auth();

    public class Auth {
        String apiUrl { get; set; }
        String apiKey { get; set; }
        String apiSig { get; set; }
        String ts { get; set; }

        public Auth() {
            List<Translation_Setting__mdt> settings = [
                SELECT 
                    Sandbox_Url__c,
                    Production_Url__c,
                    Api_Key__c,
                    Api_Sig__c,
                    Use_Sandbox__c
                FROM 
                    Translation_Setting__mdt
                WHERE
                    Active__c = true
            ];

            if (!settings.isEmpty()) {
                initialize(settings.get(0));
            }
        }

        private void initialize(Translation_Setting__mdt setting) {
            String currentTime = String.valueOf(Datetime.now().getTime());

            this.apiKey = setting.Api_Key__c;
            this.ts = currentTime;

            Blob hmacData = Crypto.generateMac(
                'hmacSHA1', 
                Blob.valueOf(currentTime), 
                Blob.valueOf(setting.Api_Sig__c)
            );

            this.apiSig = EncodingUtil.convertToHex(hmacData);
            this.apiUrl = (setting.Use_Sandbox__c) ? setting.Sandbox_Url__c: setting.Production_Url__c;
        }
    }

    public class Job extends HttpCalloutBase {
        public final String TRANSLATE_JOBS = 'translate/jobs';
        public final String JOB_DETAILS = 'translate/job/{0}';
        public Auth auth { get; set; }

        public Job(Auth auth) {
            this.auth = auth;
        }

        public String postJobs(String relatedRecordId, String objectName, String fieldName, String jobs) {
            String form = String.format('ts={0}&api_key={1}&api_sig={2}&data={3}', new List<String>{
                this.auth.ts,
                this.auth.apiKey,
                this.auth.apiSig,
                jobs
            });

            Map<String, String> headers = new Map<String, String>{
                'Content-Type' => 'application/x-www-form-urlencoded'
            };

            return send('POST', this.auth.apiUrl, form, headers);
        }

        public String getJobStatus(String jobId) {
            String qs = String.format('?ts={0}&api_key={1}&api_sig={2}', new List<String>{
                this.auth.ts,
                this.auth.apiKey,
                this.auth.apiSig
            });

            String apiUrl = String.format(this.auth.apiUrl, new List<String>{ jobId });

            return send('GET', apiUrl, null, null);
        }
    }

    public class Acct extends HttpCalloutBase {
        public final String ACCOUNT_BALANCE = 'account/balance';
        public Auth auth { get; set; }

        public Acct(Auth auth) {
            this.auth = auth;
        }

        public String getAccountBalance() {
            String qs = String.format('?ts={0}&api_key={1}&api_sig={2}', new List<String>{
                this.auth.ts,
                this.auth.apiKey,
                this.auth.apiSig
            });

            return send('GET', this.auth.apiUrl, null, null);
        }
    }

    public class Service extends HttpCalloutBase {
        public final String LANGUAGE_PAIRS = 'translate/service/language_pairs';
        public Auth auth { get; set; }

        public Service(Auth auth) {
            this.auth = auth;
        }

        public String getLanguagePairs() {
            String qs = String.format('?ts={0}&api_key={1}&api_sig={2}', new List<String>{
                this.auth.ts,
                this.auth.apiKey,
                this.auth.apiSig
            });

            return send('GET', this.auth.apiUrl, null, null);
        }

    }

    public String submitTranslation(String relatedRecordId, String objectName, String fieldName, String jobs) {
        Job job = new Job(AUTH);
        return job.postJobs(relatedRecordId, objectName, fieldName, jobs);
    }

    public String getTranslationStatus(String jobId) {
        Job job = new Job(AUTH);
        return job.getJobStatus(jobId);
    }

    public String getAccountBalance() {
        Acct acct = new Acct(AUTH);
        return acct.getAccountBalance();
    }

    public String getLanguages() {
        Service service = new Service(AUTH);
        return service.getLanguagePairs();
    }
}
