

import Foundation

public struct DataModel: Codable {
    let selectedTemplates: [Int]
}

public struct ContextAwareSigningModel: Codable {
    let statusCode: Int
    let data: DataModel
}
