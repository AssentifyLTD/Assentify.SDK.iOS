import Foundation


public class LanguageTransformation{
    private var apiKey: String;
    private var languageTransformationDelegate: LanguageTransformationDelegate;
    
    init(
        apiKey: String,
        languageTransformationDelegate: LanguageTransformationDelegate
    ){
        self.apiKey = apiKey;
        self.languageTransformationDelegate = languageTransformationDelegate;
    }
    
    public func  languageTransformation(langauge:String, transformationModel: TransformationModel){
        transformData(apiKey: apiKey, language: langauge, request: transformationModel) { result in
            switch result {
            case .success(let transformedData):
                self.languageTransformationDelegate.onTranslatedSuccess(properties:mergeKeyValue(languageTransformationList: transformedData) )
           /Users/tariq/Desktop/iOS/LanguageTransformation/LanguageTransformationDelegate.swift case .failure(let error):
                self.languageTransformationDelegate.onTranslatedError(properties:mergeKeyValue(languageTransformationList:transformationModel.languageTransformationModels) )
            }
        }
    }
     
    
}

private func mergeKeyValue(languageTransformationList: [LanguageTransformationModel]) -> [String: String] {
    var properties: [String: String] = [:]
    for item in languageTransformationList {
        properties[item.key] = item.value
    }
    return properties
}

