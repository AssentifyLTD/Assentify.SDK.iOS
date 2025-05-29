

import Foundation


public struct DocumentTokensModel:Codable {
    public let id: Int
    public  let templateId: Int
    public let tokenValue: String
    public let displayName: String
    public let tokenTypeEnum: Int
}
