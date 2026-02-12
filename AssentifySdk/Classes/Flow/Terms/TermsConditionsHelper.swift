


func  getTermsConditionsStep(
               apiKey: String,
               userAgent: String,
               flowInstanceId: String,
               tenantIdentifier: String,
               blockIdentifier: String,
               instanceId: String,
               flowIdentifier: String,
               instanceHash: String,
                ID: Int,
               completion: @escaping (BaseResult<TermsConditionsModel, Error>) -> Void) {
    let urlString = BaseUrls.baseURLGateway + "v1/TermsConditions/GetStep/\(ID)"
    guard let url = URL(string: urlString) else {
        completion(BaseResult.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
    request.setValue(userAgent, forHTTPHeaderField: "X-User-Agent")
    request.setValue(flowInstanceId, forHTTPHeaderField: "X-Flow-Instance-Id")
    request.setValue(tenantIdentifier, forHTTPHeaderField: "X-Tenant-Identifier")
    request.setValue(blockIdentifier, forHTTPHeaderField: "X-Block-Identifier")
    request.setValue(instanceId, forHTTPHeaderField: "X-Instance-Id")
    request.setValue(flowIdentifier, forHTTPHeaderField: "X-Flow-Identifier")
    request.setValue(instanceHash, forHTTPHeaderField: "X-Instance-Hash")
    
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
     
        guard let httpResponse = response as? HTTPURLResponse else {
       
            completion(BaseResult.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
            return
        }
        
        if(httpResponse.statusCode == 200){
            guard let responseData = data else {
                     completion(BaseResult.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                     return
                 }
            if let responseString = String(data: responseData, encoding: .utf8) {
            }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(TermsConditionsModel.self, from: responseData)
                 completion(BaseResult.success(result))
            } catch {
                completion(BaseResult.failure(error))
            }
        }
        
        
    }
    task.resume()
    
 }
