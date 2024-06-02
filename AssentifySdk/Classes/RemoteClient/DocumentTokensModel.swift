

import Foundation


public struct DocumentTokensModel:Codable {
    let id: Int
    let templateId: Int
    let tokenValue: String
    let displayName: String
    let tokenTypeEnum: Int
}
