
import Foundation
@objc public class OtherResponseModel : NSObject  {
    public  var destinationEndpoint: String?
    public  var otherExtractedModel: OtherExtractedModel?
    public  var error: String?
    public  var success: Bool?
    
    init(destinationEndpoint: String? = nil, otherExtractedModel: OtherExtractedModel? = nil, error: String? = nil, success: Bool? = nil) {
        self.destinationEndpoint = destinationEndpoint
        self.otherExtractedModel = otherExtractedModel
        self.error = error
        self.success = success
    }
    
}



@objc public class OtherExtractedModel : NSObject  {
    public var outputProperties: [String: Any]?
    public var extractedData: [String: Any]?
    public var additionalDetails: [String: Any]?
    public var imageUrl: String?
    public var faces: [String]?
    public var identificationDocumentCapture: IdentificationDocumentCapture?

    init(outputProperties: [String: Any]? = nil, extractedData: [String: Any]? = nil,additionalDetails: [String: Any]? = nil , imageUrl: String? = nil, faces: [String]? = nil,identificationDocumentCapture:IdentificationDocumentCapture) {
        self.outputProperties = outputProperties
        self.extractedData = extractedData
        self.imageUrl = imageUrl
        self.faces = faces
        self.identificationDocumentCapture = identificationDocumentCapture
        self.additionalDetails = additionalDetails
    }
    
   static func fromJsonString(responseString: String) -> OtherExtractedModel? {
        guard let  responseData = responseString.data(using: .utf8),
              let response = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
            return nil
        }

        var faces: [String] = []
        if let faceArray = response["faces"] as? [[String: Any]] {
            for face in faceArray {
                if let faceUrl = face["FaceUrl"] as? String {
                    faces.append(faceUrl)
                }
            }
        }

        let imageUrl = response["ImageUrl"] as? String
        let outputProperties = response["OutputProperties"] as? [String: Any]
        let additionalDetails = response["AdditionalDetails"] as? [String: Any]
        var extractedData: [String: Any] = [:]
        
        outputProperties?.forEach { (key, value) in
            var keys = key.split(separator: "_").map(String.init)
            if let newKey = keys.popLast() {
                extractedData[newKey] = value
            }
        }
        var  identificationDocumentCapture = fillIdentificationDocumentCapture(outputProperties:outputProperties )
       return OtherExtractedModel(outputProperties: outputProperties, extractedData: extractedData,additionalDetails:additionalDetails, imageUrl: imageUrl, faces: faces,identificationDocumentCapture:identificationDocumentCapture)
    }

}
