

import Foundation

class RemoteProcessing {
    
    enum BaseResult<Success, Failure: Error> {
        case success(Success)
        case failure(Failure)
    }

    
    private var delegate: RemoteProcessingDelegate?

    private let eventNames: [String] = [
        HubConnectionTargets.ON_ERROR,
        HubConnectionTargets.ON_RETRY,
        HubConnectionTargets.ON_CLIP_PREPARATION_COMPLETE,
        HubConnectionTargets.ON_STATUS_UPDATE,
        HubConnectionTargets.ON_UPDATE,
        HubConnectionTargets.ON_LIVENESS_UPDATE,
        HubConnectionTargets.ON_COMPLETE,
        HubConnectionTargets.ON_CARD_DETECTED,
        HubConnectionTargets.ON_MRZ_EXTRACTED,
        HubConnectionTargets.ON_MRZ_DETECTED,
        HubConnectionTargets.ON_NO_MRZ_EXTRACTED,
        HubConnectionTargets.ON_FACE_DETECTED,
        HubConnectionTargets.ON_NO_FACE_DETECTED,
        HubConnectionTargets.ON_FACE_EXTRACTED,
        HubConnectionTargets.ON_QUALITY_CHECK_AVAILABLE,
        HubConnectionTargets.ON_DOCUMENT_CAPTURED,
        HubConnectionTargets.ON_DOCUMENT_CROPPED,
        HubConnectionTargets.ON_UPLOAD_FAILED
    ]

    
    

    func starProcessing(
        url: String,
        videoClip: String,
        stepDefinition: String,
        appConfiguration: ConfigModel,
        templateId: String,
        secondImage: String,
        connectionId: String,
        clipsPath: String,
        checkForFace: Bool,
        processMrz: Bool,
        performLivenessDetection: Bool,
        saveCapturedVideo: Bool,
        storeCapturedDocument: Bool,
        isVideo: Bool,
        storeImageStream: Bool,
        selfieImage: String,
        completion: @escaping (BaseResult<RemoteProcessingModel?, Error>) -> Void
    ) {
        let traceIdentifier = UUID().uuidString
        let urlString = url
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 120
            var stepIdString = "";
            if let stepId = appConfiguration.stepDefinitions.first(where: { $0.stepDefinition == stepDefinition })?.stepId {
              stepIdString = String(stepId)
            }
        
            request.setValue(stepIdString, forHTTPHeaderField: "x-step-id")
            request.setValue(appConfiguration.blockIdentifier, forHTTPHeaderField: "x-block-identifier")
            request.setValue(appConfiguration.flowIdentifier, forHTTPHeaderField: "x-flow-identifier")
            request.setValue(appConfiguration.flowInstanceId, forHTTPHeaderField: "x-flow-instance-id")
            request.setValue(appConfiguration.instanceHash, forHTTPHeaderField: "x-instance-hash")
            request.setValue(appConfiguration.instanceId, forHTTPHeaderField: "x-instance-id")
            request.setValue(appConfiguration.tenantIdentifier, forHTTPHeaderField: "x-tenant-identifier")
            
        
       

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")


        
        let formData = [
            "tenantId": appConfiguration.tenantIdentifier,
            "blockId": appConfiguration.blockIdentifier,
            "instanceId": appConfiguration.instanceId,
            "templateId": templateId,
            "livenessCheckEnabled": String(performLivenessDetection),
            "processMrz": String(processMrz),
            "DisableDataExtraction": "false",
            "storeImageStream": String(storeImageStream),
            "isVideo": "false",
            "clipsPath": "clipsPath",
            "isMobile": "true",
            "videoClipB64": videoClip,
            "secondImage": secondImage,
            "checkForFace":  String(checkForFace),
            "callerConnectionId": connectionId,
            "connectionId": connectionId,
            "TraceIdentifier":UUID().uuidString,
            "selfieImage":selfieImage
        ] as [String : String]

        
        
  

        request.httpBody = createBody(boundary: boundary, parameters: formData)

    
     
        
    
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
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
                        if let dictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                            let dataResult =  parseDataToRemoteProcessingModel(data: dictionary);
                            completion(BaseResult.success(dataResult))
                          } else {
                          }
               
                        
                    } catch {
                        completion(BaseResult.failure(error))
                    }
                }else{
                    completion(BaseResult.failure(NSError(domain: "Invalid Key", code: 0, userInfo: nil)))
                }
            }
            task.resume()
        }
    


    func setDelegate(delegate: RemoteProcessingDelegate?) {
        self.delegate = delegate
    }

  
    func createBody(boundary: String, parameters: [String: String]) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        for (key, value) in parameters {
            if let stringDataBoundary = "--\(boundary + lineBreak)".data(using: .utf8) {
                body.append(stringDataBoundary)
            }
            
            if let stringDataKey = "Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)".data(using: .utf8) {
                body.append(stringDataKey)
            }
            if let stringDataValue = "\(value + lineBreak)".data(using: .utf8) {
                body.append(stringDataValue)
            }
            

        }
        if let stringDataBoundary = "--\(boundary)--\(lineBreak)".data(using: .utf8) {
            body.append(stringDataBoundary)
        }
        return body
    }



  

    


   
}
