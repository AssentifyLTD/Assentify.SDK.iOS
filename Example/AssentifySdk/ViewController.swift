//
//  ViewController.swift
//  AssentifySdk
//
//  Created by TariQ on 05/31/2024.
//  Copyright (c) 2024 TariQ. All rights reserved.
//
import AssentifySdk

import UIKit

class ViewController: UIViewController , AssentifySdkDelegate,ScanPassportDelegate,ScanOtherDelegate,ScanIDCardDelegate,FaceMatchDelegate{
    
    func onEnvironmentalConditionsChange(brightness: Double, motion: MotionType) {
        //
        
    }
    
    func onComplete(dataModel: RemoteProcessingModel, order: Int) {
        print("\(yellowColor)onComplete:" )
        print("\(yellowColor)onComplete: " , order)
        print("\(yellowColor)onComplete: " , dataModel)
    }
    
    func onWrongTemplate(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onWrongTemplate:" )
    }
    
    func onError(dataModel: RemoteProcessingModel) {
        
    }
    
    func onSend() {
        print("\(yellowColor)onSend:" )
    }
    
    func onRetry(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onRetry:" , dataModel)
    }
    
    func onClipPreparationComplete(dataModel: RemoteProcessingModel) {
        
    }
    
    func onStatusUpdated(dataModel: RemoteProcessingModel) {
        
    }
    
    func onUpdated(dataModel: RemoteProcessingModel) {
        
    }
    
    func onLivenessUpdate(dataModel: RemoteProcessingModel) {
        
    }
    
    func onComplete(dataModel: RemoteProcessingModel) {
        print("\(yellowColor)onComplete:" , dataModel)
    }
    
    func onCardDetected(dataModel: RemoteProcessingModel) {
        
    }
    
    func onMrzExtracted(dataModel: RemoteProcessingModel) {
        
    }
    
    func onMrzDetected(dataModel: RemoteProcessingModel) {
        
    }
    
    func onNoMrzDetected(dataModel: RemoteProcessingModel) {
        
    }
    
    func onFaceDetected(dataModel: RemoteProcessingModel) {
        
    }
    
    func onNoFaceDetected(dataModel: RemoteProcessingModel) {
        
    }
    
    func onFaceExtracted(dataModel: RemoteProcessingModel) {
        
    }
    
    func onQualityCheckAvailable(dataModel: RemoteProcessingModel) {
        
    }
    
    func onDocumentCaptured(dataModel: RemoteProcessingModel) {
        
    }
    
    func onDocumentCropped(dataModel: RemoteProcessingModel) {
        
    }
    
    func onUploadFailed(dataModel: RemoteProcessingModel) {
        
    }
    
    func onEnvironmentalConditionsChange(brightness: Double, motion: MotionType, zoom: ZoomType) {
//        print("\(yellowColor)onEnvironmentalConditionsChange:" , brightness)
//        print("\(yellowColor)onEnvironmentalConditionsChange:" , motion)
//        print("\(yellowColor)onEnvironmentalConditionsChange:" , zoom)
        
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
        assentifySdk?.getTemplates();
        DispatchQueue.main.async {
            
            /* PASSPORT */
           
            self.scanPassport =  self.assentifySdk?.startScanPassport(scanPassportDelegate: self)
            self.addChild(  self.scanPassport!)
            self.view.addSubview(  self.scanPassport!.view)
            self.scanPassport!.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.scanPassport!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.scanPassport!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.scanPassport!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.scanPassport!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
            self.scanPassport!.didMove(toParent: self)
           
            
            
            /* OTHER */
            /*
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
             */
            
            
            /* ID */
            /*
            let data = [
                            KycDocumentDetails(
                            name: "", order: 0, templateProcessingKeyInformation: "75b683bb-eb81-4965-b3f0-c5e5054865e7"),
                            KycDocumentDetails(
                            name: "", order: 1, templateProcessingKeyInformation: "eae46fac-1763-4d31-9acc-c38d29fe56e4"),
                        
                        ]
                        self.scanID =  self.assentifySdk?.startScanID(scanIDCardDelegate: self,kycDocumentDetails: data)
                        
                        self.addChild(self.scanID!)
                        self.view.addSubview(self.scanID!.view)
                        self.scanID!.view.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            self.scanID!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                            self.scanID!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                            self.scanID!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                            self.scanID!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                        ])
                        self.scanID!.didMove(toParent: self)
             */
            
            
            /* FaceMatch   */
            /*
            self.faceMatch =  self.assentifySdk?.startFaceMatch(faceMatchDelegate: self, secondImage:"")
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
            */
            
        }
    }
    
    
    func onHasTemplates(templates: [TemplatesByCountry]) {
        print("\(yellowColor)onHasTemplates:" , templates)
    }

}

