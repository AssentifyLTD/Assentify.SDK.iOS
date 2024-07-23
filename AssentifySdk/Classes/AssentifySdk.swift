

import Foundation
import UIKit
public class AssentifySdk {
    private let apiKey: String
    private let tenantIdentifier: String
    private let interaction: String
    private let environmentalConditions: EnvironmentalConditions?
    private let assentifySdkDelegate : AssentifySdkDelegate?
    private var processMrz: Bool?
    private var storeCapturedDocument: Bool?
    private var performLivenessDetection: Bool?
    private var storeImageStream: Bool?
    private var saveCapturedVideoID: Bool?
    private var saveCapturedVideoFace: Bool?
    private var isKeyValid: Bool = false
    private var configModel: ConfigModel?
    private var stepID: Int = -1;
    private var scanID: ScanIDCard?;
    
    

    
    public init(apiKey: String, tenantIdentifier: String, interaction: String, environmentalConditions: EnvironmentalConditions?, assentifySdkDelegate: AssentifySdkDelegate?, processMrz: Bool? = nil, storeCapturedDocument: Bool? = nil, performLivenessDetection: Bool? = nil, storeImageStream: Bool? = nil, saveCapturedVideoID: Bool? = nil, saveCapturedVideoFace: Bool? = nil) {
        self.apiKey = apiKey
        self.tenantIdentifier = tenantIdentifier
        self.interaction = interaction
        self.environmentalConditions = environmentalConditions
        self.assentifySdkDelegate = assentifySdkDelegate
        self.processMrz = processMrz
        self.storeCapturedDocument = storeCapturedDocument
        self.performLivenessDetection = performLivenessDetection
        self.storeImageStream = storeImageStream
        self.saveCapturedVideoID = saveCapturedVideoID
        self.saveCapturedVideoFace = saveCapturedVideoFace
        guard !apiKey.isEmpty else { fatalError("ApiKey must not be blank or null") }
        guard !interaction.isEmpty else { fatalError("Interaction must not be blank or null") }
        guard !tenantIdentifier.isEmpty else { fatalError("TenantIdentifier must not be blank or null") }
        guard environmentalConditions != nil else { fatalError("EnvironmentalConditions must not be null") }
        guard assentifySdkDelegate != nil else { fatalError("AssentifySdkCallback must not be null") }
        
        validateKey()
    }
 

    private func validateKey() {
        remoteValidateKey(apiKey: apiKey, tenantIdentifier: tenantIdentifier, agentSource: "SDK") { result in
            switch result {
            case .success(let validateKeyModel):
                self.getStart()
            case .failure(let error):
                self.assentifySdkDelegate?.onAssentifySdkInitError(message: "Invalid Keys");
            }
        }
    }
    
    private func getStart() {
        remoteGetStart(interActionId: interaction) { result in
            switch result {
            case .success(let configModel):
                self.isKeyValid  = true;
                self.configModel = configModel;
                configModel.stepDefinitions.forEach { item in
                    if item.stepDefinition == "IdentificationDocumentCapture" {
                        if self.processMrz == nil {
                            self.processMrz = item.customization.processMrz
                        }
                        if self.storeCapturedDocument == nil {
                            self.storeCapturedDocument = item.customization.storeCapturedDocument
                        }
                        if self.saveCapturedVideoID == nil {
                            self.saveCapturedVideoID = item.customization.saveCapturedVideo
                        }
                    }
                    if item.stepDefinition == "FaceImageAcquisition" {
                        if self.performLivenessDetection == nil {
                            self.performLivenessDetection = item.customization.performLivenessDetection
                        }
                        if self.storeImageStream == nil {
                            self.storeImageStream = item.customization.storeImageStream
                        }
                        if self.saveCapturedVideoFace == nil {
                            self.saveCapturedVideoFace = item.customization.saveCapturedVideo
                        }
                    }
                    if item.stepDefinition == "ContextAwareSigning" {
                        self.stepID = item.stepId
                    }
                }
                if self.processMrz == nil || self.storeCapturedDocument == nil || self.saveCapturedVideoID == nil {
                    self.assentifySdkDelegate?.onAssentifySdkInitError(message:"Please Configure The IdentificationDocumentCapture { processMrz , storeCapturedDocument , saveCapturedVideo }")
                }
                if self.performLivenessDetection == nil || self.storeImageStream == nil || self.saveCapturedVideoFace == nil {
                    self.assentifySdkDelegate?.onAssentifySdkInitError(message:"Please Configure The FaceImageAcquisition { performLivenessDetection , storeImageStream , saveCapturedVideo }")
                }
                self.assentifySdkDelegate?.onAssentifySdkInitSuccess(configModel: configModel);
            case .failure(let error):
                self.assentifySdkDelegate?.onAssentifySdkInitError(message:error.localizedDescription);
            }
        }
    }
    
    public func startScanPassport(scanPassportDelegate:ScanPassportDelegate,language: String = Language.NON)->UIViewController?{
        if(isKeyValid){
            let scanPassport = ScanPassport(
                configModel:self.configModel,
                environmentalConditions:self.environmentalConditions!,
                apiKey:self.apiKey,
                processMrz: self.processMrz!,
                performLivenessDetection: self.performLivenessDetection!,
                saveCapturedVideoID:self.saveCapturedVideoID!,
                storeCapturedDocument:self.storeCapturedDocument!,
                storeImageStream:self.storeImageStream!,
                scanPassportDelegate :scanPassportDelegate,
                language:language
                
            )
            return scanPassport;

        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
    
    public func startScanOthers(scanOtherDelegate:ScanOtherDelegate,language: String = Language.NON)->UIViewController?{
        if(isKeyValid){
            let scanOther = ScanOther(
                configModel:self.configModel,
                environmentalConditions:self.environmentalConditions!,
                apiKey:self.apiKey,
                processMrz: self.processMrz!,
                performLivenessDetection: self.performLivenessDetection!,
                saveCapturedVideoID:self.saveCapturedVideoID!,
                storeCapturedDocument:self.storeCapturedDocument!,
                storeImageStream:self.storeImageStream!,
                scanOtherDelegate :scanOtherDelegate,
                language:language

                
            )
            return scanOther;

        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
    
    
    public func startScanID(scanIDCardDelegate:ScanIDCardDelegate, kycDocumentDetails:[KycDocumentDetails],language: String = Language.NON)->UIViewController?{
        if(isKeyValid){
             scanID = ScanIDCard(
                configModel:self.configModel,
                environmentalConditions:self.environmentalConditions!,
                apiKey:self.apiKey,
                processMrz: self.processMrz!,
                performLivenessDetection: self.performLivenessDetection!,
                saveCapturedVideoID:self.saveCapturedVideoID!,
                storeCapturedDocument:self.storeCapturedDocument!,
                storeImageStream:self.storeImageStream!,
                scanIDCardDelegate :scanIDCardDelegate,
                kycDocumentDetails:kycDocumentDetails,
                language:language
                
            )
            return scanID;

        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
   
  
    
    
    public func startFaceMatch(faceMatchDelegate:FaceMatchDelegate,secondImage:String)->UIViewController?{
        if(isKeyValid){
            let  faceMatch = FaceMatch(
                configModel:self.configModel,
                environmentalConditions:self.environmentalConditions!,
                apiKey:self.apiKey,
                processMrz: self.processMrz!,
                performLivenessDetection: self.performLivenessDetection!,
                saveCapturedVideoID:self.saveCapturedVideoID!,
                storeCapturedDocument:self.storeCapturedDocument!,
                storeImageStream:self.storeImageStream!,
                faceMatchDelegate :faceMatchDelegate,
                secondImage :secondImage
            );
            return faceMatch;

        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
    
    
    public func startContextAwareSigning(contextAwareDelegate:ContextAwareDelegate) -> ContextAwareSigning?{
        if(isKeyValid){
            return ContextAwareSigning(
                configModel:configModel,
                apiKey:apiKey,
                stepID:stepID,
                tenantIdentifier:tenantIdentifier,
                interaction:interaction,
                contextAwareDelegate:contextAwareDelegate
            );
        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
    
    
    
    public func startSubmitData(
           submitDataDelegate: SubmitDataDelegate,
           submitRequestModel: [SubmitRequestModel]
       ) -> SubmitData? {
           if (isKeyValid) {
               return SubmitData(apiKey: apiKey,
                                 submitDataDelegate:submitDataDelegate,
                                 submitRequestModel:submitRequestModel,
                                 configModel:configModel!)
           } else{
               NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
           }
           return nil;
       }
    
    public func getTemplates() {
        remoteGetTemplates() { result in
            switch result {
            case .success(let templates):
                var filteredList = self.filterBySourceCountryCode(dataList:templates )
                var templatesByCountry = [TemplatesByCountry]()

                for data in filteredList {
                   
                        let item = TemplatesByCountry(
                            name: data.sourceCountry,
                            sourceCountryCode: data.sourceCountryCode,
                            flag: data.sourceCountryFlag,
                            templates: self.filterTemplatesCountryCode(dataList: templates, countryCode: data.sourceCountryCode)
                        )

                        templatesByCountry.append(item)
                    
                   
                }
                self.assentifySdkDelegate?.onHasTemplates(templates: self.filterToSupportedCountries(dataList: templatesByCountry)! )
            case .failure(_):
                print("Get Templates Error")
            }
        }
    }
    
    func filterBySourceCountryCode(dataList: [Templates]) -> [Templates] {
        var filteredList = [Templates]()
        var uniqueSourceCountryCodes = [String]()
        
        for data in dataList {
                if !uniqueSourceCountryCodes.contains(data.sourceCountryCode) {
                    filteredList.append(data)
                    uniqueSourceCountryCodes.append(data.sourceCountryCode)
                }
        }
        return filteredList
    }

    func filterTemplatesCountryCode(dataList: [Templates], countryCode: String) -> [Templates] {
        var filteredList = [Templates]()
        
        for data in dataList {
                if data.sourceCountryCode == countryCode {
                    filteredList.append(data)
                }
        }
        return filteredList
    }
    
    func filterToSupportedCountries(dataList: [TemplatesByCountry]?) -> [TemplatesByCountry]? {
        var selectedCountries: [String] = []
        
        for step in self.configModel!.stepDefinitions {
            if step.stepDefinition == "IdentificationDocumentCapture" {
                if let identificationDocuments = step.customization.identificationDocuments {
                    for docStep in identificationDocuments {
                        if docStep.key == "IdentificationDocument.IdCard" {
                            selectedCountries = docStep.selectedCountries!
                        }
                    }
                }
            }
        }
        
        var filteredList = [TemplatesByCountry]()
        
        dataList?.forEach { data in
            if let foundCountry = selectedCountries.first(where: { $0 == data.sourceCountryCode }) {
                if !foundCountry.isEmpty {
                    filteredList.append(data)
                }
            }
        }
        
        if selectedCountries.isEmpty {
            return dataList
        }

        return filteredList
    }
    
    public func languageTransformation(
           languageTransformationDelegate: LanguageTransformationDelegate,
            language: String,
            languageTransformationData: [LanguageTransformationModel]
        ) {
            if (isKeyValid) {
                let transformed = LanguageTransformation(apiKey: apiKey,languageTransformationDelegate: languageTransformationDelegate)
                   transformed.languageTransformation(
                    langauge: language,
                    transformationModel: TransformationModel(languageTransformationModels: languageTransformationData)
                   )
            } else{
                NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
            }
        }

}
