
import Foundation

public struct ValidateKeyModel: Codable {
    let message: String?
    let statusCode: Int
    let error: String?
    let errorCode: String?
    let data: DataResponse
    let isSuccessful: Bool
    
    enum CodingKeys: String, CodingKey {
        case message
        case statusCode
        case error
        case errorCode
        case data
        case isSuccessful
    }
    
    struct DataResponse: Codable {
        let tenantIdentifier: String
        let key: String
    }
}
