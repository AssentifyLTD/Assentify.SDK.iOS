import Foundation


public final class AssistedDataEntry {

    private let apiKey: String
    private let configModel: ConfigModel

    public  var delegate: AssistedDataEntryDelegate?
    private var stepID: String?

    public init(apiKey: String, configModel: ConfigModel,delegate:AssistedDataEntryDelegate) {
        self.apiKey = apiKey
        self.configModel = configModel
        self.delegate = delegate
    }

    

    /// Kotlin: setStepId(stepId: String?)
    public func setStepId(_ stepId: String?) {
        self.stepID = stepId

        if self.stepID == nil {
            let assistedSteps = configModel.stepDefinitions.filter {
                $0.stepDefinition == "AssistedDataEntry"
            }

            if assistedSteps.count == 1,
               let step = assistedSteps.first {

                self.stepID = String(step.stepId)   // ← assuming stepId exists
                getAssistedDataEntryStep()
                return
            }


            delegate?.onAssistedDataEntryError(
                message: "Step ID is required because multiple 'Assisted Data Entry' steps are present."
            )
            return
        }

        // stepId provided
        getAssistedDataEntryStep()
    }

    // MARK: - Network

    private func getAssistedDataEntryStep() {
        guard let stepID else {
            delegate?.onAssistedDataEntryError(message: "Step ID is missing.")
            return
        }

        getAssistedDataEntryStep(
            apiKey: apiKey,
            userAgent: "SDK",
            flowInstanceId: configModel.flowInstanceId,
            tenantIdentifier: configModel.tenantIdentifier,
            blockIdentifier: configModel.blockIdentifier,
            instanceId: configModel.instanceId,
            flowIdentifier: configModel.flowIdentifier,
            instanceHash: configModel.instanceHash,
            ID:  Int(stepID)!
        ) {  result in

            switch result {
            case .success(let baseModel):
                self.delegate?.onAssistedDataEntrySuccess(assistedDataEntryModel: baseModel.data)

            case .failure(let error):
                self.delegate?.onAssistedDataEntryError(message: error.localizedDescription)
            }
        }
    }
    
   private  func getAssistedDataEntryStep(
                   apiKey: String,
                   userAgent: String,
                   flowInstanceId: String,
                   tenantIdentifier: String,
                   blockIdentifier: String,
                   instanceId: String,
                   flowIdentifier: String,
                   instanceHash: String,
                    ID: Int,
                   completion: @escaping (BaseResult<AssistedDataEntryBaseModel, Error>) -> Void) {
        let urlString = BaseUrls.baseURLGateway + "v1/AssistedDataEntry/GetStep/\(ID)"
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
                    let result = try decoder.decode(AssistedDataEntryBaseModel.self, from: responseData)
                     completion(BaseResult.success(result))
                } catch {
                    completion(BaseResult.failure(error))
                }
            }
            
            
        }
        task.resume()
        
     }
}
