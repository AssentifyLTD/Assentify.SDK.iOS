

import Foundation
public struct ConfigModel: Codable {
    public let stepId: Int
    public let tenantIdentifier: String
    public let blockIdentifier: String
    public let instanceId: String
    public let flowInstanceId: String
    public let flowIdentifier: String
    public let instanceHash: String
    public let flowName: String
    public let stepDefinitions: [StepDefinitions]
    public let stepMap: [StepMap]

}
public struct StepDefinitions: Codable {
    public  let stepId: Int
    public  let stepDefinition: String
    public  let customization: Customization
    public  let outputProperties: [OutputProperties]
}

public struct StepMap: Codable {
    public let id: Int
    public let stepType: Int
    public let stepName: String
    public let stepDefinition: String
    public let parentStepId: Int?
    public let numberOfBranches: Int?
    public let isVirtual: Bool
}



public struct OutputProperties: Codable {
    public let id: Int
    public let key: String
    public  let displayName: String
    public  let isRequired: Bool
    public let isExcluded: Bool
    public  let type: Int
}

public struct Customization: Codable {
    public  let processMrz: Bool?
    public let storeCapturedDocument: Bool?
    public let performLivenessDetection: Bool?
    public let documentLiveness: Bool?
    public let storeImageStream: Bool?
    public let saveCapturedVideo: Bool?
    public let identificationDocuments: [IdentificationDocuments]?
}



public struct IdentificationDocuments : Codable{
    public  let key: String?
    public let selectedCountries: [String]?
    public let supportedIdCards: [String]?
}

public func encodeStepDefinitionsToJson(data: [StepDefinitions]) -> String {
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(data)
        return String(data: jsonData, encoding: .utf8) ?? ""
    } catch {
        return "\(error.localizedDescription)"
    }
}
