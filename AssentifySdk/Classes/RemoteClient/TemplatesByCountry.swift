//
//  TemplatesByCountry.swift
//  AssentifyDemoApp
//
//  Created by TariQ on 21/02/2024.
//

import Foundation



public struct TemplatesByCountry :Codable{
    let name: String
    let sourceCountryCode: String
    let flag: String
    let templates: [Templates]
}

public struct KycDocumentDetails : Codable {
    let name: String
    let order:Int
    let templateProcessingKeyInformation: String
    
    public init(name: String,order:Int,templateProcessingKeyInformation:String)  {
        self.name = name
        self.order = order
        self.templateProcessingKeyInformation = templateProcessingKeyInformation
    }
}

public struct Templates : Codable {
    let id: Int
    let sourceCountryFlag: String
    let sourceCountryCode: String
    let kycDocumentType: String
    let sourceCountry: String
    let kycDocumentDetails: [KycDocumentDetails]
}



public func encodeTemplatesByCountryToJson(data: [TemplatesByCountry]) -> String {
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(data)
        return String(data: jsonData, encoding: .utf8) ?? ""
    } catch {
        return "\(error.localizedDescription)"
    }
}




