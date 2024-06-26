
import Foundation
@objc public class RemoteProcessingModel : NSObject , Codable {
    public  var destinationEndpoint: String?
    public  var response: String?
    public  var error: String?
    public  var success: Bool?
    
    init(destinationEndpoint: String? = nil, response: String? = nil, error: String? = nil, success: Bool? = nil) {
        self.destinationEndpoint = destinationEndpoint
        self.response = response
        self.error = error
        self.success = success
    }
    
}

public func parseDataToRemoteProcessingModel(data: [String: Any]) -> RemoteProcessingModel {
    var success = false;
    var response = "";
    if let boolValue = data["success"] as? Bool {
            success = boolValue;
    }
    if let dictionaryResponse =  data["response"] as? [String: Any] {
        if let jsonString = dictionaryToString(dictionaryResponse) {
            response = jsonString
        }
    }
    return RemoteProcessingModel(
        destinationEndpoint: data["destinationEndpoint"] as? String ,
        response:response,
        error: data["error"] as? String ,
        success: success
    )
}


public func dictionaryToString(_ dictionary: [String: Any]) -> String? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)
        return jsonString
    } catch {
        return nil
    }
}

public func encodeBaseResponseDataModelToJson(data: RemoteProcessingModel) -> String {
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(data)
        return String(data: jsonData, encoding: .utf8) ?? ""
    } catch {
        return "\(error.localizedDescription)"
    }
}





