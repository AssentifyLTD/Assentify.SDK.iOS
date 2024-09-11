//
//  ViewController.swift
//  AssentifySdk
//
//  Created by TariQ on 05/31/2024.
//  Copyright (c) 2024 TariQ. All rights reserved.
//
import AssentifySdk

import UIKit

class ViewController: UIViewController , AssentifySdkDelegate,ScanOtherDelegate{
    func onComplete(dataModel: OtherResponseModel) {
        
    }
    
//    func onComplete(dataModel: PassportResponseModel) {
//        
//    }
    
//    func onComplete(dataModel: IDResponseModel, order: Int) {
//        print("\(yellowColor)onComplete: " + (dataModel.iDExtractedModel?.description)! )
//
//    }
    


    func onWrongTemplate(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onWrongTemplate:" )
    }

//    func onComplete(dataModel: FaceResponseModel) {
//        print("\(yellowColor)onComplete: " + (dataModel.faceExtractedModel?.baseImageFace)! )
// 
//    }
//    
  
    

    // Restrict the view controller to portrait mode
   public  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    public  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    public   override var shouldAutorotate: Bool {
        return false
    }
    
    
    

    
    func onError(dataModel: RemoteProcessingModel) {
        
    }
    
    
    func onEnvironmentalConditionsChange(brightness: Double, motion: MotionType) {
     
    }
    
    
    
    func onSend() {
        print("\(yellowColor)onSend:")
        let textField = UITextField(frame: CGRect(x: 20, y: 100, width: 200, height: 30))
            textField.placeholder = "Enter text here"
            textField.borderStyle = .roundedRect
            textField.textAlignment = .left

        
            // Add UITextField as a subview
            self.view.addSubview(textField)
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
          CustomColor: "#61A03A",
          HoldHandColor: "#FFC400"
      )
    
   
    
    
    private var assentifySdk :AssentifySdk?
    private var  scanPassport   :UIViewController?
    private var  scanOther   :UIViewController?
    private var  scanID   :UIViewController?
    private var  faceMatch   :UIViewController?
    
    let yellowColor = "🔥 -> ";
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assentifySdk = AssentifySdk(
                apiKey: "NvyTlImKg8lgToRGICsIV5AYGwxgObA2DdJVfCxrXKJFHPnepy0Ur38sPyoT0FJWHEkxh8LJ8uBtO4X4sg",
                tenantIdentifier: "318e2ca7-fde8-4c47-bbcc-0c94b905630f",
                interaction: "CA7240AC8456E25F619B0A60CA0334FFFC7440AEF7514768419398ED044C6B9F",
                environmentalConditions: self.environmentalConditions,
                assentifySdkDelegate: self,
                processMrz: true,
                storeCapturedDocument: true,
                performLivenessDetection: false,
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
        assentifySdk?.getTemplates();
        
        var extractedInformation: [String: String] = [:]
        
        var submitRequestModel : [SubmitRequestModel] = []

        submitRequestModel.append(SubmitRequestModel(
                    stepId:1,
                   stepDefinition:"",
                   extractedInformation:extractedInformation
                   ))
        DispatchQueue.main.async {
            
            /* PASSPORT */
            
//            self.scanPassport =  self.assentifySdk?.startScanPassport(scanPassportDelegate: self)
//            self.addChild(  self.scanPassport!)
//            self.view.addSubview(  self.scanPassport!.view)
//            self.scanPassport!.view.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                self.scanPassport!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                self.scanPassport!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                self.scanPassport!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                self.scanPassport!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            ])
//            self.scanPassport!.didMove(toParent: self)
             
            
            
            /* OTHER */
         
            self.scanOther =  self.assentifySdk?.startScanOthers(scanOtherDelegate: self);
            self.addChild(  self.scanOther!)
            self.view.addSubview(  self.scanOther!.view)
            self.scanOther!.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.scanOther!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.scanOther!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.scanOther!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.scanOther!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
            self.scanOther!.didMove(toParent: self)
           
            
            
            /* ID */
          
//                       let data = [
//                            KycDocumentDetails(
//                                name: "", order: 0, templateProcessingKeyInformation: "75b683bb-eb81-4965-b3f0-c5e5054865e7", templateSpecimen: ""),
//                            KycDocumentDetails(
//                                name: "", order: 1, templateProcessingKeyInformation: "eae46fac-1763-4d31-9acc-c38d29fe56e4", templateSpecimen: ""),
//                        
//                        ]
//                        self.scanID =  self.assentifySdk?.startScanID(scanIDCardDelegate: self,kycDocumentDetails: data)
//                        
//                        self.addChild(self.scanID!)
//                        self.view.addSubview(self.scanID!.view)
//                        self.scanID!.view.translatesAutoresizingMaskIntoConstraints = false
//                        NSLayoutConstraint.activate([
//                            self.scanID!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                            self.scanID!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                            self.scanID!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                            self.scanID!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//                        ])
//                        self.scanID!.didMove(toParent: self)
            
           
            
            /* FaceMatch   */
//           if let imageUrl = URL(string: "https://storagetestassentify.blob.core.windows.net/userfiles/318e2ca7-fde8-4c47-bbcc-0c94b905630f/f7cd52fa-9a2b-40c1-b5b6-3fb4d3cb9e7b/fead2692dd9e48dfa6e96e98f201fe56/traceIdentifier/FaceMatchWithImage/comparedWith.jpeg") {
//               if let base64String = self.imageToBase64(from: imageUrl) {
//                   self.faceMatch =  self.assentifySdk?.startFaceMatch(faceMatchDelegate: self, secondImage:base64String)
//                self.addChild( self.faceMatch!)
//                   self.view.addSubview( self.faceMatch!.view)
//                   self.faceMatch!.view.translatesAutoresizingMaskIntoConstraints = false
//                  NSLayoutConstraint.activate([
//                       self.faceMatch!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                       self.faceMatch!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                      self.faceMatch!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                       self.faceMatch!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//                  ])
//                   
//                   self.faceMatch!.didMove(toParent: self)
//              }
//          }
            
            
        }
    }
    
    
    func onHasTemplates(templates: [TemplatesByCountry]) {
        print("\(yellowColor)onHasTemplates:" , templates)
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

