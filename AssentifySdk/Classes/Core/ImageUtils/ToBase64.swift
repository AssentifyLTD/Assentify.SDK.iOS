
import Foundation

import UIKit

func convertPixelBufferToBase64(pixelBuffer: CVPixelBuffer) -> String? {
    
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let context = CIContext()
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return nil
    }
    let uiImage = UIImage(cgImage: cgImage)

    guard let imageData = uiImage.jpegData(compressionQuality: 0.3) else {
        return nil
    }

    let base64String = imageData.base64EncodedString()
    return base64String
}
