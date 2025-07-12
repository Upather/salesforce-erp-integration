@RestResource(urlMapping='/sync/*')
global with sharing class SyncServiceREST {

    /* 
    @description Standardized success/error response structure
    */

    global class SyncResponse {
        public Boolean success;
        public String message;
        public String recordId;

        public Map<String, Object> data;

        public SyncResponse(Boolean success, String message) {
            this.success = success;
            this.message = message;
            this.data = new Map<String, Object>();
        }
    }

    /* 
    @description Expected structure - incoming request payload
    */

    global class SyncRequest {
        public String externalId;
        public String operation;

        public Map<String,Object> recordData;
    }



    //http methods placeholder
    //GET
    
    /* 
    @description to handle GET requests & provides health check for the service
    */

    @HttpGet
    global static SyncResponse getStatus() {
        //set status code 
        RestContext.response.statusCode = 200;

        try {
            SyncResponse response = new SyncResponse(true, 'Sync service healthy');

            // Useful additional data
            response.data.put('timestamp', System.now());
            response.data.put('version', '1.0');
            // identify the integration user
            response.data.put('runningAsUser', UserInfo.getUserId());

            return response;

        } catch (Exception e) {
            RestContext.response.statusCode = 500; // server err
            return new SyncResponse(false, 'Error during health check: ' + e.getMessage());            
        }
    }

    //POST

    /* 
    @description to handle POST requests for records (create / update)
    */
    
    @HttpPost
    global static SyncResponse getStatus() {
        RestRequest incomingRequest = RestContext.request;
        String requestBody = incomingRequest.requestBody.toString();

        try {
            SyncRequest parsedRequest = (SyncRequest) JSON.deserialize(requestBody, SyncRequest.class); //fill out

            //400
            if(String.isBlank(parsedRequest.externalId)) { //no response 
                RestContext.response.statusCode = 400; // bad request
                return new SyncResponse(false, 'External ID is required')
            }

            //database helper should handle logic

            //200
            RestContext.response.statusCode = 200; //ok
            SyncResponse successResponse = new SyncResponse(true, 'Account Synced');
            successResponse.recordId = salesforceId;

            return successResponse;

        // != 200 OR 400
        } catch (Exception e) {
            RestContext.response.statusCode = 500; //server err
            logSyncOperation(null, 'POST', 'Failed', requestBody, e.getMessage() + '\n' + e.getStackTraceString());
            return new SyncResponse(false, 'An unexpected error occured') 
        }

    }
}