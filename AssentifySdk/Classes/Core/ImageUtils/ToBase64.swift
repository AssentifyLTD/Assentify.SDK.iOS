import UIKit
import CoreImage
import MobileCoreServices
func convertPixelBufferToBase64(pixelBuffer: CVPixelBuffer) -> String? {
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let context = CIContext()
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return nil
    }
    let uiImage = UIImage(cgImage: cgImage)
    
    guard let pngData = uiImage.pngData() else {
        return nil
    }
    
    guard let imageData = uiImage.jpeg2000DataLossless() else {
        return nil
    }
    
    
    let base64String = imageData.base64EncodedString()
    return base64String
}

func convertClipsPixelBufferToBase64(pixelBuffer: CVPixelBuffer) -> String? {
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let context = CIContext()
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return nil
    }
    let uiImage = UIImage(cgImage: cgImage)
    
    guard let pngData = uiImage.pngData() else {
        return nil
    }
    
    guard let imageData = uiImage.jpeg2000DataLosslessClips() else {
        return nil
    }
    
    
    let base64String = imageData.base64EncodedString()
    return base64String
}


extension UIImage {
    func jpeg2000DataLossless() -> Data? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        let mutableData = NSMutableData()
        let imageDestination = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG2000, 1, nil)!
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality:0.5
        ]
        CGImageDestinationAddImage(imageDestination, cgImage, options)
        CGImageDestinationFinalize(imageDestination)
        return mutableData as Data
    }
    func jpeg2000DataLosslessClips() -> Data? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        let mutableData = NSMutableData()
        let imageDestination = CGImageDestinationCreateWithData(mutableData, kUTTypeJPEG2000, 1, nil)!
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality:0.1
        ]
        CGImageDestinationAddImage(imageDestination, cgImage, options)
        CGImageDestinationFinalize(imageDestination)
        return mutableData as Data
    }
}
