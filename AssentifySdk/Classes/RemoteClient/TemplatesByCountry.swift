//
//  TemplatesByCountry.swift
//  AssentifyDemoApp
//
//  Created by TariQ on 21/02/2024.
//

import Foundation



public struct TemplatesByCountry :Codable{
    public  let name: String
    public  let sourceCountryCode: String
    public  let flag: String
    public  let templates: [Templates]
}

public struct KycDocumentDetails : Codable {
    public   let name: String
    public   let order:Int
    public   let templateProcessingKeyInformation: String
    public   let templateSpecimen: String
    
    public init(name: String,order:Int,templateProcessingKeyInformation:String,templateSpecimen:String)  {
        self.name = name
        self.order = order
        self.templateSpecimen = templateSpecimen
        self.templateProcessingKeyInformation = templateProcessingKeyInformation
    }
}

public struct Templates : Codable {
    public let id: Int
    public let sourceCountryFlag: String
    public let sourceCountryCode: String
    public let kycDocumentType: String
    public let sourceCountry: String
    public let kycDocumentDetails: [KycDocumentDetails]
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




