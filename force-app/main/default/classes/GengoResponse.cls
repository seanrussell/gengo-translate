public class GengoResponse {
    /* Job submit */
    public class SubmitResponse {
        public Integer job_count { get; set; }
        public Integer order_id { get; set; }
        public Decimal credits_used { get; set; }
    }

    public class TranslationSubmitResponse {
        public String opstat { get; set; }
        public SubmitResponse response { get; set; }
    }

    /* Order retrieve */
    public class OrderResponse {
        public Integer jobs_queued { get; set; }

        public Map<String, Object> job_statuses { get; set; }

        public List<Integer> jobs_reviewable { 
            get; 
            set{
                this.job_statuses.put('jobs_reviewable', jobs_reviewable);
                jobs_reviewable = value;
            }
        }

        public List<Integer> jobs_available { 
            get;
            set {
                this.job_statuses.put('jobs_available', jobs_available);
            }
        }

        public List<Integer> jobs_pending { 
            get;
            set{
                this.job_statuses.put('jobs_pending', jobs_pending);
            }
        }

        public List<Integer> jobs_approved { 
            get; 
            set {
                this.job_statuses.put('jobs_approved', jobs_approved);
            }
        }

        public List<Integer> jobs_revising { 
            get; 
            set {
                this.job_statuses.put('jobs_revising', jobs_revising);
            }
        }

        public List<Integer> jobs_cancelled { 
            get; 
            set {
                this.job_statuses.put('jobs_canceled', jobs_cancelled);
            }
        }

        public List<Integer> jobs_held { 
            get; 
            set {
                this.job_statuses.put('jobs_held', jobs_held);
            }
        }

        public String order_id { get; set; }
        public String total_credits { get; set; }
        public Integer total_units { get; set; }
        public String total_jobs { get; set; }

        public OrderResponse() {
            this.job_statuses = new Map<String, Object>();
        }
    }

    public class RetrieveResponse {
        public OrderResponse order { get; set; }
    }

    public class TranslationOrderResponse {
        public String opstat { get; set; }
        public RetrieveResponse response { get; set; }
    }
}