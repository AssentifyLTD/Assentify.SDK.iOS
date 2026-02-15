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
   
    
  
    
  

    func onComplete(dataModel: FaceResponseModel) {
        print("\(yellowColor)onComplete: " )
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let formattedDate = formatter.string(from: currentDate)
        print("\(yellowColor)onComplete: \(formattedDate)")
        print("\(yellowColor)onComplete: ",dataModel.faceExtractedModel?.baseImageFace)
        print("\(yellowColor)onComplete: ",dataModel.faceExtractedModel?.secondImageFace)
        print("\(yellowColor)onComplete: ",dataModel.faceExtractedModel?.percentageMatch)
        print("\(yellowColor)onComplete: ",dataModel.faceExtractedModel?.isLive)
    }

    func onError(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onError:")

    }
    
    func onSend() {
        print("\(yellowColor)onSend:")
        
    }
    
    func onRetry(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onRetry:" , dataModel.error)
    }
    
    
    let environmentalConditions = EnvironmentalConditions(
        enableDetect: true,
        enableGuide: true,
        CountDownNumbersColor: "#FFFFFF",
        HoldHandColor: "#FC4D92",
        activeLiveType: ActiveLiveType.BLINK,
        activeLivenessCheckCount: 1,
        faceLivenessRetryCount: 2,
        minRam: 10,
        minCPUCores: 10    )
    
    
    
    
    private var assentifySdk :AssentifySdk?
    private var configModel :ConfigModel?
    private var  scanPassport   :ScanPassport?
    private var  scanOther   :UIViewController?
    private var  scanID   :ScanIDCard?
    private var  scanQr   :ScanQr?
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
            performActiveLivenessFace:  true,
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
        self.configModel = configModel;
        print("\(yellowColor)onAssentifySdkInitSuccess:" , configModel.stepDefinitions)
    
       
        
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
            
         
            self.countdownLabel.font = UIFont.boldSystemFont(ofSize: 40)
            self.countdownLabel.textAlignment = .center
            self.countdownLabel.backgroundColor = UIColor.clear
            self.countdownLabel.translatesAutoresizingMaskIntoConstraints = false
          
            
            
            /* FaceMatch   */
            if let imageUrl = URL(string: "https://blob.assentify.com/v2/Document/9lZQIJL_DqaY6O2TXFMZ2IglH25fxNWvXV-jNdR-TFc=/original_image.jpg") {
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
            

            
            let click: UIButton = {
                               let button = UIButton(type: .system)
                               button.setTitle("Take Phote", for: .normal)
                               button.setTitleColor(.white, for: .normal)
                               button.backgroundColor = .systemBlue
                               button.layer.cornerRadius = 12
                               button.translatesAutoresizingMaskIntoConstraints = false // for Auto Layout
                               return button
                           }()
            
            self.view.addSubview(click)
            
            NSLayoutConstraint.activate([
                    click.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    click.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                    click.widthAnchor.constraint(equalToConstant: 200),
                    click.heightAnchor.constraint(equalToConstant: 50)
                ])
                
                // Add tap action
          click.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
            
            let click2: UIButton = {
                              let button2 = UIButton(type: .system)
                              button2.setTitle("next", for: .normal)
                              button2.setTitleColor(.white, for: .normal)
                              button2.backgroundColor = .systemBlue
                              button2.layer.cornerRadius = 12
                              button2.translatesAutoresizingMaskIntoConstraints = false // for Auto Layout
                              return button2
                          }()
          
            
          
            
            self.view.addSubview(click2)
            NSLayoutConstraint.activate([
                click2.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                           click2.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 100),
                           click2.widthAnchor.constraint(equalToConstant: 200),
                           click2.heightAnchor.constraint(equalToConstant: 50)
                ])
            click2.addTarget(self, action: #selector(self.buttonTapped2), for: .touchUpInside)

            
        }
        
        
        print("\(yellowColor) isManual :  \(self.assentifySdk?.isManual())")
        
    }
    
    @objc func buttonTapped() {
        faceMatch?.takePicture();
           }
       
       @objc func buttonTapped2() {
         scanID?.changeTemplateId();
       }
    
    func onEnvironmentalConditionsChange( brightnessEvents: BrightnessEvents,
                                          motion: MotionType,
                                          faceEvents: FaceEvents,
                                          zoom: ZoomType,
                                          detectedFaces:Int,
                                          isCentered: Bool,) {
//        DispatchQueue.main.async {
//            
//           
//            print("\(self.yellowColor) isCentered:")
//            print(isCentered)
//          
//        }
    }
    
    func onCurrentLiveMoveChange(activeLiveEvents: ActiveLiveEvents) {
//        print("\(yellowColor)activeLiveEvents:")
//        print(activeLiveEvents.rawValue)
    }
    
    func onLivenessUpdate(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onLivenessUpdate:" , dataModel.error)
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
    
    func onUploadingProgress(progress: Double) {
        print("onUploadingProgress : \(Int(progress * 100))%")

    }
}






////
////  ViewController.swift
////  AssentifySdk
////
////  Created by TariQ on 05/31/2024.
////  Copyright (c) 2024 TariQ. All rights reserved.
////
//import AssentifySdk
//
//import UIKit
//
//class ViewController: UIViewController , AssentifySdkDelegate , FlowDelegate{
//  
//    
//   
//    let yellowColor = "🔥 -> ";
//    private var assentifySdk :AssentifySdk?
//    let environmentalConditions = EnvironmentalConditions(
//          enableDetect: true,
//          enableGuide: true,
//          CountDownNumbersColor: "#FC4D92",
//          HoldHandColor: "#FC4D92",
//          activeLiveType: ActiveLiveType.BLINK,
//          activeLivenessCheckCount: 1,
//          minRam: 2,
//          minCPUCores: 6
//      
//      )
//      
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//     
//        self.assentifySdk = AssentifySdk(
//                 apiKey: "QwWzzKOYLkDzCLJ9lENlgvRQ1kmkKDv76KbJ9sPfr9Joxwj2DUuzC7htaZP89RqzgB9i9lHc4IpYOA7g",
//                 tenantIdentifier: "2937c91f-c905-434b-d13d-08dcc04755ec",
//                 interaction: "E4BDD59C3B69A3F89AE8C756FCD67EBC72A45F405B256B3C3BDD643BE282B195",
//                 environmentalConditions: self.environmentalConditions,
//                 assentifySdkDelegate: self,
//                 performActiveLivenessFace:  false,
//             )
//        
//    }
//    
//    
//    func onAssentifySdkInitError(message: String) {
//            print("\(yellowColor)onAssentifySdkInitError:" , message)
//        }
//        
//    func onAssentifySdkInitSuccess(configModel: ConfigModel) {
//        print("\(yellowColor)onAssentifySdkInitSuccess:" )
//        let  blockLoaderCustomProperties: [String: Any] = [:] ;
//        let flowEnvironmentalConditions = FlowEnvironmentalConditions(
//              backgroundType: .color,
//              logoUrl: "https://image2url.com/r2/default/images/1769694393603-0afa5733-d9a5-4b0d-9134-868d3a750069.png",
////            svgBackgroundImageUrl: "https://api.dicebear.com/7.x/shapes/svg?seed=patternA",
//            textColor: "#000000",
//            secondaryTextColor: "#ffffff",
//            backgroundCardColor: "#f3f4f6",
//            accentColor: "#ffc400",
//            backgroundColor: .solid(hex: "#ffffff"),
//            clickColor: .solid(hex: "#ffc400"),
//          
////            language: Language.English,
////            enableNfc: true,
////            enableQr: true,
////            blockLoaderCustomProperties: blockLoaderCustomProperties
////              textColor:"000000",
////              secondaryTextColor: "#000000",
////              backgroundCardColor : "#F2F2F2",
////              accentColor : "#833F89",
////              backgroundColor: .solid(hex: "#ffffff"),
////              clickColor : .gradient(
////                colorsHex: ["#833F89", "#C82B47"],
////                angleDegrees: 0.0,
////                holdUntil : 0.6
////            ),
//        )
//
//        DispatchQueue.main.async {
//            self.assentifySdk!.startFlow(from:self,flowDelegate: self,flowEnvironmentalConditions: flowEnvironmentalConditions)
//
//        }
//    }
//    
//    func onFlowCompleted(submitRequestModel: [SubmitRequestModel]) {
//        print("\(yellowColor)onFlowCompleted: \(submitRequestModel)")
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//}
//
//
