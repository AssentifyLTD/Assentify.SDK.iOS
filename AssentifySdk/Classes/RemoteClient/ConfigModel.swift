

import Foundation
public struct ConfigModel: Codable {
    let stepId: Int
    let tenantIdentifier: String
    let blockIdentifier: String
    let instanceId: String
    let flowInstanceId: String
    let flowIdentifier: String
    let instanceHash: String
    let flowName: String
    let stepDefinitions: [StepDefinitions]

}

public struct StepDefinitions: Codable {
    let stepId: Int
    let stepDefinition: String
    let customization: Customization
    let outputProperties: [OutputProperties]
}

public struct OutputProperties: Codable {
    let id: Int
    let key: String
    let displayName: String
    let isRequired: Bool
    let isExcluded: Bool
    let type: Int
}

public struct Customization: Codable {
    let processMrz: Bool?
    let storeCapturedDocument: Bool?
    let performLivenessDetection: Bool?
    let storeImageStream: Bool?
    let saveCapturedVideo: Bool?
    let identificationDocuments: [IdentificationDocuments]?
}



public struct IdentificationDocuments : Codable{
    let key: String?
    let selectedCountries: [String]?
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
