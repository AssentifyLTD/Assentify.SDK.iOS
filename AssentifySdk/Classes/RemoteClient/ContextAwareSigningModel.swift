

import Foundation

public struct DataModel: Codable {
    public  let selectedTemplates: [Int]
    public  let header:String?
    public  let subHeader:String?
    public  let confirmationMessage:String?
    public  let autoDownload:Bool
    
}    


public struct ContextAwareSigningModel: Codable {
    public  let statusCode: Int
    public  let data: DataModel
}
