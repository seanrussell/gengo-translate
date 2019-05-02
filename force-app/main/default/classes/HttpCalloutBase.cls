public virtual class HttpCalloutBase {
    
    public String send(String method, String endpoint, String body, Map<String, String> headers) {
        Http h = new Http();

        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint(endpoint);
        
        if (body != null) {
            request.setBody(body);
        }

        request.setHeader('Accept', 'application/json');

        if (headers != null) {
            for (String headerKey: headers.keySet()) {
                String headerValue = headers.get(headerKey);
                request.setHeader(headerKey, headerValue);
            }
        }

        HttpResponse response = h.send(request);

        return response.getBody();
    }
}
