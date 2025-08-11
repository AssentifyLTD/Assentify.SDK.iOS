
import Foundation

public enum BaseResult<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}



public func remoteValidateKey(apiKey: String, tenantIdentifier: String, agentSource: String, completion: @escaping (BaseResult<ValidateKeyModel, Error>) -> Void) {
    let urlString = BaseUrls.baseURLAuthentication +  "ValidateKey"
    guard let url = URL(string: urlString) else {
        completion(BaseResult.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue(tenantIdentifier, forHTTPHeaderField: "x-tenant-identifier")
    request.setValue(agentSource, forHTTPHeaderField: "X-Source-Agent")
    
    let body = "apiKey=\(apiKey)"
    request.httpBody = body.data(using: .utf8)
    
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
                 let validateKeyModel = try decoder.decode(ValidateKeyModel.self, from: responseData)
                 completion(BaseResult.success(validateKeyModel))
            } catch {
                completion(BaseResult.failure(error))
            }
        }else{
            completion(BaseResult.failure(NSError(domain: "Invalid Key", code: 0, userInfo: nil)))
        }
        
        
    }
    task.resume()
}


func  remoteGetStart(interActionId: String, completion: @escaping (BaseResult<ConfigModel, Error>) -> Void) {
    let urlString = BaseUrls.baseURLAPI + "v1/Manager/Start/\(interActionId)"
    guard let url = URL(string: urlString) else {
        completion(BaseResult.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    
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
                 let configModel = try decoder.decode(ConfigModel.self, from: responseData)
                 completion(BaseResult.success(configModel))
            } catch {
                completion(BaseResult.failure(error))
            }
        }
        
        
    }
    task.resume()
}

func  remoteGetTemplates( completion: @escaping (BaseResult<[Templates], Error>) -> Void) {
    let urlString = BaseUrls.baseURLIDPower + "GetTemplates"
    guard let url = URL(string: urlString) else {
        completion(BaseResult.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    
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
                 let templates = try decoder.decode([Templates].self, from: responseData)
                 completion(BaseResult.success(templates))
            } catch {
                completion(BaseResult.failure(error))
            }
        }
        
        
    }
    task.resume()
    
 }

func  remoteGetStep( apiKey: String,
               userAgent: String,
               flowInstanceId: String,
               tenantIdentifier: String,
               blockIdentifier: String,
               instanceId: String,
               flowIdentifier: String,
               instanceHash: String,
               ID: Int,completion: @escaping (BaseResult<ContextAwareSigningModel, Error>) -> Void) {
    let urlString = BaseUrls.baseURLGateway + "v1/ContextAwareSigning/GetStep/\(ID)"
    guard let url = URL(string: urlString) else {
        completion(BaseResult.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
    request.setValue(userAgent, forHTTPHeaderField: "X-Source-Agent")
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
                let result = try decoder.decode(ContextAwareSigningModel.self, from: responseData)
                 completion(BaseResult.success(result))
            } catch {
                completion(BaseResult.failure(error))
            }
        }
        
        
    }
    task.resume()
    
 }



func  remoteGetTokens(
                       templateId: Int,completion: @escaping (BaseResult<[DocumentTokensModel], Error>) -> Void) {
    let urlString = BaseUrls.baseURLSigning + "Tokens/sdk/gettokens/\(templateId)"
    guard let url = URL(string: urlString) else {
        completion(BaseResult.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    
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
                let result = try decoder.decode([DocumentTokensModel].self, from: responseData)
                 completion(BaseResult.success(result))
            } catch {
                completion(BaseResult.failure(error))
            }
        }
        
        
    }
    task.resume()
    
 }


func  remoteCreateUserDocumentInstance(
    requestBody: CreateUserDocumentRequestModel,completion: @escaping (BaseResult<CreateUserDocumentResponseModel, Error>) -> Void) {
    let urlString = BaseUrls.baseURLSigning + "Document/v2/CreateUserDocumentInstance"
    guard let url = URL(string: urlString) else {
        completion(BaseResult.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
                completion(.failure(NSError(domain: "Failed to encode request body", code: 0, userInfo: nil)))
                return
            }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    
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
                let result = try decoder.decode(CreateUserDocumentResponseModel.self, from: responseData)
                 completion(BaseResult.success(result))
            } catch {
                completion(BaseResult.failure(error))
            }
        }
        
        
    }
    task.resume()
    
 }

func  remoteSignature(
    requestBody: SignatureRequestModel,completion: @escaping (BaseResult<SignatureResponseModel, Error>) -> Void) {
    let urlString = BaseUrls.baseURLSigning + "Signature"
    guard let url = URL(string: urlString) else {
        completion(BaseResult.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
                completion(.failure(NSError(domain: "Failed to encode request body", code: 0, userInfo: nil)))
                return
            }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    
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
                let result = try decoder.decode(SignatureResponseModel.self, from: responseData)
                 completion(BaseResult.success(result))
            } catch {
                completion(BaseResult.failure(error))
            }
        }
        
        
    }
    task.resume()
    
 }

func remoteSubmitData(apiKey: String,
                      configModel: ConfigModel,
                      submitRequestModel: [SubmitRequestModel],
                      completion: @escaping (BaseResult<Bool, Error>) -> Void) {
    let urlString = BaseUrls.baseURLGateway + "v1/Manager/Submit"
    guard let url = URL(string: urlString) else {
        let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        print("Request URL is invalid: \(urlString)")
        completion(BaseResult.failure(error))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
    request.setValue("SDK", forHTTPHeaderField: "X-Source-Agent")
    request.setValue(configModel.flowInstanceId, forHTTPHeaderField: "X-Flow-Instance-Id")
    request.setValue(configModel.tenantIdentifier, forHTTPHeaderField: "X-Tenant-Identifier")
    request.setValue(configModel.blockIdentifier, forHTTPHeaderField: "X-Block-Identifier")
    request.setValue(configModel.instanceId, forHTTPHeaderField: "X-Instance-Id")
    request.setValue(configModel.flowIdentifier, forHTTPHeaderField: "X-Flow-Identifier")
    request.setValue(configModel.instanceHash, forHTTPHeaderField: "X-Instance-Hash")

    do {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonData = try jsonEncoder.encode(submitRequestModel)
        request.httpBody = jsonData

                
        // Log request details
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request Submit Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("Request Submit : \(jsonString)")
            BugsnagObject.logInfo(message: "Data submission started. \(jsonString)", configModel:configModel)

        }
    } catch {
        print("Failed to encode request body: \(error)")
        completion(BaseResult.failure(error))
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Request failed with error: \(error)")
            BugsnagObject.logInfo(message: "Data submission failed: \(error)", configModel:configModel)
            completion(BaseResult.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = NSError(domain: "Invalid response", code: 0, userInfo: nil)
            print("Invalid response received")
            BugsnagObject.logInfo(message: "Data submission failed: \(error)", configModel:configModel)
            completion(BaseResult.failure(error))
            return
        }

        // Log response details
        print("Response Status Code: \(httpResponse.statusCode)")
        if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
            if(!responseString.isEmpty){
                print("Response Data: \(responseString)")
                BugsnagObject.logInfo(message: "Data submission Response Data: \(responseString)", configModel:configModel)
            }
        } else {
            print("No response data received")
        }

        if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
            BugsnagObject.logInfo(message: "Data submission success", configModel:configModel)
            completion(BaseResult.success(true))
        } else {
            let error = NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: nil)
            BugsnagObject.logInfo(message: "Data submission failed \(error)", configModel:configModel)
            completion(BaseResult.failure(error))
        }
    }
    task.resume()
}

func transformData(apiKey: String, language: String, request: TransformationModel, completion: @escaping (BaseResult<[LanguageTransformationModel], Error>) -> Void) {
    let urlString = BaseUrls.languageTransformationUrl + "LanguageTransform/LanguageTransformation"
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
    urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    urlRequest.setValue(language, forHTTPHeaderField: "accept-language")
    
    do {
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
    } catch {
        completion(.failure(error))
        return
    }
    
    let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode([LanguageTransformationModel].self, from: data)
            completion(.success(result))
        } catch {
            completion(.failure(error))
        }
    }
    task.resume()
}



