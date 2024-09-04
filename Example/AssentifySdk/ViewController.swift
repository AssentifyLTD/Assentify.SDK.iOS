//
//  ViewController.swift
//  AssentifySdk
//
//  Created by TariQ on 05/31/2024.
//  Copyright (c) 2024 TariQ. All rights reserved.
//
import AssentifySdk

import UIKit

class ViewController: UIViewController , AssentifySdkDelegate,LanguageTransformationDelegate,ScanOtherDelegate,SubmitDataDelegate{
    func onSubmitError(message: String) {
        print("\(yellowColor)onSubmitError:" + message)
    }
    
    func onSubmitSuccess() {
        print("\(yellowColor)onSubmitSuccess:")
    }
    
//    func onComplete(dataModel: FaceResponseModel) {
//                dataModel.faceExtractedModel?.extractedData?.forEach({ (key: String, value: Any) in
//                    print("\(yellowColor)extractedData:" + key + " " +  "\(value)")
//                })
//    }
    
//    func onComplete(dataModel: PassportResponseModel) {
//        dataModel.passportExtractedModel?.outputProperties?.forEach({ (key: String, value: Any) in
//            print("\(yellowColor)outputProperties:" + key + " " +  "\(value)")
//        })
// 
//        dataModel.passportExtractedModel?.transformedProperties?.forEach({ (key: String, value: Any) in
//            print("\(yellowColor)transformedProperties:" + key + " " +  "\(value)")
//        })
//        
//
//        print("\(yellowColor)------------------------------------------")
//        
//        dataModel.passportExtractedModel?.extractedData?.forEach({ (key: String, value: Any) in
//            print("\(yellowColor)extractedData:" + key + " " +  "\(value)")
//        })
//        print("\(yellowColor)------------------------------------------")
//        print("\(yellowColor)imageUrl:" +  (dataModel.passportExtractedModel?.imageUrl)!)
//        print("\(yellowColor)identificationDocumentCapture:" +  "\(dataModel.passportExtractedModel?.identificationDocumentCapture?.name)" )
//        print("\(yellowColor)------------------------------------------")
//    }
    
//    func onComplete(dataModel: IDResponseModel, order: Int) {
//        print("\(yellowColor)------------------------------------------" + order.description)
//        dataModel.iDExtractedModel?.outputProperties?.forEach({ (key: String, value: Any) in
//            print("\(yellowColor)outputProperties:" + key + " " +  "\(value)")
//        })
// 
//        dataModel.iDExtractedModel?.transformedProperties?.forEach({ (key: String, value: Any) in
//            print("\(yellowColor)transformedProperties:" + key + " " +  "\(value)")
//        })
//        
//
//        print("\(yellowColor)------------------------------------------")
//        
//        dataModel.iDExtractedModel?.extractedData?.forEach({ (key: String, value: Any) in
//            print("\(yellowColor)extractedData:" + key + " " +  "\(value)")
//        })
//        print("\(yellowColor)------------------------------------------")
//        print("\(yellowColor)imageUrl:" +  (dataModel.iDExtractedModel?.imageUrl)!)
//        print("\(yellowColor)identificationDocumentCapture:" +  "\(dataModel.iDExtractedModel?.identificationDocumentCapture?.name)" )
//        print("\(yellowColor)------------------------------------------")
//    }
//    
//    func onWrongTemplate(dataModel: RemoteProcessingModel) {
//        
//    }
    
    
        func onComplete(dataModel: OtherResponseModel) {
            dataModel.otherExtractedModel?.outputProperties?.forEach({ (key: String, value: Any) in
                print("\(yellowColor)outputProperties:" + key + " " +  "\(value)")
            })
    
            dataModel.otherExtractedModel?.transformedProperties?.forEach({ (key: String, value: Any) in
                print("\(yellowColor)transformedProperties:" + key + " " +  "\(value)")
            })
    
    
            print("\(yellowColor)------------------------------------------")
    
            dataModel.otherExtractedModel?.extractedData?.forEach({ (key: String, value: Any) in
                print("\(yellowColor)extractedData:" + key + " " +  "\(value)")
            })
            print("\(yellowColor)------------------------------------------")
            print("\(yellowColor)imageUrl:" +  (dataModel.otherExtractedModel?.imageUrl)!)
            print("\(yellowColor)identificationDocumentCapture:" +  "\(dataModel.otherExtractedModel?.identificationDocumentCapture?.name)" )
            print("\(yellowColor)------------------------------------------")
        }
   
    
    func onTranslatedSuccess(properties: [String : String]?) {
        properties?.forEach({ (key: String, value: String) in
            print("\(yellowColor)onTranslatedSuccess:" + key)
            print("\(yellowColor)onTranslatedSuccess:" + value)
        })
    }
    
    func onTranslatedError(properties: [String : String]?) {
        properties?.forEach({ (key: String, value: String) in
            print("\(yellowColor)onTranslatedError:" + key)
            print("\(yellowColor)onTranslatedError:" + value)
        })
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
          CustomColor: "#FFFFFF",
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
                apiKey: "7UXZBSN2CeGxamNnp9CluLJn7Bb55lJo2SjXmXqiFULyM245nZXGGQvs956Fy5a5s1KoC4aMp5RXju8w",
                tenantIdentifier: "4232e33b-1a90-4b74-94a4-08dcab07bc4d",
                interaction: "F0D1B6A7D863E9E4089B70EE5786D3D8DF90EE7BDD12BE315019E1F2FC0E875A",
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
        
        
        let submitRequests: [SubmitRequestModel] = [
            SubmitRequestModel(
                stepId: 2684,
                stepDefinition: "IdentificationDocumentCapture",
                extractedInformation: [
                    "79755e2e-6276-40db-a14b-5defd8883e2d_OnBoardMe_IdentificationDocumentCapture_ID_PlaceOfResidence": "شبعا غربي - حاصبيا",
                    "016fc319-d7ad-44ea-b59a-900ef23a0c60_OnBoardMe_IdentificationDocumentCapture_ID_CivilRegisterNumber": "226",
                    "84a26541-229e-4cfd-a189-95cd7f459eb3_OnBoardMe_IdentificationDocumentCapture_ID_BackImage": "https://storagetestassentify.blob.core.windows.net/userfiles/4232e33b-1a90-4b74-94a4-08dcab07bc4d/988cbba1-2647-4226-bb4b-63d9eea06d4a/2ab51111158a4c6686c3c0b02a3aee8e/BB5B6E72-0FB9-4488-BA45-0B524F92EAA7/faceFrame.jpg",
                    "039489a7-aa9b-448f-a59c-3fd6eca402db_OnBoardMe_IdentificationDocumentCapture_surname": "هاشم تات",
                    "a694d89f-ef8d-4493-91e4-ca9caa1c4d58_OnBoardMe_IdentificationDocumentCapture_BackTamperHeatmap": "https://tamper-heatmap",
                    "528ed89d-c5db-4ed1-954f-73812440dd79_OnBoardMe_IdentificationDocumentCapture_ID_DateOfIssuance": "06/10/2008",
                    "c14dcb74-8fdf-471b-945a-5f3da365107e_OnBoardMe_IdentificationDocumentCapture_ID_Governorate": "حاصبيا",
                    "2f20dbff-d770-4315-ac1a-2038e2c35453_OnBoardMe_IdentificationDocumentCapture_ID_FathersName": "شادي",
                    "f3b63cd9-96db-4abb-a520-324c0c020edd_OnBoardMe_IdentificationDocumentCapture_ID_PlaceOfBirth": "بيروت",
                    "6892dcfc-24ec-4560-bbb6-c75ded33842c_OnBoardMe_IdentificationDocumentCapture_CapturedVideoFront": "https://storagetestassentify.blob.core.windows.net/userfiles/clipsPath/638610556292766096_tmpOiLGKh.mp4",
                    "b04148d7-2737-40a4-98e2-9f93aaf9a2b2_OnBoardMe_IdentificationDocumentCapture_name": "محمد النس",
                    "5255a268-ff9e-4027-ac7d-3c2eaead3360_OnBoardMe_IdentificationDocumentCapture_Sex": "ذكر",
                    "7151cd3c-bf37-41d2-9778-e650518476d3_OnBoardMe_IdentificationDocumentCapture_ID_MothersName": "ياسمين نبعه",
                    "7889e653-3280-4373-a8ec-9a0168cb14a2_OnBoardMe_IdentificationDocumentCapture_ID_Province": "النبطية",
                    "27102862-587e-40f0-9fc5-89f17c92e15b_OnBoardMe_IdentificationDocumentCapture_Image": "https://storagetestassentify.blob.core.windows.net/userfiles/4232e33b-1a90-4b74-94a4-08dcab07bc4d/988cbba1-2647-4226-bb4b-63d9eea06d4a/2ab51111158a4c6686c3c0b02a3aee8e/B4778938-623F-4923-8D79-5B1354BFF75E/faceFrame.jpg",
                    "8483b062-5d22-42e6-ab40-319eeba79950_OnBoardMe_IdentificationDocumentCapture_TamperHeatMap": "https://tamper-heatmap",
                    "24682837-22df-46fd-9f3a-d5d0dbd2cabf_OnBoardMe_IdentificationDocumentCapture_Country": "LB",
                    "910607d9-38cd-4a5c-9331-e1cd6f483fe2_OnBoardMe_IdentificationDocumentCapture_GhostImage": "https://placeholder.jpeg",
                    "321c512a-3471-42b5-8044-2f363d989d8c_OnBoardMe_IdentificationDocumentCapture_OriginalBackImage": "https://storagetestassentify.blob.core.windows.net/userfiles/4232e33b-1a90-4b74-94a4-08dcab07bc4d/988cbba1-2647-4226-bb4b-63d9eea06d4a/2ab51111158a4c6686c3c0b02a3aee8e/BB5B6E72-0FB9-4488-BA45-0B524F92EAA7/original_image.jpg",
                    "8e429109-1bd3-4b02-9cb2-22003d3f93fb_OnBoardMe_IdentificationDocumentCapture_CapturedVideoBack": "https://storagetestassentify.blob.core.windows.net/userfiles/clipsPath/638610556572931053_tmp5ZfP5h.mp4",
                    "a7b4a14a-3061-4386-b406-0f9539f53d13_OnBoardMe_IdentificationDocumentCapture_FaceCapture": "https://storagetestassentify.blob.core.windows.net/userfiles/4232e33b-1a90-4b74-94a4-08dcab07bc4d/988cbba1-2647-4226-bb4b-63d9eea06d4a/2ab51111158a4c6686c3c0b02a3aee8e/B4778938-623F-4923-8D79-5B1354BFF75E/IDCard/face_0.jpeg",
                    "95e1915b-794a-4169-8cc6-27f2db483e8b_OnBoardMe_IdentificationDocumentCapture_Birth_Date": "28/12/1998",
                    "a63e9989-a6f4-471a-ab3e-ca81c83f1cbb_OnBoardMe_IdentificationDocumentCapture_OriginalFrontImage": "https://storagetestassentify.blob.core.windows.net/userfiles/4232e33b-1a90-4b74-94a4-08dcab07bc4d/988cbba1-2647-4226-bb4b-63d9eea06d4a/2ab51111158a4c6686c3c0b02a3aee8e/B4778938-623F-4923-8D79-5B1354BFF75E/original_image.jpg",
                    "a3df19bd-dc10-4f0c-afcc-dc8041d68cc7_OnBoardMe_IdentificationDocumentCapture_Document_Number": "000028500062",
                    "90e25e06-6286-447c-8bcf-5925306d2b20_OnBoardMe_IdentificationDocumentCapture_IDType": "Lebanese Civil ID",
                    "c8a67b93-4f6c-4163-b037-59dacdb57cca_OnBoardMe_IdentificationDocumentCapture_ID_MaritalStatus": "اعزب"
                ]
            ),
            SubmitRequestModel(
                stepId: 2685,
                stepDefinition: "FaceImageAcquisition",
                extractedInformation: [
                    "82ab80c7-9a72-420e-a3ea-e96f0d8207a2_OnBoardMe_FaceImageAcquisition_SecondImage": "https://storagetestassentify.blob.core.windows.net/userfiles/4232e33b-1a90-4b74-94a4-08dcab07bc4d/988cbba1-2647-4226-bb4b-63d9eea06d4a/2ab51111158a4c6686c3c0b02a3aee8e/57dbdec2-8e18-4e95-b68d-e9e287ebaa39/FaceMatchWithImage/comparedWith.jpeg",
                    "d7bf92d0-b1bf-4626-9b5a-b9afad7f339d_OnBoardMe_FaceImageAcquisition_BaseImage": "https://storagetestassentify.blob.core.windows.net/userfiles/4232e33b-1a90-4b74-94a4-08dcab07bc4d/988cbba1-2647-4226-bb4b-63d9eea06d4a/2ab51111158a4c6686c3c0b02a3aee8e/57dbdec2-8e18-4e95-b68d-e9e287ebaa39/FaceMatchWithImage/source.jpeg"
                ]
            ),
            SubmitRequestModel(
                stepId: 2683,
                stepDefinition: "WrapUp",
                extractedInformation: [
//                    "112e1939-d32e-45b4-b734-dc4c21b32aab_OnBoardMe_WrapUp_TimeEnded": "2024-09-04 17:08:08"
                    
                    "112e1939-d32e-45b4-b734-dc4c21b32aab_OnBoardMe_WrapUp_TimeEnded": "09/04/2024 17:08:08"
                ]
            ),
            SubmitRequestModel(
                stepId: 2682,
                stepDefinition: "BlockLoader",
                extractedInformation: [
                    "e8072a30-cf2f-4a67-a5b5-060ceeae4b6c_OnBoardMe_BlockLoader_FlowName": "ENTER YOUR FLOW NAME HERE",
                    "d260bd33-a1ae-4590-b195-ad4d7b4d8a3c_OnBoardMe_BlockLoader_TimeStarted": "09/04/2024 17:08:08",
                    "2fb29e00-bcc4-4be2-a4ef-3f15e9fb4b17_OnBoardMe_BlockLoader_InstanceHash": "ENTER YOUR INSTANCE HASH HERE",
                    "79d7a5fd-f6a1-44e0-830a-a713160ad7ab_OnBoardMe_BlockLoader_Application": "ENTER YOUR APPLICATION HERE",
                    "acdb96e6-8aa5-448c-b334-132b5a83329f_OnBoardMe_Property_phoneNumber": "1000",
                    "2f48ffe5-88f8-42a4-8bda-98c1590276db_OnBoardMe_BlockLoader_DeviceName": "ENTER YOUR DEVICE NAME HERE",
                    "07c62ee2-8e79-445d-8a23-0a8fe1883ba0_OnBoardMe_BlockLoader_UserAgent": "ENTER YOUR USER AGENT HERE"
                ]
            )
        ]
        _ = assentifySdk?.startSubmitData(submitDataDelegate: self, submitRequestModel: submitRequests)
        
        DispatchQueue.main.async {
            
            /* PASSPORT */
//            
//            self.scanPassport =  self.assentifySdk?.startScanPassport(scanPassportDelegate: self,language: Language.Arabic)
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
            
//            self.scanOther =  self.assentifySdk?.startScanOthers(scanOtherDelegate: self,language: Language.Arabic);
//            self.addChild(  self.scanOther!)
//            self.view.addSubview(  self.scanOther!.view)
//            self.scanOther!.view.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                self.scanOther!.view.topAnchor.constraint(equalTo: self.view.topAnchor),
//                self.scanOther!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                self.scanOther!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                self.scanOther!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//            ])
//            self.scanOther!.didMove(toParent: self)
            
            
            
            /* ID */
          
//                       let data = [
//                            KycDocumentDetails(
//                              
//                            name: "", order: 0, templateProcessingKeyInformation: "75b683bb-eb81-4965-b3f0-c5e5054865e7",  templateSpecimen:""),
//                            KycDocumentDetails(
//                            name: "", order: 1, templateProcessingKeyInformation: "eae46fac-1763-4d31-9acc-c38d29fe56e4",  templateSpecimen:""),
//                        
//                        ]
//            self.scanID =  self.assentifySdk?.startScanID(scanIDCardDelegate: self,kycDocumentDetails: data,language: Language.English)
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
            
//            let request = [
//                    LanguageTransformationModel(languageTransformationEnum: LanguageTransformationEnum.Translation, key: "Date", value: "١١/٢/١٩٩٩", language: Language.English, dataType: DataType.Date)
//                ]
//            
//            self.assentifySdk?.languageTransformation(languageTransformationDelegate: self, language: Language.Arabic, languageTransformationData: request)

            
            
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

