

import Foundation

public struct SignatureRequestModel:Codable {
    public  let documentId: Int
    public  let documentInstanceId: Int
    public   let documentName: String
    public   let username: String
    public   let requiresAdditionalData: Bool
    public   let signature: String
}

public struct SignatureResponseModel:Codable {
    public   let signedDocument: String
    public   let fileName: String
    public   let signedDocumentUri: String
}
