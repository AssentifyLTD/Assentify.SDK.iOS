//
//  ViewController.swift
//  AssentifySdk
//
//  Created by TariQ on 05/31/2024.
//  Copyright (c) 2024 TariQ. All rights reserved.
//
import AssentifySdk

import UIKit

class ViewController: UIViewController , AssentifySdkDelegate,ScanQrDelegate{
    func onStartQrScan() {
        print("\(yellowColor)onStartQrScan:")
    }
    
    func onErrorQrScan(message: String) {
        print("\(yellowColor)onErrorQrScan:")
    }
    
    func onCompleteQrScan(dataModel: IDResponseModel) {
                        if let extractedData = dataModel.iDExtractedModel?.extractedData {
                            for (key, value) in extractedData {
                                print("\(key): \(value)")
                            }
                        } else {
                            print("extractedData is nil")
                        }
                        print("\(yellowColor)onComplete: outputProperties")
                        if let extractedData = dataModel.iDExtractedModel?.outputProperties {
                            for (key, value) in extractedData {
                                print("\(key): \(value)")
                            }
                        } else {
                            print("extractedData is nil")
                        }
                        print("\(yellowColor)onComplete: transformedProperties")
                        if let extractedData = dataModel.iDExtractedModel?.transformedProperties {
                            for (key, value) in extractedData {
                                print("\(key): \(value)")
                            }
                        } else {
                            print("extractedData is nil")
                        }
    }
    
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
////
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
//
//    func onComplete(dataModel: FaceResponseModel) {
//        let currentDate = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
//        let formattedDate = formatter.string(from: currentDate)
//        print("\(yellowColor)onComplete: \(formattedDate)")
//        print("\(yellowColor)onComplete: ",dataModel.faceExtractedModel?.baseImageFace)
//        print("\(yellowColor)onComplete: ",dataModel.faceExtractedModel?.secondImageFace)
//    }

 
    

    
  
    
//    func onComplete(dataModel: PassportResponseModel) {
//        self.scanPassport?.stopScanning();
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
    
   
    
    func onEnvironmentalConditionsChange(brightnessEvents: BrightnessEvents, motion: MotionType, zoom: ZoomType) {
        
    }
    
    func onCurrentLiveMoveChange(activeLiveEvents: ActiveLiveEvents) {
     // print("\(yellowColor)onCurrentLiveMoveChange " + activeLiveEvents.rawValue.description)
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
        enableGuide: true,
        CustomColor: "#FFFFFF",
        HoldHandColor: "#FFC400"
    )
    
    
    
    
    private var assentifySdk :AssentifySdk?
    private var  scanPassport   :ScanPassport?
    private var  scanOther   :UIViewController?
    private var  scanID   :UIViewController?
    private var  scanQr   :UIViewController?
    private var  faceMatch   :FaceMatch?
    private var  countdownLabel = UILabel()
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
            performActiveLivenessFace: true,
            performPassiveLivenessFace:  true,
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
        
        configModel.stepMap.forEach(){item in
            print("\(yellowColor)Name:" , item.stepDefinition)
            print("\(yellowColor)Name:" , item.id)
            
        }
        
        DispatchQueue.main.async {
            
         
            self.countdownLabel.font = UIFont.boldSystemFont(ofSize: 40)
            self.countdownLabel.textAlignment = .center
            self.countdownLabel.backgroundColor = UIColor.clear
            self.countdownLabel.translatesAutoresizingMaskIntoConstraints = false
          
            
            /* PASSPORT */
//            
//            self.scanPassport =  self.assentifySdk?.startScanPassport(scanPassportDelegate: self,stepId: 2684)
//            self.addChild(self.scanPassport!)
//            self.view.addSubview(  self.scanPassport!.view)
//            self.scanPassport!.view.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                            self.scanPassport!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                            self.scanPassport!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                            self.scanPassport!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                            self.scanPassport!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            ])
//            self.scanPassport!.didMove(toParent: self)


            
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

//                                               let data = [
//                                                    KycDocumentDetails(
//                                                    name: "", order: 0, templateProcessingKeyInformation: "75b683bb-eb81-4965-b3f0-c5e5054865e7",  templateSpecimen:""),
//                                                    KycDocumentDetails(
//                                                    name: "", order: 1, templateProcessingKeyInformation: "eae46fac-1763-4d31-9acc-c38d29fe56e4",  templateSpecimen:""),
//                                                ]
//
//            self.scanID =  self.assentifySdk?.startScanID(scanIDCardDelegate: self,kycDocumentDetails: data,language: Language.English,stepId:4337)
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
//            if let imageUrl = URL(string: "https://storagetestassentify.blob.core.windows.net/userfiles/318e2ca7-fde8-4c47-bbcc-0c94b905630f/f7cd52fa-9a2b-40c1-b5b6-3fb4d3cb9e7b/fead2692dd9e48dfa6e96e98f201fe56/traceIdentifier/FaceMatchWithImage/comparedWith.jpeg") {
//                if let base64String = self.imageToBase64(from: imageUrl) {
//                    self.faceMatch =  self.assentifySdk?.startFaceMatch(faceMatchDelegate: self, secondImage:base64String,showCountDown:true)
//                    self.addChild( self.faceMatch!)
//                    self.view.addSubview( self.faceMatch!.view)
//                    self.faceMatch!.view.translatesAutoresizingMaskIntoConstraints = false
//                    NSLayoutConstraint.activate([
//                        self.faceMatch!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                        self.faceMatch!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                        self.faceMatch!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                        self.faceMatch!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//                    ])
//
//                    self.faceMatch!.didMove(toParent: self)
//                }
//                }
            
            
            
            //
            //            let request = [
            //                    LanguageTransformationModel(languageTransformationEnum: LanguageTransformationEnum.Translation, key: "Date", value: "١١/٢/١٩٩٩", language: Language.English, dataType: DataType.Date)
            //                ]
            //
            //            self.assentifySdk?.languageTransformation(languageTransformationDelegate: self, language: Language.Arabic, languageTransformationData: request)
            
            /* qr */

                                               let data = [
                                                    KycDocumentDetails(
                                                    name: "", order: 0, templateProcessingKeyInformation: "a1ec8a0d-067c-4ce1-8420-820d7789cf83",  templateSpecimen:"",hasQrCode: true),
                                                ]

            self.scanQr =  self.assentifySdk?.startScanQr(scanQrDelegate: self,kycDocumentDetails: data,stepId:2684)
            
                                                            self.addChild(self.scanQr!)
                                                            self.view.addSubview(self.scanQr!.view)
                                                            self.scanQr!.view.translatesAutoresizingMaskIntoConstraints = false
                                                            NSLayoutConstraint.activate([
                                                                self.scanQr!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                                                                self.scanQr!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                                                self.scanQr!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                                                                self.scanQr!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                                                            ])
                                                            self.scanQr!.didMove(toParent: self)
            
        }
    }
    
    func onEnvironmentalConditionsChange(brightnessEvents: BrightnessEvents, motion: MotionType, faceEvents: FaceEvents, zoom: ZoomType) {
        DispatchQueue.main.async {
            
            self.countdownLabel.removeFromSuperview()
            self.view.addSubview(self.countdownLabel)

            NSLayoutConstraint.activate([
                self.countdownLabel.topAnchor.constraint(equalTo:  self.view.topAnchor, constant: 20),
                self.countdownLabel.centerXAnchor.constraint(equalTo:  self.view.centerXAnchor)
            ])
            
            switch faceEvents {
            case .ROLL_LEFT:
                self.countdownLabel.text = "ROLL_LEFT"
            case .ROLL_RIGHT:
                self.countdownLabel.text = "ROLL_RIGHT"
            case .YAW_LEFT:
                self.countdownLabel.text = "YAW_LEFT"
            case .YAW_RIGHT:
                self.countdownLabel.text = "YAW_RIGHT"
            case .PITCH_UP:
                self.countdownLabel.text = "PITCH_UP"
            case .PITCH_DOWN:
                self.countdownLabel.text = "PITCH_DOWN"
            case .GOOD:
                self.countdownLabel.text = "GOOD"
            case .NO_DETECT:
                self.countdownLabel.text = "NO_DETECT"
            }
            
            
          
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

