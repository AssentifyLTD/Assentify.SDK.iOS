

import Foundation

public struct CreateUserDocumentRequestModel:Codable {
    let userId: String
    let documentTemplateId: Int
    let data: [String: String]
    let outputType: Int
}

public struct CreateUserDocumentResponseModel:Codable {
    let templateInstance: String
    let templateInstanceId: Int
    let documentId: Int
    let isPdf: Bool
}
