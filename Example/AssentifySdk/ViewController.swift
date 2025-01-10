//
//  ViewController.swift
//  AssentifySdk
//
//  Created by TariQ on 05/31/2024.
//  Copyright (c) 2024 TariQ. All rights reserved.
//
import AssentifySdk

import UIKit

class ViewController: UIViewController , AssentifySdkDelegate,ContextAwareDelegate{
  

    
    
    
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
    private var  contextAwareSigning   :ContextAwareSigning?
    
    let yellowColor = "🔥 -> ";
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assentifySdk = AssentifySdk(
            apiKey: "7UXZBSN2CeGxamNnp9CluLJn7Bb55lJo2SjXmXqiFULyM245nZXGGQvs956Fy5a5s1KoC4aMp5RXju8w",
            tenantIdentifier: "4232e33b-1a90-4b74-94a4-08dcab07bc4d",
            interaction: "E893390F6835D4E1D2F12126B7AA2B0ED996C056C8893BA267A7FE90A8452200",
            environmentalConditions: self.environmentalConditions,
            assentifySdkDelegate: self,
            processMrz: true,
            storeCapturedDocument: true,
            performLivenessDocument:  false,
            performLivenessFace:  false,
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
             
            }
        }
        contextAwareSigning =  assentifySdk?.startContextAwareSigning(contextAwareDelegate: self)

    }
    
    func onHasTokens(documentTokens: [DocumentTokensModel]) {
        print("onHasTokens")
        var data: [String : String] = [:];
        documentTokens.forEach(){item in
            print(item.displayName + " : " + item.tokenValue)
            data[item.id.description]="iOS Test"
        }
        contextAwareSigning?.createUserDocumentInstance(data: data);
        
    }
    
    func onCreateUserDocumentInstance(userDocumentResponseModel: CreateUserDocumentResponseModel) {
        print("onCreateUserDocumentInstance " + userDocumentResponseModel.templateInstanceId.description)
        print("onCreateUserDocumentInstance " + userDocumentResponseModel.templateInstance)
        contextAwareSigning?.signature(documentId: userDocumentResponseModel.documentId,documentInstanceId: userDocumentResponseModel.templateInstanceId, signature: "iVBORw0K...")
    }
    
    func onSignature(signatureResponseModel: SignatureResponseModel) {
        print("onSignature " + signatureResponseModel.signedDocument)
        print("onSignature " + signatureResponseModel.signedDocumentUri)
    }
    
    func onError(message: String) {
        print("onError " + message)
    }
    
}

