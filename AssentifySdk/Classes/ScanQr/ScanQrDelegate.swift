
import Foundation

@objc public protocol  ScanQrDelegate{
    
    func onStartQrScan()

    func onErrorQrScan(message: String)

    func onCompleteQrScan(dataModel: IDResponseModel)
    
    @objc func onUploadingProgress(progress:Double)
}
