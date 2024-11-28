//
//  ViewController.swift
//  AssentifySdk
//
//  Created by TariQ on 05/31/2024.
//  Copyright (c) 2024 TariQ. All rights reserved.
//
import AssentifySdk

import UIKit

class ViewController: UIViewController , AssentifySdkDelegate,FaceMatchDelegate{
//    func onComplete(dataModel: IDResponseModel, order: Int) {
//                print("\(yellowColor)onComplete: extractedData")
//                if let extractedData = dataModel.iDExtractedModel?.extractedData {
//                    for (key, value) in extractedData {
//                        print("\(key): \(value)")
//                    }
//                } else {
//                    print("extractedData is nil")
//                }
//                print("\(yellowColor)onComplete: outputProperties")
//                if let extractedData = dataModel.iDExtractedModel?.outputProperties {
//                    for (key, value) in extractedData {
//                        print("\(key): \(value)")
//                    }
//                } else {
//                    print("extractedData is nil")
//                }
//                print("\(yellowColor)onComplete: transformedProperties")
//                if let extractedData = dataModel.iDExtractedModel?.transformedProperties {
//                    for (key, value) in extractedData {
//                        print("\(key): \(value)")
//                    }
//                } else {
//                    print("extractedData is nil")
//                }
//
//    }
//
//    func onWrongTemplate(dataModel: RemoteProcessingModel) {
//
//    }
//
//    func onComplete(dataModel: OtherResponseModel) {
//        print("\(yellowColor)onComplete: extractedData")
//        if let extractedData = dataModel.otherExtractedModel?.extractedData {
//            for (key, value) in extractedData {
//                print("\(key): \(value)")
//            }
//        } else {
//            print("extractedData is nil")
//        }
//        print("\(yellowColor)onComplete: outputProperties")
//        if let extractedData = dataModel.otherExtractedModel?.outputProperties {
//            for (key, value) in extractedData {
//                print("\(key): \(value)")
//            }
//        } else {
//            print("extractedData is nil")
//        }
//        print("\(yellowColor)onComplete: transformedProperties")
//        if let extractedData = dataModel.otherExtractedModel?.transformedProperties {
//            for (key, value) in extractedData {
//                print("\(key): \(value)")
//            }
//        } else {
//            print("extractedData is nil")
//        }
//        print("\(yellowColor)onComplete: additionalDetails")
//        if let extractedData = dataModel.otherExtractedModel?.additionalDetails {
//            for (key, value) in extractedData {
//                print("\(key): \(value)")
//            }
//        } else {
//            print("extractedData is nil")
//        }
//        print("\(yellowColor)onComplete: transformedDetails")
//        if let extractedData = dataModel.otherExtractedModel?.transformedDetails{
//            for (key, value) in extractedData {
//                print("\(key): \(value)")
//            }
//        } else {
//            print("extractedData is nil")
//        }
//    }
    
    func onComplete(dataModel: FaceResponseModel) {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let formattedDate = formatter.string(from: currentDate)
        print("\(yellowColor)onComplete: \(formattedDate)")
    }

 
    

    
  
    
//    func onComplete(dataModel: PassportResponseModel) {
//        print("\(yellowColor)onComplete: extractedData")
//        if let extractedData = dataModel.passportExtractedModel?.extractedData {
//            for (key, value) in extractedData {
//                print("\(key): \(value)")
//            }
//        } else {
//            print("extractedData is nil")
//        }
//        print("\(yellowColor)onComplete: outputProperties")
//        if let extractedData = dataModel.passportExtractedModel?.outputProperties {
//            for (key, value) in extractedData {
//                print("\(key): \(value)")
//            }
//        } else {
//            print("extractedData is nil")
//        }
//        print("\(yellowColor)onComplete: transformedProperties")
//        if let extractedData = dataModel.passportExtractedModel?.transformedProperties {
//            for (key, value) in extractedData {
//                print("\(key): \(value)")
//            }
//        } else {
//            print("extractedData is nil")
//        }
//
//    }

  
    


    
    func onError(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onError:")
    }
    
    
    func onEnvironmentalConditionsChange(brightness: Double, motion: MotionType) {
        
    }
    
    
    
    func onSend() {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = formatter.string(from: currentDate)
        print("\(yellowColor)onSend: \(formattedDate)")
        
    }
    
    func onRetry(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onRetry:" , dataModel)
    }
    
    
    
    
    
    
    
    
    let environmentalConditions = EnvironmentalConditions(
        enableDetect: true,
        enableGuide: true ,
        BRIGHTNESS_HIGH_THRESHOLD: 500.0,
        BRIGHTNESS_LOW_THRESHOLD: 0.0,
        PREDICTION_LOW_PERCENTAGE: 50.0,
        PREDICTION_HIGH_PERCENTAGE: 100.0,
        CustomColor: "#FFFFFF",
        HoldHandColor: "#FFC400"
    )
    
    
    
    
    private var assentifySdk :AssentifySdk?
    private var  scanPassport   :UIViewController?
    private var  scanOther   :UIViewController?
    private var  scanID   :UIViewController?
    private var  faceMatch   :FaceMatch?
    
    let yellowColor = "🔥 -> ";
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assentifySdk = AssentifySdk(
            apiKey: "7UXZBSN2CeGxamNnp9CluLJn7Bb55lJo2SjXmXqiFULyM245nZXGGQvs956Fy5a5s1KoC4aMp5RXju8w",
            tenantIdentifier: "4232e33b-1a90-4b74-94a4-08dcab07bc4d",
            interaction: "F0D1B6A7D863E9E4089B70EE5786D3D8DF90EE7BDD12BE315019E1F2FC0E875A",
            environmentalConditions: self.environmentalConditions,
            assentifySdkDelegate: self,
            processMrz: true,
            storeCapturedDocument: true,
            performLivenessDocument:  false,
            performLivenessFace:  true,
            storeImageStream: true,
            saveCapturedVideoID: true,
            saveCapturedVideoFace: true
        )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func onAssentifySdkInitError(message: String) {
        print("\(yellowColor)onAssentifySdkInitError:" , message)
    }
    
    func onAssentifySdkInitSuccess(configModel: ConfigModel) {
        print("\(yellowColor)onAssentifySdkInitSuccess:" , configModel)
        print("\(yellowColor)onAssentifySdkInitSuccess:" , configModel.blockIdentifier)
        print("\(yellowColor)onAssentifySdkInitSuccess:" , configModel.tenantIdentifier)
        print("\(yellowColor)onAssentifySdkInitSuccess:" , configModel.blockIdentifier)
        var templates = assentifySdk?.getTemplates();
        
        templates?.forEach(){item in
            print("\(yellowColor)Name:" , item.name)
            item.templates.forEach(){item2 in
                print("\(yellowColor)Templates:" , item2.kycDocumentType)
                print("\(yellowColor)Templates:" , item2.id)
                print("\(yellowColor)Templates:" , item2.kycDocumentDetails.first)
                print("\(yellowColor)Templates:" ,item2.kycDocumentDetails.last)
                
                
            }
        }
        
        DispatchQueue.main.async {
            
            /* PASSPORT */
            
//            self.scanPassport =  self.assentifySdk?.startScanPassport(scanPassportDelegate: self,language: Language.Korean)
//                        self.addChild(  self.scanPassport!)
//                        self.view.addSubview(  self.scanPassport!.view)
//                        self.scanPassport!.view.translatesAutoresizingMaskIntoConstraints = false
//                        NSLayoutConstraint.activate([
//                            self.scanPassport!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                            self.scanPassport!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                            self.scanPassport!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                            self.scanPassport!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//                        ])
//                        self.scanPassport!.didMove(toParent: self)
//
//
            
            /* OTHER */
            
//                                    self.scanOther =  self.assentifySdk?.startScanOthers(scanOtherDelegate: self);
//                                    self.addChild(  self.scanOther!)
//                                    self.view.addSubview(  self.scanOther!.view)
//                                    self.scanOther!.view.translatesAutoresizingMaskIntoConstraints = false
//                                    NSLayoutConstraint.activate([
//                                        self.scanOther!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                                        self.scanOther!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                                        self.scanOther!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                                        self.scanOther!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//                                    ])
//                                    self.scanOther!.didMove(toParent: self)
            
            
            
            /* ID */
//
//                                               let data = [
//                                                    KycDocumentDetails(
//                                                    name: "", order: 0, templateProcessingKeyInformation: "75b683bb-eb81-4965-b3f0-c5e5054865e7",  templateSpecimen:""),
//                                                    KycDocumentDetails(
//                                                    name: "", order: 1, templateProcessingKeyInformation: "eae46fac-1763-4d31-9acc-c38d29fe56e4",  templateSpecimen:""),
//                                                ]
//
//                                                 self.scanID =  self.assentifySdk?.startScanID(scanIDCardDelegate: self,kycDocumentDetails: data,language: Language.English)
//
//                                                self.addChild(self.scanID!)
//                                                self.view.addSubview(self.scanID!.view)
//                                                self.scanID!.view.translatesAutoresizingMaskIntoConstraints = false
//                                                NSLayoutConstraint.activate([
//                                                    self.scanID!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                                                    self.scanID!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                                                    self.scanID!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                                                    self.scanID!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//                                                ])
//                                                self.scanID!.didMove(toParent: self)
            
            
            
            /* FaceMatch   */
            if let imageUrl = URL(string: "https://storagetestassentify.blob.core.windows.net/userfiles/318e2ca7-fde8-4c47-bbcc-0c94b905630f/f7cd52fa-9a2b-40c1-b5b6-3fb4d3cb9e7b/fead2692dd9e48dfa6e96e98f201fe56/traceIdentifier/FaceMatchWithImage/comparedWith.jpeg") {
                if let base64String = self.imageToBase64(from: imageUrl) {
                    self.faceMatch =  self.assentifySdk?.startFaceMatch(faceMatchDelegate: self, secondImage:base64String,showCountDown:false)
                    self.addChild( self.faceMatch!)
                    self.view.addSubview( self.faceMatch!.view)
                    self.faceMatch!.view.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        self.faceMatch!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                        self.faceMatch!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                        self.faceMatch!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                        self.faceMatch!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                    ])

                    self.faceMatch!.didMove(toParent: self)
                }
           }
            //
            //            let request = [
            //                    LanguageTransformationModel(languageTransformationEnum: LanguageTransformationEnum.Translation, key: "Date", value: "١١/٢/١٩٩٩", language: Language.English, dataType: DataType.Date)
            //                ]
            //
            //            self.assentifySdk?.languageTransformation(languageTransformationDelegate: self, language: Language.Arabic, languageTransformationData: request)
            
            
            
        }
    }
    
    
    func onLivenessUpdate(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onLivenessUpdate:")
    }
    func imageToBase64(from url: URL) -> String? {
        // Download image from URL
        guard let imageData = try? Data(contentsOf: url) else {
            print("Failed to download image from URL")
            return nil
        }
        
        // Convert image data to base64
        let base64String = imageData.base64EncodedString()
        
        return base64String
    }
}

