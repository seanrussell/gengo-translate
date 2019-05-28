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
