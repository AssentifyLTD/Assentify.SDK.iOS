

import Foundation

public struct SignatureRequestModel:Codable {
    let documentId: Int
    let documentInstanceId: Int
    let documentName: String
    let username: String
    let requiresAdditionalData: Bool
    let signature: String
}

public struct SignatureResponseModel:Codable {
    let signedDocument: String
    let fileName: String
    let signedDocumentUri: String
}
