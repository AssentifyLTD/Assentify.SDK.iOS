
import Foundation


public class ContextAwareSigning{
    
    private var contextAwareDelegate: ContextAwareDelegate?;
    private var tenantIdentifier: String;
    private var interaction: String?;
    private var stepID: Int?;
    private var configModel: ConfigModel?;
    private var apiKey: String;
    private var templateId = -1;


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

        getStep()
    }
    
    
  private func  getStep(){
        remoteGetStep(
            apiKey: apiKey,
            userAgent: "SDK",
            flowInstanceId: configModel!.flowInstanceId,
            tenantIdentifier: configModel!.tenantIdentifier,
            blockIdentifier: configModel!.blockIdentifier,
            instanceId: configModel!.instanceId,
            flowIdentifier: configModel!.flowIdentifier,
            instanceHash: configModel!.instanceHash,
            ID: stepID!
            ){ result in
            switch result {
            case .success(let contextAwareSigningModel):
                self.templateId =  contextAwareSigningModel.data.selectedTemplates[0]
                self.getTokens(templateId: self.templateId)
             case .failure(let error):
                self.contextAwareDelegate?.onError(message: error.localizedDescription);
            }
        }
    }
    
    private func  getTokens(templateId:Int){
        remoteGetTokens(
            templateId: templateId
            ){ result in
            switch result {
            case .success(let documentTokensModel):
                self.contextAwareDelegate?.onHasTokens(documentTokens: documentTokensModel)
             case .failure(let error):
                self.contextAwareDelegate?.onError(message: error.localizedDescription);
            }
        }
    }
    

    
   public func createUserDocumentInstance(data: [String: String]){
       let createUserDocumentRequestModel =
                 CreateUserDocumentRequestModel(
                    userId : "UserId",
                    documentTemplateId : templateId,
                    data:  data,
                    outputType:1
                 );
        remoteCreateUserDocumentInstance(requestBody: createUserDocumentRequestModel){
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
    
        remoteSignature(requestBody: signatureRequestModel){
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
