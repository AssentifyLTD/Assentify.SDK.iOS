

import Foundation

public struct DataModel: Codable {
    public  let selectedTemplates: [Int]
}

public struct ContextAwareSigningModel: Codable {
    public  let statusCode: Int
    public  let data: DataModel
}
