
import Foundation

public struct SubmitRequestModel : Codable{
    public   let stepId: Int
    public  let stepDefinition: String
    public  let extractedInformation: [String: String]
}
