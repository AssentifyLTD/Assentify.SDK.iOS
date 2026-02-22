

import Foundation


public struct DocumentTokensModel:Codable {
    public let id: Int
    public  let templateId: Int
    public let tokenValue: String
    public let displayName: String
    public let tokenTypeEnum: Int
}


public struct TokensMappings: Codable {
    let id: Int
    let tokenId: Int
    let aBlockIdentifier: String
    let stepId: Int
    let aFlowPropertyIdentifier: String
    let flowName: String
    let blockName: String
    let stepName: String
    let displayName: String
    let sourceKey: String
    let isDeleted: Bool
    let type: Int

    enum CodingKeys: String, CodingKey {
        case id
        case tokenId
        case aBlockIdentifier
        case stepId
        case aFlowPropertyIdentifier
        case flowName
        case blockName
        case stepName
        case displayName
        case sourceKey
        case isDeleted
        case type
    }
}
