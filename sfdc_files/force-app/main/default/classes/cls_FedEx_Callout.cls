global class cls_FedEx_Callout {
    
    @AuraEnabled
    public static Map<String, Object> getShippingRates(String jsonInputData) {
        System.debug(jsonInputData);
        Map<String, Object> inputDataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInputData);
        Map<String, Object> inputData = (Map<String, Object>)inputDataMap.get('requestedShipment');
        //abstracting values we need for payload 
        Map<String,Object> shipper = (Map<String,Object>)inputData.get('shipper');
        Map<String,Object> recipient = (Map<String,Object>)inputData.get('recipient');
        List<Object> requestedPackageLineItems = (List<Object>)inputData.get('requestedPackageLineItems');

        String fedExEndpoint = 'https://apis-sandbox.fedex.com/rate/v1/rates/quotes'; //normally would create util class or MDT for this
        String accountNumber = [SELECT Label, Number__c FROM FedExIntegrationInfo__mdt  WHERE Label = 'AccountNumber' LIMIT 1].Number__c;
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('accountNumber', new Map<String, String>{'value' => accountNumber});
        payload.put(
            'requestedShipment', new Map<String, Object>{
                'shipper' => shipper,
                'recipient' => recipient,
                'rateRequestType' => new List<String>{'ACCOUNT', 'LIST'},
                'pickupType' => 'DROPOFF_AT_FEDEX_LOCATION',
                'requestedPackageLineItems' => requestedPackageLineItems
            }
        );
        payload.put('carrierCodes', new List<String>{'FDXE', 'FDXG'});
        payload.put('pickupType', 'DROPOFF_AT_FEDEX_LOCATION');
        
        String token = getAuthToken();
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(fedExEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-locale', 'en_us');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setBody(JSON.serialize(payload));

        HttpResponse res = http.send(req);
        String body = res.getBody();
        Integer statusCode = res.getStatusCode();
        Map<String, Object> outputData = (Map<String, Object>)JSON.deserializeUntyped(body);
        Map<String,Object> responseToPage = new Map<String,Object>();
        if(statusCode == 200){
            Map<String, Object> output = (Map<String, Object>)outputData.get('output');
            List<Object> rateReplyDetails = (List<Object>)output.get('rateReplyDetails');
            responseToPage.put('statusCode', statusCode);
            responseToPage.put('data', rateReplyDetails);
        }else{
            responseToPage.put('statusCode', statusCode);
            responseToPage.put('data', outputData.get('errors'));
        }
        return responseToPage;
    }
    
    public static String getAuthToken(){
        String fedExEndpoint = 'https://apis-sandbox.fedex.com/oauth/token';            
        Http http = new Http();
        
        String apiKey = [SELECT Label, Number__c FROM FedExIntegrationInfo__mdt WHERE Label = 'API Key'].Number__c;
        String clientSecret = [SELECT Label, Number__c FROM FedExIntegrationInfo__mdt WHERE Label = 'ClientSecret'].Number__c;
        
        String payload = 'grant_type=client_credentials&client_id=' + apiKey + '&client_secret=' + clientSecret;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(fedExEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(payload);

        HttpResponse res = http.send(req);
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200){
            Map<String, Object> deserializedBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            return (String)deserializedBody.get('access_token');
        } else {
            throw new AuthException('Authorization failed. Please check your FedEx Credentials.');
        }
    }

}