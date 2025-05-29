
import Foundation


public protocol ContextAwareDelegate{
    func onHasTokens(documentTokens: [DocumentTokensModel]);
    func onCreateUserDocumentInstance(userDocumentResponseModel: CreateUserDocumentResponseModel);
    func onSignature(signatureResponseModel :SignatureResponseModel);
    func onError(message :String);
}
