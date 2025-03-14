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

func saveBase64ImageToGallery(base64String: String) {
    guard let imageData = Data(base64Encoded: base64String) else {
        print("Failed to decode Base64 string to Data")
        return
    }
    
    guard let uiImage = UIImage(data: imageData) else {
        print("Failed to create UIImage from decoded Data")
        return
    }
    
    // Save the image to the photo gallery
    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    print("Image saved to gallery")
}



func downscalePixelBuffer(_ pixelBuffer: CVPixelBuffer, scaleFactor: CGFloat) -> CVPixelBuffer? {
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
    let scaledImage = ciImage.transformed(by: transform)
    
    let context = CIContext()
    var scaledPixelBuffer: CVPixelBuffer?
    CVPixelBufferCreate(nil,
                        Int(scaledImage.extent.width),
                        Int(scaledImage.extent.height),
                        CVPixelBufferGetPixelFormatType(pixelBuffer),
                        nil,
                        &scaledPixelBuffer)
    
    if let scaledPixelBuffer = scaledPixelBuffer {
        context.render(scaledImage, to: scaledPixelBuffer)
    }
    
    return scaledPixelBuffer
}


func copyPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let pixelFormatType = CVPixelBufferGetPixelFormatType(pixelBuffer)
    
    var copiedBuffer: CVPixelBuffer?
    let attributes: [CFString: Any] = [
        kCVPixelBufferCGImageCompatibilityKey: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey: true
    ]
    
    let status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        pixelFormatType,
        attributes as CFDictionary,
        &copiedBuffer
    )
    
    guard status == kCVReturnSuccess, let newBuffer = copiedBuffer else {
        print("Failed to create pixel buffer copy")
        return nil
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    CVPixelBufferLockBaseAddress(newBuffer, [])
    
    if let sourceBaseAddress = CVPixelBufferGetBaseAddress(pixelBuffer),
       let destinationBaseAddress = CVPixelBufferGetBaseAddress(newBuffer) {
        let sourceBytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let destinationBytesPerRow = CVPixelBufferGetBytesPerRow(newBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        for row in 0..<height {
            memcpy(destinationBaseAddress + row * destinationBytesPerRow,
                   sourceBaseAddress + row * sourceBytesPerRow,
                   sourceBytesPerRow)
        }
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
    CVPixelBufferUnlockBaseAddress(newBuffer, [])
    
    return newBuffer
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
