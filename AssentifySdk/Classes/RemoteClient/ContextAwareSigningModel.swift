

import Foundation

public struct DataModel: Codable {
    public  let selectedTemplates: [Int]
    public  let header:String?
    public  let subHeader:String?
    public  let confirmationMessage:String?
    public  let autoDownload:Bool
    
    public  let enableDigitalSignature:Bool
    public  let hideSignatureBoard:Bool?
    public  let otpInputType:String
    public  let enableOtp:Bool
    public  let otpSize:Int?
    public  let otpType:Int?
    public  let otpExpiryTime:Double?
    
}

public struct ContextAwareSigningModel: Codable {
    public  let statusCode: Int
    public  let data: DataModel
}
