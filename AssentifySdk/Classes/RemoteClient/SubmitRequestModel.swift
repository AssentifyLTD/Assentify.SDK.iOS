
import Foundation

public struct SubmitRequestModel : Codable{
    let stepId: Int
    let stepDefinition: String
    let extractedInformation: [String: String]
}
