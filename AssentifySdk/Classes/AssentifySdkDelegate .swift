
import Foundation

public protocol  AssentifySdkDelegate  {
    func onAssentifySdkInitError(message: String)
    func onAssentifySdkInitSuccess(configModel: ConfigModel)
    func onHasTemplates(templates: [TemplatesByCountry])
    
}
