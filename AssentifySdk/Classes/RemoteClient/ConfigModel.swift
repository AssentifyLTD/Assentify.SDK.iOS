

import Foundation
public struct ConfigModel: Codable {
    public let stepId: Int
    public let tenantIdentifier: String
    public let blockIdentifier: String
    public let instanceId: String
    public let applicationId: String
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
    public  let inputProperties: [InputProperty]
}

public struct StepMap: Codable {
    public let id: Int
    public let stepType: Int
    public let stepName: String
    public let stepDefinition: String
    public let parentStepId: Int?
    public let numberOfBranches: Int?
    public let isVirtual: Bool
    public let  branches: [[StepMap]]?
}



public struct OutputProperties: Codable {
    public let id: Int
    public let key: String
    public let keyIdentifier: String?
    public  let displayName: String
    public  let isRequired: Bool?
    public let isExcluded: Bool?
    public  let type: Int?
}


public struct StepTypeDto: Codable {
    var id: Int
}

public struct Customization: Codable {
    public  let header: String?
    public  let processMrz: Bool?
    public let storeCapturedDocument: Bool?
    public let performLivenessDetection: Bool?
    public let documentLiveness: Bool?
    public let storeImageStream: Bool?
    public let saveCapturedVideo: Bool?
    public let showResultPage: Bool?
    public  let outputProperties: [OutputProperties]
    public let  identificationDocuments: [IdentificationDocuments]?
    public  let branches: [Branch]?
    public  let stepTypeDto: StepTypeDto
}

public struct Branch: Codable {
    public  let branchIndex: Int
    public let conditions: [Condition]
}

public struct Condition: Codable {

    public let label: String?
    public let inputPropertyKey: String
    public let conditionOperator: Int?   // 1 AND, 2 OR
    public let `operator`: Int           // backticks because "operator" is reserved in Swift
    public let useAge: Bool?
    public let value: String?

}


public struct InputProperty: Codable {
    
    public let id: Int
    public let sourcePropertyId: Int
    public let sourceStepId: Int
    public let sourceKey: String
    public let targetPropertyId: Int
    public let targetStepId: Int
    public let targetKey: String
    public let isDeleted: Bool
    
    public init(
        id: Int,
        sourcePropertyId: Int,
        sourceStepId: Int,
        sourceKey: String,
        targetPropertyId: Int,
        targetStepId: Int,
        targetKey: String,
        isDeleted: Bool
    ) {
        self.id = id
        self.sourcePropertyId = sourcePropertyId
        self.sourceStepId = sourceStepId
        self.sourceKey = sourceKey
        self.targetPropertyId = targetPropertyId
        self.targetStepId = targetStepId
        self.targetKey = targetKey
        self.isDeleted = isDeleted
    }
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
