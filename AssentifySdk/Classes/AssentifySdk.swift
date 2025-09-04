

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
    private var performLivenessDocument: Bool?
    private var performActiveLivenessFace: Bool?
    private var performPassiveLivenessFace: Bool?
    private var storeImageStream: Bool?
    private var saveCapturedVideoID: Bool?
    private var saveCapturedVideoFace: Bool?
    private var isKeyValid: Bool = false
    private var configModel: ConfigModel?
    private var stepID: Int = -1;
    private var scanID: ScanIDCard?;
    private var templates: [TemplatesByCountry]?;
    
    

    
    public init(apiKey: String, tenantIdentifier: String, interaction: String, environmentalConditions: EnvironmentalConditions?, assentifySdkDelegate: AssentifySdkDelegate?, processMrz: Bool? = nil, storeCapturedDocument: Bool? = nil,performActiveLivenessFace: Bool? = nil,storeImageStream: Bool? = nil, saveCapturedVideoID: Bool? = nil, saveCapturedVideoFace: Bool? = nil) {
        self.apiKey = apiKey
        self.tenantIdentifier = tenantIdentifier
        self.interaction = interaction
        self.environmentalConditions = environmentalConditions
        self.assentifySdkDelegate = assentifySdkDelegate
        self.processMrz = processMrz
        self.storeCapturedDocument = storeCapturedDocument
        self.performActiveLivenessFace = performActiveLivenessFace
        self.storeImageStream = storeImageStream
        self.saveCapturedVideoID = saveCapturedVideoID
        self.saveCapturedVideoFace = saveCapturedVideoFace
        if apiKey.isEmpty {
            print("AssentifySdk Init Error: ApiKey must not be blank or nil")
        }
        if interaction.isEmpty {
            print("AssentifySdk Init Error: Interaction must not be blank or nil")
        }
        if tenantIdentifier.isEmpty {
            print("AssentifySdk Init Error: TenantIdentifier must not be blank or nil")
        }
        if environmentalConditions == nil {
            print("AssentifySdk Init Error: EnvironmentalConditions must not be nil")
        }
        if assentifySdkDelegate == nil {
            print("AssentifySdk Init Error: assentifySdkDelegate must not be nil")
        }
        if !apiKey.isEmpty && !interaction.isEmpty && !tenantIdentifier.isEmpty {
            validateKey()
        }

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
                        if self.performLivenessDocument == nil {
                            self.performLivenessDocument = item.customization.documentLiveness
                        }
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
                        if self.performPassiveLivenessFace == nil {
                            self.performPassiveLivenessFace = item.customization.performLivenessDetection
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
                if self.performLivenessDocument == nil ||  self.processMrz == nil || self.storeCapturedDocument == nil || self.saveCapturedVideoID == nil {
                    self.assentifySdkDelegate?.onAssentifySdkInitError(message:"Please Configure The IdentificationDocumentCapture { performLivenessDocument , processMrz , storeCapturedDocument , saveCapturedVideo }")
                }
                if self.performPassiveLivenessFace == nil || self.storeImageStream == nil || self.saveCapturedVideoFace == nil {
                    self.assentifySdkDelegate?.onAssentifySdkInitError(message:"Please Configure The FaceImageAcquisition { performLivenessFace , storeImageStream , saveCapturedVideo }")
                }
                self.getTemplatesByCountry();
               
            case .failure(let error):
                self.assentifySdkDelegate?.onAssentifySdkInitError(message:error.localizedDescription);
            }
        }
    }
    
    public func startScanPassport(scanPassportDelegate:ScanPassportDelegate,language: String = Language.NON,stepId: Int? = nil)->ScanPassport?{
        if(isKeyValid){
            let scanPassport = ScanPassport(
                configModel:self.configModel,
                environmentalConditions:self.environmentalConditions!,
                apiKey:self.apiKey,
                processMrz: self.processMrz!,
                performLivenessDocument: self.performLivenessDocument!,
                performLivenessFace:  self.performPassiveLivenessFace!,
                saveCapturedVideoID:self.saveCapturedVideoID!,
                storeCapturedDocument:self.storeCapturedDocument!,
                storeImageStream:self.storeImageStream!,
                scanPassportDelegate :scanPassportDelegate,
                language:language,
                isManual: self.isManual()
                
            )
            scanPassport.setStepId(stepId)
            return scanPassport;

        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
    
    public func startScanNfc(scanNfcDelegate:ScanNfcDelegate,language: String = Language.NON,stepId: Int? = nil)->ScanNfc?{
        if(isKeyValid){
            let scanNfc = ScanNfc(
                configModel:self.configModel,
                apiKey:self.apiKey,
                language:language,
                scanNfcDelegate:scanNfcDelegate
            )
            return scanNfc;

        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
    
    
    public func startScanOthers(scanOtherDelegate:ScanOtherDelegate,language: String = Language.NON,stepId: Int? = nil)->ScanOther?{
        if(isKeyValid){
            let scanOther = ScanOther(
                configModel:self.configModel,
                environmentalConditions:self.environmentalConditions!,
                apiKey:self.apiKey,
                processMrz: self.processMrz!,
                performLivenessDocument: self.performLivenessDocument!,
                performLivenessFace:  self.performPassiveLivenessFace!,
                saveCapturedVideoID:self.saveCapturedVideoID!,
                storeCapturedDocument:self.storeCapturedDocument!,
                storeImageStream:self.storeImageStream!,
                scanOtherDelegate :scanOtherDelegate,
                language:language,
                isManual: self.isManual()

                
            )
            scanOther.setStepId(stepId)
            return scanOther;

        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
    
    
    public func startScanID(scanIDCardDelegate:ScanIDCardDelegate, kycDocumentDetails:[KycDocumentDetails],language: String = Language.NON,stepId: Int? = nil)->ScanIDCard?{
        if(isKeyValid){
             scanID = ScanIDCard(
                configModel:self.configModel,
                environmentalConditions:self.environmentalConditions!,
                apiKey:self.apiKey,
                processMrz: self.processMrz!,
                performLivenessDocument: self.performLivenessDocument!,
                performLivenessFace:  self.performPassiveLivenessFace!,
                saveCapturedVideoID:self.saveCapturedVideoID!,
                storeCapturedDocument:self.storeCapturedDocument!,
                storeImageStream:self.storeImageStream!,
                scanIDCardDelegate :scanIDCardDelegate,
                kycDocumentDetails:kycDocumentDetails,
                language:language,
                isManual: self.isManual()
                
            )
            scanID!.setStepId(stepId)
            return scanID;

        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
   
    
    public func startScanQr(scanQrDelegate:ScanQrDelegate, kycDocumentDetails:[KycDocumentDetails],language: String = Language.NON,stepId: Int? = nil)->ScanQr?{
        if(isKeyValid){
           var  scanQr = ScanQr(
                configModel:self.configModel,
                environmentalConditions:self.environmentalConditions!,
                apiKey:self.apiKey,
                processMrz: self.processMrz!,
                performLivenessDocument: self.performLivenessDocument!,
                performLivenessFace:  self.performPassiveLivenessFace!,
                saveCapturedVideoID:self.saveCapturedVideoID!,
                storeCapturedDocument:self.storeCapturedDocument!,
                storeImageStream:self.storeImageStream!,
                scanQrDelegate :scanQrDelegate,
                kycDocumentDetails:kycDocumentDetails,
                language:language
                
            )
            scanQr.setStepId(stepId)
            return scanQr;

        }else{
            NSException(name: NSExceptionName(rawValue: "Exception"), reason: "Invalid Keys", userInfo: nil).raise()
        }
        return nil;
    }
  
    
    
    public func startFaceMatch(faceMatchDelegate:FaceMatchDelegate,secondImage:String,showCountDown:Bool = true,stepId: Int? = nil)->FaceMatch?{
        if(isKeyValid){
            let  faceMatch = FaceMatch(
                configModel:self.configModel,
                environmentalConditions:self.environmentalConditions!,
                apiKey:self.apiKey,
                processMrz: self.processMrz!,
                performLivenessDocument: self.performLivenessDocument!,
                performLivenessFace:  self.performActiveLivenessFace!,
                performPassiveLivenessFace:  self.performPassiveLivenessFace!,
                saveCapturedVideoID:self.saveCapturedVideoID!,
                storeCapturedDocument:self.storeCapturedDocument!,
                storeImageStream:self.storeImageStream!,
                faceMatchDelegate :faceMatchDelegate,
                secondImage :secondImage,
                showCountDown: showCountDown,
                isManual: self.isManual()
            );
            faceMatch.setStepId(stepId)
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
    
     func getTemplatesByCountry() {
        remoteGetTemplates() { result in
            switch result {
            case .success(let templates):
                var filteredList = self.filterBySourceCountryCode(dataList:templates )
                var templatesByCountry = [TemplatesByCountry]()

                for data in filteredList {
                   
                        let item = TemplatesByCountry(
                            id: data.id,
                            name: data.sourceCountry,
                            sourceCountryCode: data.sourceCountryCode,
                            flag: data.sourceCountryFlag,
                            templates: self.filterTemplatesCountryCode(dataList: templates, countryCode: data.sourceCountryCode)
                        )

                        templatesByCountry.append(item)
                    
                   
                }
                self.templates = self.filterToSupportedCountries(dataList: templatesByCountry)!
                self.assentifySdkDelegate?.onAssentifySdkInitSuccess(configModel: self.configModel!);
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
        var supportedIdCards: [String] = []
        
        for step in self.configModel!.stepDefinitions {
            if step.stepDefinition == "IdentificationDocumentCapture" {
                if let identificationDocuments = step.customization.identificationDocuments {
                    for docStep in identificationDocuments {
                        if docStep.key == "IdentificationDocument.IdCard" {
                            selectedCountries = docStep.selectedCountries!
                            supportedIdCards = docStep.supportedIdCards!
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
        
        
        var filteredListByCards = [TemplatesByCountry]()
          
        filteredList.forEach(){
            card in
            var selectedTemplates : [Templates] = [];
            card.templates.forEach(){cardTemplates in
                if supportedIdCards.contains(String(cardTemplates.id)) {
                    selectedTemplates.append(cardTemplates)
                }
            }
            filteredListByCards.append(TemplatesByCountry(
                id: card.id,
                name: card.name,
                sourceCountryCode: card.sourceCountryCode,
                flag: card.flag,
                templates: selectedTemplates))
        }
        
        

        return filteredListByCards
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
    
    public func getTemplates() -> [TemplatesByCountry] {
        return self.templates!
    }
    
    public func isManual() -> Bool {
           let totalRamGB = getTotalRAMInGB()
           let cores = ProcessInfo.processInfo.processorCount
           
           print("Total RAM: \(totalRamGB) GB")
           print("CPU Cores: \(cores)")
           
        return (totalRamGB < self.environmentalConditions!.minRam) || (cores < self.environmentalConditions!.minCPUCores)
       }
       
    private  func getTotalRAMInGB() -> UInt64 {
           let physicalMemory = ProcessInfo.processInfo.physicalMemory
           return physicalMemory / (1024 * 1024 * 1024)
    }

}
