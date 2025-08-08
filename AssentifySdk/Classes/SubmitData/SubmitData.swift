
import Foundation


public class SubmitData{
    private var apiKey: String;
    private var submitDataDelegate: SubmitDataDelegate;
    private var submitRequestModel: [SubmitRequestModel];
    private var configModel: ConfigModel;
    
    init(
        apiKey: String,
        submitDataDelegate: SubmitDataDelegate,
        submitRequestModel:  [SubmitRequestModel],
        configModel: ConfigModel
    ){
        self.apiKey = apiKey;
        self.submitDataDelegate = submitDataDelegate;
        self.submitRequestModel = submitRequestModel;
        self.configModel = configModel;
        submitData();
    }
    
    private func submitData() {
        BugsnagObject.logInfo(message: "Data submission started. \(submitRequestModelLog(submitRequestModel: submitRequestModel))", configModel:configModel)
        
        remoteSubmitData(
            apiKey: apiKey,
            configModel: self.configModel,
            submitRequestModel: submitRequestModel
        ) { result in
            switch result {
            case .success(_):
                BugsnagObject.logInfo(message: "Data submission success", configModel:self.configModel)
                self.submitDataDelegate.onSubmitSuccess()
                
            case .failure(let error):
                BugsnagObject.logInfo(message: "Data submission failed: \(error.localizedDescription)", configModel:self.configModel)
                self.submitDataDelegate.onSubmitError(message: error.localizedDescription)
            }
        }
    }
    
    private func submitRequestModelLog(submitRequestModel: [SubmitRequestModel]) -> [String: Any] {
        var stepsMap = [String: Any]()
        
        for model in submitRequestModel {
            let key = "\(model.stepDefinition) : \(model.stepId)"
            let value = "Extracted Information Size : \(model.extractedInformation.count)"
            stepsMap[key] = value
        }
        
        return stepsMap
    }


     
    
}
