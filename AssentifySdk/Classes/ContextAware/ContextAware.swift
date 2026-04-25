
import Foundation


public class ContextAwareSigning{
    
    private var contextAwareDelegate: ContextAwareDelegate?;
    private var contextAwareSigningModel: ContextAwareSigningModel?;
    private var tenantIdentifier: String;
    private var interaction: String?;
    private var stepID: Int?;
    private var configModel: ConfigModel?;
    private var apiKey: String;


    init(configModel: ConfigModel!,
         apiKey:String,
         stepID:Int,
         tenantIdentifier:String,
         interaction:String,
         contextAwareDelegate:ContextAwareDelegate
    ) {
        self.configModel = configModel;
        self.apiKey = apiKey;
        self.stepID = stepID;
        self.tenantIdentifier = tenantIdentifier;
        self.interaction = interaction;
        self.contextAwareDelegate = contextAwareDelegate;

        getContextAwareSigningStepFromConfigFile()
    }
    
    
  private func  getContextAwareSigningStepFromConfigFile(){
      
      let stepDefinitions = self.configModel!.stepDefinitions
      stepDefinitions.forEach { step in
          if step.stepId == self.stepID  {
              let contextAwareSigningModel = step.customization.toContextAwareSigningModel()
              self.contextAwareSigningModel = contextAwareSigningModel
              contextAwareSigningModel.data.selectedTemplates.forEach({ it in
                  self.getTokensMappings(templateId: it)
              })
          }
      }
    }
    
    private func  getTokensMappings(templateId:Int){
        let stepDefinitions = self.configModel!.stepDefinitions
        stepDefinitions.forEach { step in
            if step.stepId == self.stepID  {
                self.contextAwareDelegate?.onHasTokens(templateId: templateId,documentTokens: step.mappings!,contextAwareSigningModel:self.contextAwareSigningModel! );
            }
        }
       
    }
    

    
   public func createUserDocumentInstance(templateId:Int,data: [String: String]){
       let createUserDocumentRequestModel =
                 CreateUserDocumentRequestModel(
                    userId : "UserId",
                    documentTemplateId : templateId,
                    data:  data,
                    outputType:1
                 );
       remoteCreateUserDocumentInstance(tenantIdentifier: self.configModel!.tenantIdentifier,requestBody: createUserDocumentRequestModel){
            result in
            switch result {
            case .success(let createUserDocumentResponseModel):
                self.contextAwareDelegate?.onCreateUserDocumentInstance(
                    userDocumentResponseModel: createUserDocumentResponseModel
                       );
             case .failure(let error):
                self.contextAwareDelegate?.onError(message: error.localizedDescription);
            }
        }
    }
    
    public func signature(documentId:Int,documentInstanceId: Int,
                          signature: String){
        let signatureRequestModel =
        SignatureRequestModel(
                     documentId : documentId,
                     documentInstanceId : documentInstanceId,
                     documentName : "documentName",
                     username : "UserId",
                     requiresAdditionalData : false,
                     signature : signature
                  );
    
        remoteSignature(tenantIdentifier: self.configModel!.tenantIdentifier,requestBody: signatureRequestModel){
             result in
             switch result {
             case .success(let signatureResponseModel):
                 self.contextAwareDelegate?.onSignature(signatureResponseModel: signatureResponseModel);
              case .failure(let error):
                 self.contextAwareDelegate?.onError(message: error.localizedDescription);
             }
         }
     }
    
    
}

extension Customization {
    func toContextAwareSigningModel() -> ContextAwareSigningModel {
        return ContextAwareSigningModel(
            statusCode: 200,
            data: DataModel(
                selectedTemplates: self.selectedTemplates ?? [],
                header: self.header,
                subHeader: self.subHeader,
                confirmationMessage: self.confirmationMessage,
                autoDownload: self.autoDownload ?? false,
                enableDigitalSignature: !(self.hideSignatureBoard ?? false),
                hideSignatureBoard: self.hideSignatureBoard ?? false,
                otpInputType: self.otpInputType ?? "TEXT",
                enableOtp: self.enableOtp ?? false,
                otpSize: self.otpSize,
                otpType: self.otpType,
                otpExpiryTime: self.otpExpiryTime
            )
        )
    }
}
